import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fover/features/matches/providers/match_lineup_provider.dart';

class MatchDetailLineupSection extends ConsumerWidget {
  const MatchDetailLineupSection({super.key, required this.matchId});

  final int matchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(matchLineupProvider(matchId));
    if (state.status == MatchLineupStatus.loading ||
        state.status == MatchLineupStatus.initial) {
      return const _SectionPlaceholder(
        message: 'Loading lineups and formations.',
      );
    }

    if (state.status == MatchLineupStatus.error) {
      return _SectionError(
        message: state.errorMessage,
        onRetry: () =>
            ref.read(matchLineupProvider(matchId).notifier).loadLineup(),
      );
    }

    final lineup = state.lineup;
    if (lineup == null) {
      return const _SectionPlaceholder(
        message: 'No lineup information was provided yet.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionHeading(title: 'Starting XI'),
        const SizedBox(height: 16),
        _LineupPitchCard(
          title: lineup.home.teamName,
          formation: lineup.home.formation,
          players: lineup.home.startingXI,
        ),
        const SizedBox(height: 14),
        _LineupPitchCard(
          title: lineup.away.teamName,
          formation: lineup.away.formation,
          players: lineup.away.startingXI,
          reverse: true,
        ),
        const SizedBox(height: 20),
        const _SectionHeading(title: 'Substitutes'),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _SubstituteList(
                teamName: lineup.home.teamName,
                players: lineup.home.substitutes,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SubstituteList(
                teamName: lineup.away.teamName,
                players: lineup.away.substitutes,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LineupPitchCard extends StatelessWidget {
  const _LineupPitchCard({
    required this.title,
    required this.formation,
    required this.players,
    this.reverse = false,
  });

  final String title;
  final String formation;
  final List<dynamic> players;
  final bool reverse;

  List<List<dynamic>> get _tiers {
    final parts = formation.split('-').map(int.tryParse).whereType<int>().toList();
    if (parts.length < 3 || players.isEmpty) {
      return [players];
    }
    final tiers = <List<dynamic>>[];
    var index = 0;
    for (var count in parts.reversed) {
      final end = (index + count).clamp(0, players.length);
      tiers.add(players.sublist(index, end));
      index = end;
    }
    return reverse ? tiers : tiers.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Text(
                formation.isNotEmpty ? formation : 'TBD',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white54,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0E1727),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: _tiers.map((group) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: group.map((player) {
                      final name = player.name as String? ?? '';
                      final number = player.number?.toString() ?? '';
                      return _PlayerBubble(name: name, number: number);
                    }).toList(),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerBubble extends StatelessWidget {
  const _PlayerBubble({required this.name, required this.number});

  final String name;
  final String number;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF16203A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            number,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            name.isNotEmpty ? name.split(' ').last : '-',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white60,
                ),
          ),
        ],
      ),
    );
  }
}

class _SubstituteList extends StatelessWidget {
  const _SubstituteList({required this.teamName, required this.players});

  final String teamName;
  final List<dynamic> players;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            teamName,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          ...players.map((player) {
            final name = player.name as String? ?? '';
            final number = player.number?.toString() ?? '';
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '$number ${name.isNotEmpty ? name : 'Unknown'}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white54,
                    ),
              ),
            );
          }),
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
            message ?? 'Unable to load lineup details.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white54),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Reload')),
        ],
      ),
    );
  }
}
