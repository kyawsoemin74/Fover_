import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fover/features/matches/providers/match_stats_provider.dart';

class MatchDetailStatsSection extends ConsumerWidget {
  const MatchDetailStatsSection({super.key, required this.matchId});

  final int matchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(matchStatsProvider(matchId));
    if (state.status == MatchStatsStatus.loading ||
        state.status == MatchStatsStatus.initial) {
      return const _SectionPlaceholder(message: 'Loading match statistics.');
    }

    if (state.status == MatchStatsStatus.error) {
      return const _SectionPlaceholder(
        message: 'Statistics data is not available for this match yet.',
      );
    }

    final stats = state.stats;
    if (stats == null || !stats.hasData) {
      return const _SectionPlaceholder(
        message: 'Statistic data is not available for this match yet.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionHeading(title: 'Match Stats'),
        const SizedBox(height: 18),
        _StatRow(
          label: 'Possession',
          homeValue: stats.homePossession,
          awayValue: stats.awayPossession,
          accent: const Color(0xFF4F46E5),
        ),
        _StatRow(
          label: 'Shots',
          homeValue: stats.homeShots,
          awayValue: stats.awayShots,
          accent: const Color(0xFF2563EB),
        ),
        _StatRow(
          label: 'On Target',
          homeValue: stats.homeShotsOnTarget,
          awayValue: stats.awayShotsOnTarget,
          accent: const Color(0xFF22C55E),
        ),
        _StatRow(
          label: 'Corners',
          homeValue: stats.homeCorners,
          awayValue: stats.awayCorners,
          accent: const Color(0xFF8B5CF6),
        ),
        _StatRow(
          label: 'Attacks',
          homeValue: stats.homeAttacks,
          awayValue: stats.awayAttacks,
          accent: const Color(0xFFF97316),
        ),
        _StatRow(
          label: 'Dangerous Attacks',
          homeValue: stats.homeDangerousAttacks,
          awayValue: stats.awayDangerousAttacks,
          accent: const Color(0xFF4ADE80),
        ),
        _StatRow(
          label: 'Fouls',
          homeValue: stats.homeFouls,
          awayValue: stats.awayFouls,
          accent: const Color(0xFFF59E0B),
        ),
        _StatRow(
          label: 'Yellow Cards',
          homeValue: stats.homeYellowCards,
          awayValue: stats.awayYellowCards,
          accent: const Color(0xFFEAB308),
        ),
        _StatRow(
          label: 'Red Cards',
          homeValue: stats.homeRedCards,
          awayValue: stats.awayRedCards,
          accent: const Color(0xFFEF4444),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.homeValue,
    required this.awayValue,
    required this.accent,
  });

  final String label;
  final int homeValue;
  final int awayValue;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final total = (homeValue + awayValue).clamp(1, double.infinity).toDouble();
    final homeWidth = homeValue / total;
    final awayWidth = awayValue / total;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Text(
                '$homeValue - $awayValue',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white54,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Row(
              children: [
                Expanded(
                  flex: (homeWidth * 100).round(),
                  child: Container(
                    height: 10,
                    color: accent,
                  ),
                ),
                Expanded(
                  flex: (awayWidth * 100).round(),
                  child: Container(
                    height: 10,
                    color: Color.fromRGBO(
                      (accent.r * 255.0).round().clamp(0, 255),
                      (accent.g * 255.0).round().clamp(0, 255),
                      (accent.b * 255.0).round().clamp(0, 255),
                      0.35,
                    ),
                  ),
                ),
              ],
            ),
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
      padding: const EdgeInsets.all(22),
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

