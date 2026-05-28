import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fover/features/matches/domain/models/match_event_model.dart';
import 'package:fover/features/matches/providers/match_events_provider.dart';

class MatchDetailDetailsSection extends ConsumerWidget {
  const MatchDetailDetailsSection({
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
    final state = ref.watch(matchEventsProvider(matchId));
    if (state.status == MatchEventsStatus.loading ||
        state.status == MatchEventsStatus.initial) {
      return const _SectionPlaceholder(title: 'Events timeline is loading.');
    }

    if (state.status == MatchEventsStatus.error) {
      return _SectionError(
        message: state.errorMessage,
        onRetry: () =>
            ref.read(matchEventsProvider(matchId).notifier).loadEvents(),
      );
    }

    final events = state.events;
    if (events.isEmpty) {
      return const _SectionPlaceholder(title: 'No match events available yet.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionHeading(title: 'Match Timeline'),
        const SizedBox(height: 16),
        ...events.map(
          (event) => _TimelineEvent(
            event: event,
            homeTeamId: homeTeamId,
            awayTeamId: awayTeamId,
          ),
        ),
      ],
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
            fontWeight: FontWeight.w800,
          ),
    );
  }
}

class _TimelineEvent extends StatelessWidget {
  const _TimelineEvent({
    required this.event,
    required this.homeTeamId,
    required this.awayTeamId,
  });

  final MatchEventInfo event;
  final int homeTeamId;
  final int awayTeamId;

  Color get _accentColor {
    switch (event.type) {
      case MatchEventType.goal:
      case MatchEventType.ownGoal:
      case MatchEventType.penalty:
        return const Color(0xFF22C55E);
      case MatchEventType.yellowCard:
        return const Color(0xFFFACC15);
      case MatchEventType.redCard:
        return const Color(0xFFEF4444);
      case MatchEventType.substitution:
        return const Color(0xFF3B82F6);
      case MatchEventType.varReview:
        return const Color(0xFF8B5CF6);
      case MatchEventType.halftime:
      case MatchEventType.fulltime:
        return const Color(0xFF9CA3AF);
      default:
        return const Color(0xFF8B5CF6);
    }
  }

  IconData get _icon {
    switch (event.type) {
      case MatchEventType.goal:
      case MatchEventType.ownGoal:
        return Icons.sports_soccer;
      case MatchEventType.penalty:
        return Icons.shield;
      case MatchEventType.yellowCard:
        return Icons.crop_square;
      case MatchEventType.redCard:
        return Icons.crop_square;
      case MatchEventType.substitution:
        return Icons.swap_horiz;
      case MatchEventType.varReview:
        return Icons.tv;
      case MatchEventType.kickoff:
        return Icons.sports_score;
      case MatchEventType.halftime:
      case MatchEventType.fulltime:
        return Icons.flag;
      default:
        return Icons.info;
    }
  }

  String get _eventMinute {
    final base = event.minute.toString();
    return event.extraMinute > 0 ? '$base+${event.extraMinute}' : base;
  }

  String get _subtitle {
    final parts = <String>[];
    if (event.description.isNotEmpty) parts.add(event.description);
    if (event.assistName != null && event.assistName!.isNotEmpty) {
      parts.add('Assist: ${event.assistName}');
    }
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final isHome = event.teamId == homeTeamId;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Color.fromRGBO(
                (_accentColor.r * 255.0).round().clamp(0, 255),
                (_accentColor.g * 255.0).round().clamp(0, 255),
                (_accentColor.b * 255.0).round().clamp(0, 255),
                0.18,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(_icon, color: _accentColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_eventMinute ${event.teamName}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  event.playerName.isNotEmpty ? event.playerName : event.detail,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (_subtitle.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    _subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white54,
                        ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            isHome ? 'Home' : 'Away',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white54,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _SectionPlaceholder extends StatelessWidget {
  const _SectionPlaceholder({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(
        title,
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
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            message ?? 'Unable to load details.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white54),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
