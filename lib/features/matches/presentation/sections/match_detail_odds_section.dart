import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fover/features/matches/providers/match_odds_provider.dart';

class MatchDetailOddsSection extends ConsumerWidget {
  const MatchDetailOddsSection({super.key, required this.matchId});

  final int matchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(matchOddsProvider(matchId));
    if (state.status == MatchOddsStatus.loading ||
        state.status == MatchOddsStatus.initial) {
      return const _SectionPlaceholder(
        message: 'Fetching odds and market lines.',
      );
    }

    if (state.status == MatchOddsStatus.error) {
      return _SectionError(
        message: state.errorMessage,
        onRetry: () => ref.read(matchOddsProvider(matchId).notifier).loadOdds(),
      );
    }

    final odds = state.odds?.odds ?? [];
    if (odds.isEmpty) {
      return const _SectionPlaceholder(
        message: 'No odds available for this match.',
      );
    }

    final grouped = _groupByMarket(odds);
    final entries = grouped.entries.toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1124),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SectionHeading(title: ''),
          const SizedBox(height: 12),
          ...entries.asMap().entries.map((pair) {
            final idx = pair.key;
            final entry = pair.value;
            final items = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _SectionHeading(title: entry.key),
                  const SizedBox(height: 8),
                  _OddsMarketRow(items: items),
                  if (idx < entries.length - 1) ...[
                    const SizedBox(height: 12),
                    Divider(color: Colors.white12, height: 1),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Map<String, List<Map<String, String>>> _groupByMarket(List<dynamic> oddsList) {
    final grouped = <String, List<Map<String, String>>>{};
    for (final raw in oddsList) {
      if (raw is Map<String, dynamic>) {
        final market = raw['market']?.toString() ?? raw['name']?.toString() ?? 'Market';

        // Case A: individual selection entries: {market, selection, odd}
        if (raw.containsKey('selection') && (raw.containsKey('odd') || raw.containsKey('price'))) {
          final sel = raw['selection']?.toString() ?? '';
          final odd = raw['odd']?.toString() ?? raw['price']?.toString() ?? '';
          grouped.putIfAbsent(market, () => []).add({'selection': sel, 'odd': odd});
          continue;
        }

        // Case B: combined entry with home/draw/away keys
        final home = raw['home']?.toString() ?? raw['back_home']?.toString() ?? raw['odds_home']?.toString();
        final draw = raw['draw']?.toString() ?? raw['back_draw']?.toString() ?? raw['odds_draw']?.toString();
        final away = raw['away']?.toString() ?? raw['back_away']?.toString() ?? raw['odds_away']?.toString();
        if (home != null || draw != null || away != null) {
          final list = <Map<String, String>>[];
          if (home != null) list.add({'selection': 'Home', 'odd': home});
          if (draw != null) list.add({'selection': 'Draw', 'odd': draw});
          if (away != null) list.add({'selection': 'Away', 'odd': away});
          if (list.isNotEmpty) grouped.putIfAbsent(market, () => []).addAll(list);
          continue;
        }

        // Case C: try common fallbacks
        final selKey = raw.keys.firstWhere((k) => k.toLowerCase().contains('selection') || k.toLowerCase().contains('name'), orElse: () => '');
        final oddKey = raw.keys.firstWhere((k) => k.toLowerCase().contains('odd') || k.toLowerCase().contains('price') || k.toLowerCase().contains('odds'), orElse: () => '');
        if (selKey.isNotEmpty && oddKey.isNotEmpty) {
          final sel = raw[selKey]?.toString() ?? '';
          final odd = raw[oddKey]?.toString() ?? '';
          grouped.putIfAbsent(market, () => []).add({'selection': sel, 'odd': odd});
        }
      }
    }

    if (grouped.isEmpty) {
      grouped['Match Odds'] = [ {'selection': 'Unavailable', 'odd': '-'} ];
    }
    return grouped;
  }

}

class _OddsMarketRow extends StatelessWidget {
  const _OddsMarketRow({
    required this.items,
  });

  final List<Map<String, String>> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.secondary;

    return Row(
      children: items.map((item) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF0B1124),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item['selection'] ?? '',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  item['odd'] ?? '',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: accent,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
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
            message ?? 'Unable to load odds.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white54),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Refresh')),
        ],
      ),
    );
  }
}
