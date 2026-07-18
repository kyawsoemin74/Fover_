class TeamSquadInfo {
  const TeamSquadInfo({
    required this.teamId,
    required this.teamName,
    this.players = const [],
  });

  final int teamId;
  final String teamName;
  final List<TeamSquadPlayer> players;

  factory TeamSquadInfo.fromJson(Map<String, dynamic> json) {
    final rawPlayers = json['players'];
    final players = <TeamSquadPlayer>[];
    if (rawPlayers is List) {
      players.addAll(
        rawPlayers.whereType<Map<String, dynamic>>().map(TeamSquadPlayer.fromJson).toList(),
      );
    }

    return TeamSquadInfo(
      teamId: json['team_id'] as int? ?? int.tryParse(json['team_id']?.toString() ?? '') ?? 0,
      teamName: json['team_name']?.toString() ?? '',
      players: players,
    );
  }
}

class TeamSquadPlayer {
  const TeamSquadPlayer({
    required this.playerId,
    required this.playerName,
    this.age,
    this.nationality,
    this.position,
    this.photo,
  });

  final int? playerId;
  final String playerName;
  final int? age;
  final String? nationality;
  final String? position;
  final String? photo;

  factory TeamSquadPlayer.fromJson(Map<String, dynamic> json) {
    return TeamSquadPlayer(
      playerId: json['player_id'] as int? ?? int.tryParse(json['player_id']?.toString() ?? ''),
      playerName: json['player_name']?.toString() ?? '',
      age: json['age'] as int? ?? int.tryParse(json['age']?.toString() ?? ''),
      nationality: json['nationality']?.toString(),
      position: json['position']?.toString(),
      photo: json['photo']?.toString(),
    );
  }
}
