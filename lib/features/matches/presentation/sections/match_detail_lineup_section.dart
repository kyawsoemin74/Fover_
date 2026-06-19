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
            ref.read(matchLineupProvider(matchId).notifier).loadLineup(forceRefresh: true),
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
        _LineupPitchBoard(
          homeTeamName: lineup.home.teamName,
          homeFormation: lineup.home.formation,
          homePlayers: lineup.home.startingXI,
          awayTeamName: lineup.away.teamName,
          awayFormation: lineup.away.formation,
          awayPlayers: lineup.away.startingXI,
        ),
        const SizedBox(height: 14),
        const _SectionHeading(title: 'Coach'),
        const SizedBox(height: 8),
        _CoachComparisonRow(
          homeTeamName: lineup.home.teamName,
          homeCoachName: lineup.home.coach,
          homeCoachPhotoUrl: lineup.home.coachPhotoUrl,
          awayTeamName: lineup.away.teamName,
          awayCoachName: lineup.away.coach,
          awayCoachPhotoUrl: lineup.away.coachPhotoUrl,
        ),
        const SizedBox(height: 18),
        const _SectionHeading(title: 'Bench'),
        const SizedBox(height: 8),
        _BenchComparisonList(
          homePlayers: lineup.home.substitutes,
          awayPlayers: lineup.away.substitutes,
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
        final isCaptain = player.isCaptain == true;
        return _PlayerCard(
          name: name,
          number: number,
          photoUrl: photoUrl,
          isCaptain: isCaptain,
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
        final isCaptain = player.isCaptain == true;
        return _PlayerCard(
          name: name,
          number: number,
          photoUrl: photoUrl,
          isCaptain: isCaptain,
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
          const SizedBox(height: 10),
          Text(
            awayFormation.isNotEmpty ? awayFormation : 'TBD',
            textAlign: TextAlign.right,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white54,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            awayTeamName,
            textAlign: TextAlign.right,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
  const _PlayerName({required this.name, this.isCaptain = false});

  final String name;
  final bool isCaptain;

  @override
  Widget build(BuildContext context) {
    final formatted = formatPlayerName(name);
    final label = isCaptain ? '(C) $formatted' : formatted;

    return Text(
      label,
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
    this.isCaptain = false,
  });

  final String name;
  final String? number;
  final String? photoUrl;
  final bool isCaptain;

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
        _PlayerName(name: name, isCaptain: isCaptain),
      ],
    );
  }
}

class _CoachComparisonRow extends StatelessWidget {
  const _CoachComparisonRow({
    required this.homeTeamName,
    required this.homeCoachName,
    required this.homeCoachPhotoUrl,
    required this.awayTeamName,
    required this.awayCoachName,
    required this.awayCoachPhotoUrl,
  });

  final String homeTeamName;
  final String homeCoachName;
  final String? homeCoachPhotoUrl;
  final String awayTeamName;
  final String awayCoachName;
  final String? awayCoachPhotoUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _CoachCompactSide(
              teamName: homeTeamName,
              coachName: homeCoachName,
              photoUrl: homeCoachPhotoUrl,
              textAlign: TextAlign.left,
              isHome: true,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _CoachCompactSide(
              teamName: awayTeamName,
              coachName: awayCoachName,
              photoUrl: awayCoachPhotoUrl,
              textAlign: TextAlign.right,
              isHome: false,
            ),
          ),
        ],
      ),
    );
  }
}

class _CoachCompactSide extends StatelessWidget {
  const _CoachCompactSide({
    required this.teamName,
    required this.coachName,
    required this.photoUrl,
    required this.textAlign,
    required this.isHome,
  });

  final String teamName;
  final String coachName;
  final String? photoUrl;
  final TextAlign textAlign;
  final bool isHome;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = coachName.isNotEmpty ? coachName : '-';

