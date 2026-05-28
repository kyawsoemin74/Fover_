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
      startingXI: _parsePlayers(json['starting_xi'] ?? json['starting_xi'] ?? json['lineup'] ?? json['starting_lineup']),
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
  });

  final int? playerId;
  final String name;
  final int? number;
  final String position;
  final bool isCaptain;
  final String? photoUrl;

  factory MatchLineupPlayer.fromJson(Map<String, dynamic> json) {
    return MatchLineupPlayer(
      playerId: _toInt(json['player_id'] ?? json['id']),
      name: (json['player'] ?? json['player_name'] ?? json['name'] ?? '')?.toString() ?? '',
      number: _toInt(json['number'] ?? json['jersey'] ?? json['shirt_number']),
      position: (json['position'] ?? json['role'] ?? '')?.toString() ?? '',
      isCaptain: (json['captain'] ?? json['is_captain'] ?? false) == true,
      photoUrl: (json['photo'] ?? json['photo_url'] ?? json['image'])?.toString(),
    );
  }

  const MatchLineupPlayer.empty()
      : playerId = null,
        name = '',
        number = null,
        position = '',
        isCaptain = false,
        photoUrl = null;

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}
