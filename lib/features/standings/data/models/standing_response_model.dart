import 'package:fover/features/standings/domain/models/standing_model.dart';

class StandingResponseModel {
  StandingResponseModel({
    required this.leagueId,
    required this.season,
    required this.position,
    required this.teamId,
    required this.teamName,
    this.teamLogo,
    required this.points,
    required this.played,
    required this.won,
    required this.drawn,
    required this.lost,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.goalDifference,
  });

  final int leagueId;
  final String season;
  final int position;
  final int teamId;
  final String teamName;
  final String? teamLogo;
  final int points;
  final int played;
  final int won;
  final int drawn;
  final int lost;
  final int goalsFor;
  final int goalsAgainst;
  final int goalDifference;

  factory StandingResponseModel.fromJson(Map<String, dynamic> json) {
    return StandingResponseModel(
      leagueId: _parseInt(json['league_id']),
      season: json['season']?.toString() ?? '',
      position: _parseInt(json['position']),
      teamId: _parseInt(json['team_id']),
      teamName: json['team_name']?.toString() ?? '',
      teamLogo: json['team_logo']?.toString(),
      points: _parseInt(json['points']),
      played: _parseInt(json['played']),
      won: _parseInt(json['won']),
      drawn: _parseInt(json['drawn']),
      lost: _parseInt(json['lost']),
      goalsFor: _parseInt(json['goals_for']),
      goalsAgainst: _parseInt(json['goals_against']),
      goalDifference: _parseInt(json['goal_difference']),
    );
  }

  StandingInfo toDomain() {
    return StandingInfo(
      leagueId: leagueId,
      season: season,
      position: position,
      teamId: teamId,
      teamName: teamName,
      teamLogo: teamLogo,
      points: points,
      played: played,
      won: won,
      drawn: drawn,
      lost: lost,
      goalsFor: goalsFor,
      goalsAgainst: goalsAgainst,
      goalDifference: goalDifference,
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
