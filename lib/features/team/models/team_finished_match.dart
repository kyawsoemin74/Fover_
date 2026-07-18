class TeamFinishedMatch {
  const TeamFinishedMatch({
    this.matchId,
    this.homeTeamId,
    this.awayTeamId,
    this.homeTeamName,
    this.awayTeamName,
    this.homeTeamLogo,
    this.awayTeamLogo,
    this.homeScore,
    this.awayScore,
    this.status,
    this.date,
    this.kickOffTime,
    this.competitionName,
    this.venueName,
    this.result,
  });

  final int? matchId;
  final int? homeTeamId;
  final int? awayTeamId;
  final String? homeTeamName;
  final String? awayTeamName;
  final String? homeTeamLogo;
  final String? awayTeamLogo;
  final int? homeScore;
  final int? awayScore;
  final String? status;
  final String? date;
  final String? kickOffTime;
  final String? competitionName;
  final String? venueName;
  final String? result;

  factory TeamFinishedMatch.fromJson(Map<String, dynamic> json) {
    return TeamFinishedMatch(
      matchId: _parseInt(json['match_id'] ?? json['matchId'] ?? json['id']),
      homeTeamId: _parseInt(json['home_team_id'] ?? json['homeTeamId'] ?? json['team_home_id'] ?? json['teamAId']),
      awayTeamId: _parseInt(json['away_team_id'] ?? json['awayTeamId'] ?? json['team_away_id'] ?? json['teamBId']),
      homeTeamName: _parseString(json['home_team_name'] ?? json['homeTeamName'] ?? json['home_team'] ?? json['homeTeam'] ?? json['team_a_name'] ?? json['teamA']),
      awayTeamName: _parseString(json['away_team_name'] ?? json['awayTeamName'] ?? json['away_team'] ?? json['awayTeam'] ?? json['team_b_name'] ?? json['teamB']),
      homeTeamLogo: _parseString(json['home_team_logo'] ?? json['homeTeamLogo'] ?? json['home_logo'] ?? json['homeLogo']),
      awayTeamLogo: _parseString(json['away_team_logo'] ?? json['awayTeamLogo'] ?? json['away_logo'] ?? json['awayLogo']),
      homeScore: _parseInt(json['home_score'] ?? json['homeScore'] ?? json['home']),
      awayScore: _parseInt(json['away_score'] ?? json['awayScore'] ?? json['away']),
      status: _parseString(json['status'] ?? json['match_status'] ?? json['result'] ?? json['matchStatus']),
      date: _parseString(json['date'] ?? json['match_date'] ?? json['scheduled_at'] ?? json['datetime']),
      kickOffTime: _parseString(json['kick_off_time'] ?? json['kickOffTime'] ?? json['time'] ?? json['match_time']),
      competitionName: _parseString(json['competition_name'] ?? json['competition'] ?? json['league_name'] ?? json['league']),
      venueName: _parseString(json['venue_name'] ?? json['venue'] ?? json['stadium']),
      result: _parseString(json['result'] ?? json['score'] ?? json['full_time_result']),
    );
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static String? _parseString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    return value.toString();
  }
}
