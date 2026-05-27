import 'package:fover/features/home/domain/models/match_model.dart';

class MatchResponseModel {
  MatchResponseModel({
    required this.teamA,
    required this.teamB,
    required this.score,
    required this.kickOffTime,
    required this.status,
    this.redCardsA = 0,
    this.redCardsB = 0,
    this.yellowCardsA = 0,
    this.yellowCardsB = 0,
  });

  final String teamA;
  final String teamB;
  final String score;
  final String kickOffTime;
  final String status;
  final int redCardsA;
  final int redCardsB;
  final int yellowCardsA;
  final int yellowCardsB;

  factory MatchResponseModel.fromJson(Map<String, dynamic> json) {
    return MatchResponseModel(
      teamA: json['teamA'] as String? ?? json['homeTeam'] as String? ?? '',
      teamB: json['teamB'] as String? ?? json['awayTeam'] as String? ?? '',
      score: json['score'] as String? ?? json['result'] as String? ?? '0 - 0',
      kickOffTime: json['kickOffTime'] as String? ?? json['time'] as String? ?? '',
      status: json['status'] as String? ?? json['matchStatus'] as String? ?? 'UPCOMING',
      redCardsA: json['redCardsA'] as int? ?? 0,
      redCardsB: json['redCardsB'] as int? ?? 0,
      yellowCardsA: json['yellowCardsA'] as int? ?? 0,
      yellowCardsB: json['yellowCardsB'] as int? ?? 0,
    );
  }

  MatchInfo toDomain() {
    return MatchInfo(
      teamA: teamA,
      teamB: teamB,
      score: score,
      kickOffTime: kickOffTime,
      status: status,
      redCardsA: redCardsA,
      redCardsB: redCardsB,
      yellowCardsA: yellowCardsA,
      yellowCardsB: yellowCardsB,
    );
  }
}
