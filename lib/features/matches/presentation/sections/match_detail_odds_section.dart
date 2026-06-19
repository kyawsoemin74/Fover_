import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fover/features/matches/providers/match_odds_provider.dart';

class MatchDetailOddsSection extends ConsumerWidget {
  const MatchDetailOddsSection({super.key, required this.matchId});

  static const double _cardRadius = 16;
  static const double _cardPadding = 10;
  static const double _marketSpacing = 10;
  static const double _itemSpacing = 6;
  static const String _myanmarBodyTitle = 'မြန်မာကြေး-ဘော်ဒီ';
  static const String _myanmarGoalsTitle = 'မြန်မာကြေး-ဂိုးပေါင်း';

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
        onRetry: () => ref
            .read(matchOddsProvider(matchId).notifier)
            .loadOdds(forceRefresh: true),
      );
    }

    final odds = state.odds?.odds ?? [];
    if (odds.isEmpty) {
      return const _SectionPlaceholder(
        message: 'No odds available for this match.',
      );
    }

    final bookmaker = _resolveBookmakerLabel(odds);
    final grouped = _groupByMarket(odds);
    final entries = _buildDisplayEntries(grouped, odds);

    return Container(
      padding: const EdgeInsets.all(_cardPadding),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1124),
        borderRadius: BorderRadius.circular(_cardRadius),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BookmakerHeader(title: bookmaker),
          const SizedBox(height: 8),
          ...entries.asMap().entries.map((pair) {
            final idx = pair.key;
            final entry = pair.value;
            final items = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: _itemSpacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MarketHeading(title: entry.key),
                  const SizedBox(height: 4),
                  const Divider(color: Colors.white12, height: 1, thickness: 0.7),
                  const SizedBox(height: 6),
                  _buildMarketContent(entry.key, items),
                  if (idx < entries.length - 1) ...[
                    const SizedBox(height: _marketSpacing),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _resolveBookmakerLabel(List<dynamic> oddsList) {
    final names = <String>{};
    for (final raw in oddsList) {
      if (raw is Map<String, dynamic>) {
        final value = raw['bookmaker']?.toString().trim();
        if (value != null && value.isNotEmpty) {
          names.add(value);
        }
      }
    }

    if (names.isEmpty) return 'Bookmaker';
    if (names.length == 1) return names.first;
    return '${names.first} +${names.length - 1}';
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

  List<MapEntry<String, List<Map<String, String>>>> _buildDisplayEntries(
    Map<String, List<Map<String, String>>> grouped,
    List<dynamic> oddsList,
  ) {
    final output = <MapEntry<String, List<Map<String, String>>>>[];

    void addMarket(String title) {
      final items = grouped[title];
      if (items != null && items.isNotEmpty) {
        output.add(MapEntry(title, items));
      }
    }

    addMarket('Match Winner');

    final myanmarBodyItems = _extractMyanmarOdds(
      oddsList: oddsList,
      sourceMarket: 'Asian Handicap',
      keepSelection: false,
    );
    if (myanmarBodyItems.isNotEmpty) {
      output.add(MapEntry(_myanmarBodyTitle, myanmarBodyItems));
    }

    addMarket('Asian Handicap');

    final myanmarGoalsItems = _extractMyanmarOdds(
      oddsList: oddsList,
      sourceMarket: 'Goals Over/Under',
      keepSelection: true,
    );
    if (myanmarGoalsItems.isNotEmpty) {
      output.add(MapEntry(_myanmarGoalsTitle, myanmarGoalsItems));
    }

    addMarket('Goals Over/Under');
    addMarket('Corners Over Under');

    final consumed = output.map((e) => e.key).toSet();
    for (final entry in grouped.entries) {
      if (!consumed.contains(entry.key)) {
        output.add(entry);
      }
    }

    if (output.isEmpty) {
      return grouped.entries.toList();
    }

    return output;
  }

  List<Map<String, String>> _extractMyanmarOdds({
    required List<dynamic> oddsList,
    required String sourceMarket,
    required bool keepSelection,
  }) {
    final items = <Map<String, String>>[];
    for (final raw in oddsList) {
      if (raw is! Map<String, dynamic>) {
        continue;
      }

      final market = raw['market']?.toString().trim();
      if (market != sourceMarket) {
        continue;
      }

      final myanmarOdd = raw['myanmar_odd']?.toString().trim();
      if (myanmarOdd == null || myanmarOdd.isEmpty) {
        continue;
      }

      final selection = keepSelection
          ? (raw['selection']?.toString().trim() ?? '')
          : '';

      items.add({
        'selection': selection,
        'odd': myanmarOdd,
      });
    }

    return items;
  }

  Widget _buildMarketContent(String title, List<Map<String, String>> items) {
    if (title == _myanmarBodyTitle) {
      return _MyanmarOddsOnlyRow(items: items);
    }
    return _OddsMarketRow(items: items);
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
    final accent = theme.colorScheme.primary;

    return Row(
      children: items.map((item) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item['selection'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white60,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item['odd'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _MyanmarOddsOnlyRow extends StatelessWidget {
  const _MyanmarOddsOnlyRow({
    required this.items,
  });

  final List<Map<String, String>> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return Row(
      children: items.map((item) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                item['odd'] ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _BookmakerHeader extends StatelessWidget {
  const _BookmakerHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Colors.white54,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
    );
  }
}

class _MarketHeading extends StatelessWidget {
  const _MarketHeading({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
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
