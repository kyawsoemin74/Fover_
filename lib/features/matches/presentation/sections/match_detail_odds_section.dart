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

    final market = _extractMarket(odds);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionHeading(title: 'Live Odds'),
        const SizedBox(height: 16),
        ...market.entries.map(
          (entry) => _MarketCard(label: entry.key, value: entry.value),
        ),
      ],
    );
  }

  Map<String, String> _extractMarket(List<dynamic> oddsList) {
    final market = <String, String>{};
    for (final raw in oddsList) {
      if (raw is Map<String, dynamic>) {
        final key =
            raw['name']?.toString() ?? raw['market']?.toString() ?? 'Market';
        final home =
            raw['home']?.toString() ??
            raw['back_home']?.toString() ??
            raw['odds_home']?.toString();
        final draw =
            raw['draw']?.toString() ??
            raw['back_draw']?.toString() ??
            raw['odds_draw']?.toString();
        final away =
            raw['away']?.toString() ??
            raw['back_away']?.toString() ??
            raw['odds_away']?.toString();
        if (home != null && away != null) {
          market[key] = 'H: $home · D: ${draw ?? '-'} · A: $away';
          if (market.length == 3) break;
        }
      }
    }
    if (market.isEmpty) {
      market['Match Odds'] = 'Unavailable';
    }
    return market;
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

class _MarketCard extends StatelessWidget {
  const _MarketCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF111827), Color(0xFF0B1124)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white12),
        boxShadow: [
          const BoxShadow(
            color: Color.fromRGBO(68, 138, 255, 0.1),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(68, 138, 255, 0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.show_chart,
                  color: Colors.blueAccent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'Top',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.blue[100],
                ),
          ),
        ],
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
