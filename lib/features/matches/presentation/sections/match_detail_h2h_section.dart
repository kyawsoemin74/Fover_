import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fover/features/matches/domain/models/match_h2h_model.dart';
import 'package:fover/features/matches/presentation/pages/match_detail_page.dart';
import 'package:fover/features/matches/providers/match_detail_provider.dart';
import 'package:fover/features/matches/providers/match_h2h_provider.dart';

class MatchDetailH2HSection extends ConsumerStatefulWidget {
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
  ConsumerState<MatchDetailH2HSection> createState() =>
      _MatchDetailH2HSectionState();
}

class _MatchDetailH2HSectionState extends ConsumerState<MatchDetailH2HSection> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final request = MatchH2HRequest(
      matchId: widget.matchId,
      homeTeamId: widget.homeTeamId,
      awayTeamId: widget.awayTeamId,
    );
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
        onRetry: () => ref
            .read(matchDetailProvider(widget.matchId).notifier)
            .setSelectedTab(MatchDetailTab.h2h, forceRefresh: true),
      );
    }

    final h2h = state.h2h;
    if (h2h == null || !h2h.hasHistory) {
      return const _SectionPlaceholder(
        message: 'No head-to-head fixtures found.',
      );
    }

    final hasMore = h2h.meetings.length > 5;
    final meetings = _showAll ? h2h.meetings : h2h.meetings.take(5).toList();

    return ListView(
      children: [
        const _SectionHeading(title: 'Head to Head'),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1124),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _H2HSummaryCard(h2h: h2h),
              const SizedBox(height: 10),
              const Divider(height: 1, thickness: 0.7, color: Colors.white12),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: meetings.length,
                separatorBuilder: (context, index) => const Divider(
                  height: 1,
                  thickness: 0.7,
                  color: Colors.white12,
                ),
                itemBuilder: (context, index) =>
                    _H2HMatchRow(meeting: meetings[index]),
              ),
              if (hasMore) ...[
                const Divider(height: 1, thickness: 0.7, color: Colors.white12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _showAll = !_showAll;
                      });
                    },
                    child: Text(_showAll ? 'Show Less' : 'Show More'),
                  ),
                ),
              ],
            ],
          ),
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
    final homeWins = h2h.homeWins;
    final draws = h2h.draws;
    final awayWins = h2h.awayWins;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _SummaryMetric(
                  label: 'Wins',
                  value: homeWins.toString(),
                  accent: const Color(0xFF22C55E),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SummaryMetric(
                  label: 'Draws',
                  value: draws.toString(),
                  accent: const Color(0xFF4B5563),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SummaryMetric(
                  label: 'Wins',
                  value: awayWins.toString(),
                  accent: const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFF1F2937),
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.hardEdge,
            child: Row(
              children: [
                if (homeWins > 0)
                  Expanded(
                    flex: homeWins,
                    child: Container(color: const Color(0xFF22C55E)),
                  ),
                if (draws > 0)
                  Expanded(
                    flex: draws,
                    child: Container(color: const Color(0xFF4B5563)),
                  ),
                if (awayWins > 0)
                  Expanded(
                    flex: awayWins,
                    child: Container(color: const Color(0xFFEF4444)),
                  ),
                if (homeWins == 0 && draws == 0 && awayWins == 0)
                  Expanded(child: Container(color: const Color(0xFF374151))),
              ],
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
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
    const monthShort = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
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
    final dateLabel = _formatDate(date);
    final statusShort = meeting.statusShort.toUpperCase();
    final statusLabel = statusShort == 'NS' || statusShort.isEmpty
        ? _formatTime(date)
        : statusShort;

    final finished =
        statusShort == 'FT' ||
        (meeting.homeScore != 0 || meeting.awayScore != 0) &&
            statusShort != 'NS';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (meeting.leagueName.isNotEmpty) ...[
            Text(
              meeting.leagueName,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
          ],
          Text(
            '$dateLabel • $statusLabel',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white54,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
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
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
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
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(color: Colors.white54),
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
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.white54),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
