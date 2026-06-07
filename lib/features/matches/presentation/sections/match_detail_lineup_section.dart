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
        const _SectionHeading(title: 'Lineups & Formations'),
        const SizedBox(height: 12),
        _LineupPitchBoard(
          homeTeamName: lineup.home.teamName,
          homeFormation: lineup.home.formation,
          homePlayers: lineup.home.startingXI,
          awayTeamName: lineup.away.teamName,
          awayFormation: lineup.away.formation,
          awayPlayers: lineup.away.startingXI,
        ),
        const SizedBox(height: 18),
        const _SectionHeading(title: 'Substitutes lineup'),
        const SizedBox(height: 10),
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

class _LineupPitchBoard extends StatelessWidget {
  const _LineupPitchBoard({
    required this.homeTeamName,
    required this.homeFormation,
    required this.homePlayers,
    required this.awayTeamName,
    required this.awayFormation,
    required this.awayPlayers,
  });

  final String homeTeamName;
  final String homeFormation;
  final List<dynamic> homePlayers;
  final String awayTeamName;
  final String awayFormation;
  final List<dynamic> awayPlayers;

  List<List<dynamic>> _tiers(String formation, List<dynamic> players, {bool reverse = false}) {
    final parts = formation.split('-').map((part) => int.tryParse(part.trim())).whereType<int>().toList();
    if (players.isEmpty || parts.isEmpty) {
      return [players];
    }

    final totalPlayers = players.length;
    final sumParts = parts.fold<int>(0, (sum, part) => sum + part);
    final rowCounts = <int>[];

    if (sumParts == totalPlayers) {
      rowCounts.addAll(parts);
    } else if (sumParts + 1 == totalPlayers) {
      rowCounts.add(1);
      rowCounts.addAll(parts);
    } else {
      return [players];
    }

    final tiers = <List<dynamic>>[];
    var index = 0;
    for (final count in rowCounts.reversed) {
      final end = (index + count).clamp(0, players.length);
      tiers.add(players.sublist(index, end));
      index = end;
    }
    return reverse ? tiers : tiers.reversed.toList();
  }

  List<Widget> _buildPlayers(List<dynamic> players, String formation, {bool reverse = false}) {
    final gridRows = _buildGridRows(players, reverse: reverse);
    if (gridRows.isNotEmpty) {
      return gridRows;
    }

    final tiers = _tiers(formation, players, reverse: reverse);
    return _buildRows(tiers);
  }