    final identity = Expanded(
      child: Column(
        crossAxisAlignment: isHome ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: textAlign,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            teamName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: textAlign,
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    final avatar = CircleAvatar(
      radius: 18,
      backgroundColor: const Color(0xFF0F172A),
      backgroundImage: photoUrl?.isNotEmpty == true ? NetworkImage(photoUrl!) : null,
      child: photoUrl?.isNotEmpty == true
          ? null
          : const Icon(Icons.person, color: Colors.white70, size: 16),
    );

    return Row(
      children: [
        if (isHome) avatar,
        if (isHome) const SizedBox(width: 8),
        identity,
        if (!isHome) const SizedBox(width: 8),
        if (!isHome) avatar,
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

class _BenchComparisonList extends StatelessWidget {
  const _BenchComparisonList({
    required this.homePlayers,
    required this.awayPlayers,
  });

  final List<dynamic> homePlayers;
  final List<dynamic> awayPlayers;

  @override
  Widget build(BuildContext context) {
    final maxRows = homePlayers.length > awayPlayers.length
        ? homePlayers.length
        : awayPlayers.length;

    if (maxRows == 0) {
      return const _SectionPlaceholder(message: 'No bench data available.');
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: List.generate(maxRows, (index) {
          final homePlayer = index < homePlayers.length ? homePlayers[index] : null;
          final awayPlayer = index < awayPlayers.length ? awayPlayers[index] : null;

          return Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              border: index == maxRows - 1
                  ? null
                  : const Border(
                      bottom: BorderSide(color: Colors.white12, width: 0.6),
                    ),
            ),
            child: Row(
              children: [
                Expanded(child: _BenchSide(player: homePlayer, isHome: true)),
                const SizedBox(width: 10),
                Expanded(child: _BenchSide(player: awayPlayer, isHome: false)),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _BenchSide extends StatelessWidget {
  const _BenchSide({required this.player, required this.isHome});

  final dynamic player;
  final bool isHome;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textAlign = isHome ? TextAlign.left : TextAlign.right;
    final rowAlign = isHome ? CrossAxisAlignment.start : CrossAxisAlignment.end;

    final name = player?.name as String? ?? '-';
    final number = player?.number?.toString();
    final position = _toCompactPosition(player?.position as String? ?? '');
    final isCaptain = player?.isCaptain == true;
    final photoUrl = player?.photoUrl as String?;
    final displayName = isCaptain ? '(C) ${formatPlayerName(name)}' : formatPlayerName(name);
    final meta = '#${number?.trim().isNotEmpty == true ? number!.trim() : '-'} • $position';

    final identity = Expanded(
      child: Column(
        crossAxisAlignment: rowAlign,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: textAlign,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            meta,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: textAlign,
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    final avatar = CircleAvatar(
      radius: 16,
      backgroundColor: const Color(0xFF0F172A),
      backgroundImage: photoUrl?.isNotEmpty == true ? NetworkImage(photoUrl!) : null,
      child: photoUrl?.isNotEmpty == true
          ? null
          : const Icon(Icons.person, color: Colors.white70, size: 14),
    );

    return Row(
      children: [
        if (isHome) avatar,
        if (isHome) const SizedBox(width: 8),
        identity,
        if (!isHome) const SizedBox(width: 8),
        if (!isHome) avatar,
      ],
    );
  }
}

String _toCompactPosition(String rawPosition) {
  final value = rawPosition.trim().toUpperCase();
  if (value.isEmpty) return '-';

  if (value == 'G' || value == 'GK' || value.contains('GOALKEEPER')) return 'GK';
  if (value == 'D' || value == 'DF' || value == 'DEF' || value.contains('DEF')) return 'DF';
  if (value == 'M' || value == 'MF' || value == 'MID' || value.contains('MID')) return 'MF';
  if (value == 'F' || value == 'FW' || value == 'ST' || value.contains('FOR')) return 'FW';

  return value.length > 3 ? value.substring(0, 3) : value;
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
