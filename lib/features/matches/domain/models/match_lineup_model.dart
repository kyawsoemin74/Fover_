class MatchLineupInfo {
  const MatchLineupInfo({
    required this.home,
    required this.away,
  });

  final MatchTeamLineup home;
  final MatchTeamLineup away;

  factory MatchLineupInfo.fromJson(Map<String, dynamic> json) {
    final homeJson = json['home'] as Map<String, dynamic>? ?? json['home_team'] as Map<String, dynamic>? ?? json['team_home'] as Map<String, dynamic>? ?? {};
    final awayJson = json['away'] as Map<String, dynamic>? ?? json['away_team'] as Map<String, dynamic>? ?? json['team_away'] as Map<String, dynamic>? ?? {};

    return MatchLineupInfo(
      home: MatchTeamLineup.fromJson(homeJson),
      away: MatchTeamLineup.fromJson(awayJson),
    );
  }
}

class MatchTeamLineup {
  const MatchTeamLineup({
    required this.teamId,
    required this.teamName,
    required this.coach,
    required this.formation,
    required this.startingXI,
    required this.substitutes,
  });

  final int? teamId;
  final String teamName;
  final String coach;
  final String formation;
  final List<MatchLineupPlayer> startingXI;
  final List<MatchLineupPlayer> substitutes;

  factory MatchTeamLineup.fromJson(Map<String, dynamic> json) {
    return MatchTeamLineup(
      teamId: _toInt(json['team_id'] ?? json['id']),
      teamName: (json['team_name'] ?? json['name'] ?? '')?.toString() ?? '',
      coach: (json['coach'] ?? json['manager'] ?? '')?.toString() ?? '',
      formation: (json['formation'] ?? '')?.toString() ?? '',
      startingXI: _parsePlayers(json['startXI'] ?? json['starting_xi'] ?? json['lineup'] ?? json['starting_lineup']),
      substitutes: _parsePlayers(json['substitutes'] ?? json['subs'] ?? json['bench']),
    );
  }

  static List<MatchLineupPlayer> _parsePlayers(dynamic raw) {
    if (raw is List) {
      return raw.map((item) {
        if (item is Map<String, dynamic>) return MatchLineupPlayer.fromJson(item);
        return const MatchLineupPlayer.empty();
      }).toList();
    }
    if (raw is Map<String, dynamic>) {
      return raw.values.map((item) {
        if (item is Map<String, dynamic>) return MatchLineupPlayer.fromJson(item);
        return const MatchLineupPlayer.empty();
      }).toList();
    }
    return const [];
  }

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}

class MatchLineupPlayer {
  const MatchLineupPlayer({
    required this.playerId,
    required this.name,
    required this.number,
    required this.position,
    required this.isCaptain,
    required this.photoUrl,
    required this.grid,
  });

  final int? playerId;
  final String name;
  final int? number;
  final String position;
  final bool isCaptain;
  final String? photoUrl;
  final String? grid;

  factory MatchLineupPlayer.fromJson(Map<String, dynamic> json) {
    final player = json['player'] as Map<String, dynamic>? ?? json;
    return MatchLineupPlayer(
      playerId: _toInt(player['player_id'] ?? player['playerId'] ?? player['id']),
      name: (player['player'] ?? player['player_name'] ?? player['name'] ?? '')?.toString() ?? '',
      number: _parseJersey(player['number'] ?? player['jersey'] ?? player['shirt_number'] ?? player['shirt']),
      position: (player['pos'] ?? player['position'] ?? player['role'] ?? '')?.toString() ?? '',
      isCaptain: (player['captain'] ?? player['is_captain'] ?? false) == true,
      photoUrl: (player['photo'] ?? player['photo_url'] ?? player['image'])?.toString(),
      grid: (player['grid'] ?? player['grid_position'] ?? player['gridPosition'])?.toString(),
    );
  }

  static int? _parseJersey(dynamic value) {
    if (value is int) {
      return _isValidJersey(value) ? value : null;
    }
    if (value is String) {
      final cleaned = value.trim();
      final normalized = cleaned.startsWith('#') ? cleaned.substring(1).trim() : cleaned;
      final parsed = int.tryParse(normalized);
      return _isValidJersey(parsed) ? parsed : null;
    }
    return null;
  }

  static bool _isValidJersey(int? value) => value != null && value > 0 && value <= 99;

  const MatchLineupPlayer.empty()
      : playerId = null,
        name = '',
        number = null,
        position = '',
        isCaptain = false,
        photoUrl = null,
        grid = null;

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}