  List<Widget> _buildRows(List<List<dynamic>> rows) {
    return rows.map((group) {
      final players = group.map((player) {
        final name = player.name as String? ?? '';
        final number = player.number?.toString();
        final photoUrl = player.photoUrl as String?;
        return _PlayerCard(
          name: name,
          number: number,
          photoUrl: photoUrl,
        );
      }).toList();

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: group.length == 1 ? MainAxisAlignment.center : MainAxisAlignment.spaceEvenly,
          children: _buildFormationRowChildren(players),
        ),
      );
    }).toList();
  }

  List<Widget> _buildFormationRowChildren(List<Widget> players) {
    if (players.length == 1) {
      return players;
    }

    return players.map((player) {
      return Expanded(
        child: Align(
          alignment: Alignment.center,
          child: player,
        ),
      );
    }).toList();
  }

  List<Widget> _buildGridRows(List<dynamic> players, {bool reverse = false}) {
    final rowMap = <int, Map<int, dynamic>>{};
    var maxColumns = 0;
    var placed = 0;
    var minRow = double.maxFinite.toInt();
    var maxRow = 0;

    for (final player in players) {
      final gridString = (player.grid as String?) ?? '';
      final coords = _parseGrid(gridString);
      if (coords == null) continue;

      final row = coords[0];
      final col = coords[1];
      rowMap.putIfAbsent(row, () => {})[col] = player;
      maxColumns = maxColumns < col ? col : maxColumns;
      placed += 1;
      minRow = minRow < row ? minRow : row;
      maxRow = maxRow > row ? maxRow : row;
    }

    final coverage = players.isNotEmpty ? placed / players.length : 0.0;
    if (coverage < 0.8 || rowMap.isEmpty) {
      return const [];
    }

    final adjustedRowMap = <int, Map<int, dynamic>>{};
    if (reverse && minRow <= maxRow) {
      final offset = minRow + maxRow;
      for (final entry in rowMap.entries) {
        final invertedRow = offset - entry.key;
        adjustedRowMap[invertedRow] = entry.value;
      }
    } else {
      adjustedRowMap.addAll(rowMap);
    }

    final sortedRows = adjustedRowMap.keys.toList()..sort();
    return sortedRows.map((row) {
      final columns = adjustedRowMap[row]!;
      final rowPlayers = columns.entries
          .toList()
          ..sort((a, b) => a.key.compareTo(b.key));

      final playersInRow = rowPlayers.map((entry) {
        final player = entry.value;
        final name = player.name as String? ?? '';
        final number = player.number?.toString();
        final photoUrl = player.photoUrl as String?;
        return _PlayerCard(
          name: name,
          number: number,
          photoUrl: photoUrl,
        );
      }).toList();

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: playersInRow.length == 1
              ? MainAxisAlignment.center
              : MainAxisAlignment.spaceEvenly,
          children: _buildFormationRowChildren(playersInRow),
        ),
      );
    }).toList();
  }

  List<int>? _parseGrid(String? grid) {
    if (grid == null || grid.isEmpty) {
      return null;
    }
    final parts = grid.split(':').map((part) => int.tryParse(part.trim())).whereType<int>().toList();
    if (parts.length != 2) {
      return null;
    }
    return parts;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      homeTeamName,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      homeFormation.isNotEmpty ? homeFormation : 'TBD',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      awayTeamName,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      awayFormation.isNotEmpty ? awayFormation : 'TBD',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0D271A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _PitchPainter(),
                  ),
                ),
                Column(
                  children: [
                    ..._buildPlayers(homePlayers, homeFormation),
                    const SizedBox(height: 8),
                    Container(height: 1, color: Colors.white12),
                    const SizedBox(height: 8),
                    ..._buildPlayers(awayPlayers, awayFormation, reverse: true),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String formatPlayerName(String name) {
  if (name.isEmpty) return '-';
  final parts = name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
  if (parts.length <= 1) return name;
  final firstInitial = parts.first[0].toUpperCase();
  final lastName = parts.last;
  return '$firstInitial. $lastName';
}

class _PlayerAvatar extends StatelessWidget {
  const _PlayerAvatar({
    required this.photoUrl,
  });

  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: const Color(0xFF0F172A),
      backgroundImage: photoUrl?.isNotEmpty == true ? NetworkImage(photoUrl!) : null,
    );
  }
}

class _PlayerName extends StatelessWidget {
  const _PlayerName({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Text(
      formatPlayerName(name),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _PlayerCard extends StatelessWidget {
  const _PlayerCard({
    required this.name,
    this.number,
    this.photoUrl,
  });

  final String name;
  final String? number;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final hasNumber = number?.isNotEmpty == true;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PlayerAvatar(photoUrl: photoUrl),
        if (hasNumber) ...[
          const SizedBox(height: 6),
          Text(
            number!.trim(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
          ),
        ],
        const SizedBox(height: 4),
        _PlayerName(name: name),
      ],
    );
  }
}

class _PitchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final rect = Offset.zero & size;
    canvas.drawRect(rect, paint);

    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height), paint);
    canvas.drawCircle(center, size.width * 0.08, paint);

    final boxWidth = size.width * 0.24;
    final boxHeight = size.height * 0.16;
    final left = (size.width - boxWidth) / 2;
    canvas.drawRect(Rect.fromLTWH(left, 0, boxWidth, boxHeight), paint);
    canvas.drawRect(Rect.fromLTWH(left, size.height - boxHeight, boxWidth, boxHeight), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: players.map((player) {
              final name = player.name as String? ?? '';
              final number = player.number?.toString();
              final photoUrl = player.photoUrl as String?;
              return SizedBox(
                width: 120,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1F2E),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: _PlayerCard(
                    name: name,
                    number: number,
                    photoUrl: photoUrl,
                  ),
                ),
              );
            }).toList(),
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
