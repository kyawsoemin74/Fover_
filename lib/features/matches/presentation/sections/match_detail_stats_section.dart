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
      return const _SectionStatusCard(
        icon: Icons.query_stats_outlined,
        title: 'Loading statistics',
        message: 'Fetching match statistics.',
      );
    }

    if (state.status == MatchStatsStatus.error) {
      return _SectionStatusCard(
        icon: Icons.error_outline,
        title: 'Statistics unavailable',
        message: state.errorMessage ?? 'Unable to load match statistics.',
        actionLabel: 'Retry',
        onAction: () => ref
            .read(matchStatsProvider(matchId).notifier)
            .loadStats(forceRefresh: true),
      );
    }

    final stats = state.stats;
    if (state.status == MatchStatsStatus.empty || stats == null || !stats.hasData) {
      return const _SectionStatusCard(
        icon: Icons.insert_chart_outlined,
        title: 'No statistics yet',
        message: 'Statistic data is not available for this match yet.',
      );
    }

    final metrics = _StatsCardData.fromStats(stats);

    return _StatisticsCard(metrics: metrics);
  }
}

double _toNumFlexible(dynamic value) {
  if (value == null) return 0.0;
  if (value is int) return value.toDouble();
  if (value is double) return value;
  if (value is String) {
    var s = value.trim();
    if (s.endsWith('%')) {
      s = s.substring(0, s.length - 1).trim();
    }
    s = s.replaceAll(',', '');
    final d = double.tryParse(s);
    if (d != null) return d;
  }
  return 0.0;
}

String _formatStatValue(dynamic raw) {
  if (raw == null) return '0';
  if (raw is num) {
    if (raw is double && raw % 1 != 0) {
      return raw.toStringAsFixed(1);
    }
    return raw.toString();
  }
  final text = raw.toString().trim();
  return text.isEmpty ? '0' : text;
}

class _StatsCardData {
  const _StatsCardData({
    required this.ballPossessionHome,
    required this.ballPossessionAway,
    required this.expectedGoalsHome,
    required this.expectedGoalsAway,
    required this.totalShotsHome,
    required this.totalShotsAway,
    required this.shotsOnTargetHome,
    required this.shotsOnTargetAway,
    required this.cornerKicksHome,
    required this.cornerKicksAway,
    required this.yellowCardsHome,
    required this.yellowCardsAway,
  });

  final dynamic ballPossessionHome;
  final dynamic ballPossessionAway;
  final dynamic expectedGoalsHome;
  final dynamic expectedGoalsAway;
  final dynamic totalShotsHome;
  final dynamic totalShotsAway;
  final dynamic shotsOnTargetHome;
  final dynamic shotsOnTargetAway;
  final dynamic cornerKicksHome;
  final dynamic cornerKicksAway;
  final dynamic yellowCardsHome;
  final dynamic yellowCardsAway;

  factory _StatsCardData.fromStats(dynamic stats) {
    final itemLookup = <String, _StatMetric>{};
    final items = stats.items;
    if (items != null && items.isNotEmpty) {
      for (final item in items) {
        final key = _normalizeMetricKey(item.dataName, item.label);
        if (key.isNotEmpty) {
          itemLookup.putIfAbsent(key, () => _StatMetric(item.homeValue, item.awayValue));
        }
      }
    }

    return _StatsCardData(
      ballPossessionHome: _lookupMetricPair(itemLookup, stats.homePossession, stats.awayPossession, const ['ball_possession', 'possession']).homeValue,
      ballPossessionAway: _lookupMetricPair(itemLookup, stats.homePossession, stats.awayPossession, const ['ball_possession', 'possession']).awayValue,
      expectedGoalsHome: _lookupMetricPair(itemLookup, 0, 0, const ['xg', 'expected_goals', 'expected_goals_xg']).homeValue,
      expectedGoalsAway: _lookupMetricPair(itemLookup, 0, 0, const ['xg', 'expected_goals', 'expected_goals_xg']).awayValue,
      totalShotsHome: _lookupMetricPair(itemLookup, stats.homeShots, stats.awayShots, const ['total_shots', 'shots', 'shots_total']).homeValue,
      totalShotsAway: _lookupMetricPair(itemLookup, stats.homeShots, stats.awayShots, const ['total_shots', 'shots', 'shots_total']).awayValue,
      shotsOnTargetHome: _lookupMetricPair(itemLookup, stats.homeShotsOnTarget, stats.awayShotsOnTarget, const ['shots_on_goal', 'shots_on_target']).homeValue,
      shotsOnTargetAway: _lookupMetricPair(itemLookup, stats.homeShotsOnTarget, stats.awayShotsOnTarget, const ['shots_on_goal', 'shots_on_target']).awayValue,
      cornerKicksHome: _lookupMetricPair(itemLookup, stats.homeCorners, stats.awayCorners, const ['corner_kicks', 'corners']).homeValue,
      cornerKicksAway: _lookupMetricPair(itemLookup, stats.homeCorners, stats.awayCorners, const ['corner_kicks', 'corners']).awayValue,
      yellowCardsHome: _lookupMetricPair(itemLookup, stats.homeYellowCards, stats.awayYellowCards, const ['yellow_cards']).homeValue,
      yellowCardsAway: _lookupMetricPair(itemLookup, stats.homeYellowCards, stats.awayYellowCards, const ['yellow_cards']).awayValue,
    );
  }
}

