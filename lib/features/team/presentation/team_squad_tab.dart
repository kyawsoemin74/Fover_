import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fover/features/team/models/team_squad_model.dart';
import 'package:fover/features/team/providers/team_provider.dart';
import 'package:fover/features/team/providers/team_state.dart';

class TeamSquadTab extends ConsumerStatefulWidget {
  const TeamSquadTab({super.key, required this.teamId});

  final int teamId;

  @override
  ConsumerState<TeamSquadTab> createState() => _TeamSquadTabState();
}

class _TeamSquadTabState extends ConsumerState<TeamSquadTab> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(teamProvider(widget.teamId).notifier).loadSquad(widget.teamId));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teamProvider(widget.teamId));

    if (state.squadStatus == TeamSquadStatus.loading || state.squadStatus == TeamSquadStatus.initial) {
      return _buildLoadingState();
    }

    if (state.squadStatus == TeamSquadStatus.error) {
      return _buildErrorState(state.squadError);
    }

    final squad = state.squad;
    if (state.squadStatus == TeamSquadStatus.empty || squad == null || squad.players.isEmpty) {
      return _buildEmptyState();
    }

    final groupedSections = _groupPlayers(squad.players);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: groupedSections.map((section) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                section.title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              ...section.players.map((player) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _PlayerCard(player: player),
                  )),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<_PositionGroup> _groupPlayers(List<TeamSquadPlayer> players) {
    final groups = <_PositionGroup>[
      _PositionGroup(title: 'Goalkeepers', players: <TeamSquadPlayer>[]),
      _PositionGroup(title: 'Defenders', players: <TeamSquadPlayer>[]),
      _PositionGroup(title: 'Midfielders', players: <TeamSquadPlayer>[]),
      _PositionGroup(title: 'Attackers', players: <TeamSquadPlayer>[]),
    ];

    for (final player in players) {
      final section = _sectionForPlayer(player, groups);
      if (section != null) {
        section.players.add(player);
      }
    }

    return groups.where((group) => group.players.isNotEmpty).toList();
  }

  _PositionGroup? _sectionForPlayer(TeamSquadPlayer player, List<_PositionGroup> groups) {
    final normalized = (player.position ?? '').trim().toLowerCase();
    if (normalized.contains('goalkeeper') || normalized.contains('gk') || normalized.contains('keeper')) {
      return groups.whereType<_PositionGroup>().firstWhere((group) => group.title == 'Goalkeepers');
    }
    if (normalized.contains('defender') || normalized.contains('back') || normalized.contains('lb') || normalized.contains('rb') || normalized.contains('cb')) {
      return groups.whereType<_PositionGroup>().firstWhere((group) => group.title == 'Defenders');
    }
    if (normalized.contains('midfielder') || normalized.contains('mid') || normalized.contains('cm') || normalized.contains('lm') || normalized.contains('rm') || normalized.contains('dm') || normalized.contains('am')) {
      return groups.whereType<_PositionGroup>().firstWhere((group) => group.title == 'Midfielders');
    }
    if (normalized.contains('attacker') || normalized.contains('forward') || normalized.contains('striker') || normalized.contains('fw') || normalized.contains('st') || normalized.contains('lw') || normalized.contains('rw') || normalized.contains('cf')) {
      return groups.whereType<_PositionGroup>().firstWhere((group) => group.title == 'Attackers');
    }
    return null;
  }

  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1220),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1220),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(
        'No squad players found.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.white60,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildErrorState(String? message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1220),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Unable to load squad',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          if (message != null && message.trim().isNotEmpty)
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white60,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}

class _PositionGroup {
  _PositionGroup({required this.title, required this.players});

  final String title;
  final List<TeamSquadPlayer> players;
}

class _PlayerCard extends StatelessWidget {
  const _PlayerCard({required this.player});

  final TeamSquadPlayer player;

  @override
  Widget build(BuildContext context) {
    final photoUrl = player.photo?.trim() ?? '';
    final position = player.position?.trim().isNotEmpty == true ? player.position!.trim() : '–';
    final ageLabel = player.age != null ? player.age.toString() : '–';

    return Card(
      margin: EdgeInsets.zero,
      color: const Color(0xFF0E1220),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.white12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            ClipOval(
              child: Container(
                width: 42,
                height: 42,
                color: const Color(0xFF050B1A),
                child: photoUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: photoUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white24),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.person_outline,
                          color: Colors.white70,
                          size: 24,
                        ),
                      )
                    : const Icon(
                        Icons.person_outline,
                        color: Colors.white70,
                        size: 24,
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.playerName.isEmpty ? 'Unknown player' : player.playerName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    position,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white60,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$ageLabel yrs',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
