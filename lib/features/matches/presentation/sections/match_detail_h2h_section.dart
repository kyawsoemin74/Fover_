import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionHeading(title: 'Head to Head'),
        const SizedBox(height: 16),
        _H2HSummaryCard(h2h: h2h),
        const SizedBox(height: 18),
        ...h2h.meetings.take(4).map((meeting) => _MeetingCard(meeting: meeting)),
      ],
    );
  }
}

class _H2HSummaryCard extends StatelessWidget {
  const _H2HSummaryCard({required this.h2h});

  final dynamic h2h;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF111827), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _SummaryMetric(
            label: h2h.homeTeamName,
            value: h2h.homeWins.toString(),
            accent: const Color(0xFF4F46E5),
          ),
          _SummaryMetric(
            label: 'Draws',
            value: h2h.draws.toString(),
            accent: const Color(0xFF6B7280),
          ),
          _SummaryMetric(
            label: h2h.awayTeamName,
            value: h2h.awayWins.toString(),
            accent: const Color(0xFF2563EB),
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

class _MeetingCard extends StatelessWidget {
  const _MeetingCard({required this.meeting});

  final dynamic meeting;

  @override
  Widget build(BuildContext context) {
    final date = meeting.date is DateTime
        ? meeting.date as DateTime
        : DateTime.now();
    final resultText =
        '${meeting.homeTeam} ${meeting.homeScore} - ${meeting.awayScore} ${meeting.awayTeam}';
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  resultText,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  meeting.status,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: Colors.white24,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                '${date.day}/${date.month}/${date.year}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white54,
                    ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.location_on,
                color: Colors.white24,
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  meeting.venue,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white54,
                      ),
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