_StatMetric _lookupMetricPair(
  Map<String, _StatMetric> lookup,
  dynamic fallbackHome,
  dynamic fallbackAway,
  List<String> keys,
) {
  for (final key in keys) {
    final metric = lookup[key];
    if (metric != null) {
      return metric;
    }
  }
  return _StatMetric(fallbackHome, fallbackAway);
}

String _normalizeMetricKey(String dataName, String label) {
  final raw = '${dataName}_$label'.toLowerCase();
  final normalized = raw
      .replaceAll('%', '')
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
  if (normalized.contains('ball_possession') || normalized.contains('possession')) {
    return 'ball_possession';
  }
  if (normalized.contains('expected_goals') || normalized.contains('xg')) {
    return 'xg';
  }
  if (normalized.contains('shots_on_goal') || normalized.contains('shots_on_target')) {
    return 'shots_on_goal';
  }
  if (normalized.contains('total_shots') || (normalized.contains('shots') && !normalized.contains('off') && !normalized.contains('goal') && !normalized.contains('target'))) {
    return 'total_shots';
  }
  if (normalized.contains('corner')) {
    return 'corner_kicks';
  }
  if (normalized.contains('yellow')) {
    return 'yellow_cards';
  }
  return normalized;
}

class _StatMetric {
  const _StatMetric(this.homeValue, this.awayValue);

  final dynamic homeValue;
  final dynamic awayValue;
}

class _StatisticsCard extends StatelessWidget {
  const _StatisticsCard({required this.metrics});

  final _StatsCardData metrics;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1220),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PossessionComparisonRow(
            homeValue: metrics.ballPossessionHome,
            awayValue: metrics.ballPossessionAway,
            homeColor: const Color(0xFF22C55E),
            awayColor: const Color(0xFFFACC15),
          ),
          const SizedBox(height: 12),
          _CompactComparisonRow(
            title: 'Expected Goals (xG)',
            homeValue: metrics.expectedGoalsHome,
            awayValue: metrics.expectedGoalsAway,
          ),
          const SizedBox(height: 8),
          _CompactComparisonRow(
            title: 'Total Shots',
            homeValue: metrics.totalShotsHome,
            awayValue: metrics.totalShotsAway,
          ),
          const SizedBox(height: 8),
          _CompactComparisonRow(
            title: 'Shots on Target',
            homeValue: metrics.shotsOnTargetHome,
            awayValue: metrics.shotsOnTargetAway,
          ),
          const SizedBox(height: 8),
          _CompactComparisonRow(
            title: 'Corner Kicks',
            homeValue: metrics.cornerKicksHome,
            awayValue: metrics.cornerKicksAway,
          ),
          const SizedBox(height: 8),
          _CompactComparisonRow(
            title: 'Yellow Cards',
            homeValue: metrics.yellowCardsHome,
            awayValue: metrics.yellowCardsAway,
          ),
        ],
      ),
    );
  }
}

class _PossessionComparisonRow extends StatelessWidget {
  const _PossessionComparisonRow({
    required this.homeValue,
    required this.awayValue,
    required this.homeColor,
    required this.awayColor,
  });

  final dynamic homeValue;
  final dynamic awayValue;
  final Color homeColor;
  final Color awayColor;

  @override
  Widget build(BuildContext context) {
    final home = _toNumFlexible(homeValue);
    final away = _toNumFlexible(awayValue);
    final total = (home + away).clamp(0.0001, double.infinity);
    final homeWidth = home / total;
    final awayWidth = away / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            SizedBox(
              width: 44,
              child: Text(
                _formatStatValue(homeValue),
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Ball Possession',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 44,
              child: Text(
                _formatStatValue(awayValue),
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 6,
                child: Row(
                  children: [
                    Expanded(
                      flex: (homeWidth * 100).round().clamp(1, 100),
                      child: ColoredBox(color: homeColor),
                    ),
                    Expanded(
                      flex: (awayWidth * 100).round().clamp(1, 100),
                      child: ColoredBox(color: awayColor),
                    ),
                  ],
                ),
              ),
              Container(width: 1.5, height: 6, color: Colors.white),
            ],
          ),
        ),
      ],
    );
  }
}

class _CompactComparisonRow extends StatelessWidget {
  const _CompactComparisonRow({
    required this.title,
    required this.homeValue,
    required this.awayValue,
  });

  final String title;
  final dynamic homeValue;
  final dynamic awayValue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Text(
              _formatStatValue(homeValue),
              textAlign: TextAlign.left,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 44,
            child: Text(
              _formatStatValue(awayValue),
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionStatusCard extends StatelessWidget {
  const _SectionStatusCard({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1220),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(icon, color: Colors.white54, size: 24),
          const SizedBox(height: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white60,
              height: 1.4,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

