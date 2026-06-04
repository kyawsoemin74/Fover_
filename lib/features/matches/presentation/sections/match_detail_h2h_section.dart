import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fover/features/matches/domain/models/match_h2h_model.dart';
import 'package:fover/features/matches/providers/match_h2h_provider.dart';

class MatchDetailH2HSection extends ConsumerWidget {
  const MatchDetailH2HSection({
    super.key,
    required this.matchId,
    required this.homeTeamId,
    required this.awayTeamId,
  });

  final int matchId;
  final int homeTeamId;
  final int awayTeamId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = MatchH2HRequest(
      matchId: matchId,
      homeTeamId: homeTeamId,
      awayTeamId: awayTeamId,
    );
    // ignore: avoid_print
    print('WATCH PROVIDER HASH => ${request.hashCode}');
    final state = ref.watch(matchH2HProvider(request));

    if (state.status == MatchH2HStatus.loading ||
        state.status == MatchH2HStatus.initial) {
      return const _SectionPlaceholder(
        message: 'Loading head-to-head history.',
      );
    }

    if (state.status == MatchH2HStatus.error) {
      return _SectionError(
        message: state.errorMessage,
        onRetry: () => ref.read(matchH2HProvider(request).notifier).loadH2H(),
      );
    }

    final h2h = state.h2h;
    if (h2h == null || !h2h.hasHistory) {
      return const _SectionPlaceholder(
        message: 'No head-to-head fixtures found.',
      );
    }

    final meetings = h2h.meetings.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionHeading(title: 'Head to Head'),
        const SizedBox(height: 12),
        _H2HSummaryCard(h2h: h2h),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: meetings.length,
          separatorBuilder: (context, index) => const Divider(height: 1, color: Colors.white12),
          itemBuilder: (context, index) => _H2HMatchRow(meeting: meetings[index]),
        ),
      ],
    );
  }
}

class _H2HSummaryCard extends StatelessWidget {
  const _H2HSummaryCard({required this.h2h});

  final MatchH2HInfo h2h;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryMetric(
              label: h2h.homeTeamName,
              value: '${h2h.homeWins}W',
              accent: const Color(0xFF22C55E),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _SummaryMetric(
              label: 'Draws',
              value: h2h.draws.toString(),
              accent: const Color(0xFFF59E0B),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _SummaryMetric(
              label: h2h.awayTeamName,
              value: '${h2h.awayWins}W',
              accent: const Color(0xFF3B82F6),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: accent,
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white54,
                letterSpacing: 0.4,
              ),
        ),
      ],
    );
  }
}

class _H2HMatchRow extends StatelessWidget {
  const _H2HMatchRow({required this.meeting});

  final MatchH2HMeeting meeting;

  String _formatDate(DateTime d) {
    // Example: 30 Nov 2026
    const monthShort = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day.toString().padLeft(2, '0')} ${monthShort[d.month - 1]} ${d.year}';
  }

  String _formatTime(DateTime d) {
    final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final minute = d.minute.toString().padLeft(2, '0');
    final ampm = d.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final date = meeting.date;
    final leftTop = _formatDate(date);
    final statusShort = meeting.statusShort.toUpperCase();
    final leftBottom = statusShort == 'NS' || statusShort.isEmpty ? _formatTime(date) : statusShort;

    final finished = statusShort == 'FT' || (meeting.homeScore != 0 || meeting.awayScore != 0) && statusShort != 'NS';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 110,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  leftTop,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  leftBottom,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white54,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(width: 1, height: 44, color: Colors.white12),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        meeting.homeTeam,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      width: 40,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: finished
                            ? Text(
                                meeting.homeScore.toString(),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        meeting.awayTeam,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      width: 40,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: finished
                            ? Text(
                                meeting.awayScore.toString(),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),
        ],
      ),
    );
  }
}


// Last 5 meetings and total-goals widgets removed per design requirements.

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

class _SectionPlaceholder extends StatelessWidget {
  const _SectionPlaceholder({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white54),
      ),
    );
  }
}

class _SectionError extends StatelessWidget {
  const _SectionError({required this.message, required this.onRetry});

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            message ?? 'Unable to load head-to-head data.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white54),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
