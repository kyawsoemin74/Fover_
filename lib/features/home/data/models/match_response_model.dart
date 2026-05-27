import 'package:intl/intl.dart';
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
    this.teamALogoUrl,
    this.teamBLogoUrl,
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
  final String? teamALogoUrl;
  final String? teamBLogoUrl;

  factory MatchResponseModel.fromJson(Map<String, dynamic> json) {
    final homeScore = _parseInt(json['home_score'] ?? json['homeScore'] ?? json['home'] ?? 0);
    final awayScore = _parseInt(json['away_score'] ?? json['awayScore'] ?? json['away'] ?? 0);
    final rawKickOff = json['match_time'] as String? ?? json['kickOffTime'] as String? ?? json['time'] as String? ?? '';
    final localTime = _formatLocalTime(rawKickOff);

    return MatchResponseModel(
      teamA: json['home_team'] as String? ?? json['teamA'] as String? ?? '',
      teamB: json['away_team'] as String? ?? json['teamB'] as String? ?? '',
      score: json['score'] as String? ?? json['result'] as String? ?? '$homeScore - $awayScore',
      kickOffTime: localTime,
      status: json['status'] as String? ?? json['matchStatus'] as String? ?? 'UPCOMING',
      redCardsA: json['redCardsA'] as int? ?? 0,
      redCardsB: json['redCardsB'] as int? ?? 0,
      yellowCardsA: json['yellowCardsA'] as int? ?? 0,
      yellowCardsB: json['yellowCardsB'] as int? ?? 0,
      teamALogoUrl: json['home_team_logo'] as String? ?? json['teamALogoUrl'] as String?,
      teamBLogoUrl: json['away_team_logo'] as String? ?? json['teamBLogoUrl'] as String?,
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
      teamALogoUrl: teamALogoUrl,
      teamBLogoUrl: teamBLogoUrl,
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static String _formatLocalTime(String rawTime) {
    try {
      final parsed = DateTime.parse(rawTime).toLocal();
      return DateFormat('HH:mm').format(parsed);
    } catch (_) {
      return rawTime;
    }
  }
}
