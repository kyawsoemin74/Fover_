class MatchH2HInfo {
  const MatchH2HInfo({
    required this.homeTeamId,
    required this.awayTeamId,
    required this.homeTeamName,
    required this.awayTeamName,
    required this.homeWins,
    required this.awayWins,
    required this.draws,
    required this.totalGoalsHome,
    required this.totalGoalsAway,
    required this.meetings,
  });

  final int homeTeamId;
  final int awayTeamId;
  final String homeTeamName;
  final String awayTeamName;
  final int homeWins;
  final int awayWins;
  final int draws;
  final int totalGoalsHome;
  final int totalGoalsAway;
  final List<MatchH2HMeeting> meetings;

  bool get hasHistory => meetings.isNotEmpty;

  factory MatchH2HInfo.fromJson(Map<String, dynamic> json) {
    final meetings = _extractMeetings(json).map(MatchH2HMeeting.fromJson).toList();
    final homeWins = _intValue(json, ['home_wins', 'homeWins']) ?? _computeWins(meetings, true);
    final awayWins = _intValue(json, ['away_wins', 'awayWins']) ?? _computeWins(meetings, false);
    final draws = _intValue(json, ['draws', 'drawCount']) ?? _computeDraws(meetings);
    final totalGoalsHome = _intValue(json, ['home_goals', 'total_goals_home', 'goals_home']) ?? _computeGoals(meetings, true);
    final totalGoalsAway = _intValue(json, ['away_goals', 'total_goals_away', 'goals_away']) ?? _computeGoals(meetings, false);

    return MatchH2HInfo(
      homeTeamId: _toInt(json['home_team_id'] ?? json['team1_id'] ?? json['homeTeamId']),
      awayTeamId: _toInt(json['away_team_id'] ?? json['team2_id'] ?? json['awayTeamId']),
      homeTeamName: (json['home_team_name'] ?? json['team1_name'] ?? '')?.toString() ?? '',
      awayTeamName: (json['away_team_name'] ?? json['team2_name'] ?? '')?.toString() ?? '',
      homeWins: homeWins,
      awayWins: awayWins,
      draws: draws,
      totalGoalsHome: totalGoalsHome,
      totalGoalsAway: totalGoalsAway,
      meetings: meetings,
    );
  }

  factory MatchH2HInfo.fromApiSportsList(
    List<dynamic> rawMatches,
    int homeTeamId,
    int awayTeamId,
  ) {
    final meetings = rawMatches
        .whereType<Map<String, dynamic>>()
        .map(MatchH2HMeeting.fromApiSportsJson)
        .where((meeting) => meeting.statusShort.toUpperCase() != 'NS')
        .toList();

    final homeTeamName = _teamNameForId(meetings, homeTeamId);
    final awayTeamName = _teamNameForId(meetings, awayTeamId);
    final homeWins = _computeWinsForTeam(meetings, homeTeamId);
    final awayWins = _computeWinsForTeam(meetings, awayTeamId);
    final draws = _computeDraws(meetings);
    final totalGoalsHome = _computeGoalsForTeam(meetings, homeTeamId);
    final totalGoalsAway = _computeGoalsForTeam(meetings, awayTeamId);

    return MatchH2HInfo(
      homeTeamId: homeTeamId,
      awayTeamId: awayTeamId,
      homeTeamName: homeTeamName,
      awayTeamName: awayTeamName,
      homeWins: homeWins,
      awayWins: awayWins,
      draws: draws,
      totalGoalsHome: totalGoalsHome,
      totalGoalsAway: totalGoalsAway,
      meetings: meetings,
    );
  }

  static List<Map<String, dynamic>> _extractMeetings(Map<String, dynamic> json) {
    final raw = json['head2head'] ?? json['h2h'] ?? json['matches'] ?? json['history'];
    if (raw is List) {
      return raw.whereType<Map<String, dynamic>>().toList();
    }
    if (raw is Map<String, dynamic>) {
      return raw.values.whereType<Map<String, dynamic>>().toList();
    }
    return const [];
  }

  static String _teamNameForId(List<MatchH2HMeeting> meetings, int teamId) {
    for (final meeting in meetings) {
      if (meeting.homeTeamId == teamId) return meeting.homeTeam;
      if (meeting.awayTeamId == teamId) return meeting.awayTeam;
    }
    return '';
  }

  static int _computeWins(List<MatchH2HMeeting> meetings, bool homeSide) {
    return meetings.where((match) {
      if (match.homeScore == match.awayScore) return false;
      return homeSide ? match.homeScore > match.awayScore : match.awayScore > match.homeScore;
    }).length;
  }

  static int _computeWinsForTeam(List<MatchH2HMeeting> meetings, int teamId) {
    return meetings.where((match) {
      if (match.homeScore == match.awayScore) return false;
      final winnerId = match.homeScore > match.awayScore ? match.homeTeamId : match.awayTeamId;
      return winnerId == teamId;
    }).length;
  }

  static int _computeDraws(List<MatchH2HMeeting> meetings) {
    return meetings.where((match) => match.homeScore == match.awayScore).length;
  }

  static int _computeGoals(List<MatchH2HMeeting> meetings, bool homeSide) {
    return meetings.fold<int>(0, (sum, match) => sum + (homeSide ? match.homeScore : match.awayScore));
  }

  static int _computeGoalsForTeam(List<MatchH2HMeeting> meetings, int teamId) {
    return meetings.fold<int>(0, (sum, match) {
      if (match.homeTeamId == teamId) {
        return sum + match.homeScore;
      }
      if (match.awayTeamId == teamId) {
        return sum + match.awayScore;
      }
      return sum;
    });
  }

  static int? _intValue(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      if (json.containsKey(key)) {
        return _toInt(json[key]);
      }
    }
    return null;
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

class MatchH2HMeeting {
  const MatchH2HMeeting({
    required this.date,
    required this.homeTeamId,
    required this.awayTeamId,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeScore,
    required this.awayScore,
    required this.status,
    required this.statusShort,
    required this.venue,
    required this.result,
  });

  final DateTime date;
  final int homeTeamId;
  final int awayTeamId;
  final String homeTeam;
  final String awayTeam;
  final int homeScore;
  final int awayScore;
  final String status;
  final String statusShort;
  final String venue;
  final String result;

  factory MatchH2HMeeting.fromJson(Map<String, dynamic> json) {
    final dateString = (json['match_date'] ?? json['date'] ?? json['fixture_date'] ?? '')?.toString() ?? '';
    final date = DateTime.tryParse(dateString) ?? DateTime.fromMillisecondsSinceEpoch(0);
    final homeScore = _toInt(json['home_score'] ?? json['score_home'] ?? json['goals_home']);
    final awayScore = _toInt(json['away_score'] ?? json['score_away'] ?? json['goals_away']);
    final status = (json['status'] ?? json['match_status'] ?? '')?.toString() ?? '';
    final statusShort = (json['status_short'] ?? json['match_status_short'] ?? '')?.toString() ?? '';
    final venue = (json['venue'] ?? json['stadium'] ?? '')?.toString() ?? '';
    final result = (json['result'] ?? json['outcome'] ?? status)?.toString() ?? '';

    return MatchH2HMeeting(
      date: date,
      homeTeamId: _toInt(json['home_team_id'] ?? json['team1_id'] ?? json['homeTeamId']),
      awayTeamId: _toInt(json['away_team_id'] ?? json['team2_id'] ?? json['awayTeamId']),
      homeTeam: (json['home_team'] ?? json['team1_name'] ?? '')?.toString() ?? '',
      awayTeam: (json['away_team'] ?? json['team2_name'] ?? '')?.toString() ?? '',
      homeScore: homeScore,
      awayScore: awayScore,
      status: status,
      statusShort: statusShort,
      venue: venue,
      result: result,
    );
  }

  factory MatchH2HMeeting.fromApiSportsJson(Map<String, dynamic> json) {
    final fixture = (json['fixture'] as Map<String, dynamic>?) ?? {};
    final statusInfo = (fixture['status'] as Map<String, dynamic>?) ?? {};
    final teamInfo = (json['teams'] as Map<String, dynamic>?) ?? {};
    final homeInfo = (teamInfo['home'] as Map<String, dynamic>?) ?? {};
    final awayInfo = (teamInfo['away'] as Map<String, dynamic>?) ?? {};
    final goals = (json['goals'] as Map<String, dynamic>?) ?? {};

    final dateString = (fixture['date'] ?? '')?.toString() ?? '';
    final date = DateTime.tryParse(dateString) ?? DateTime.fromMillisecondsSinceEpoch(0);
    final homeScore = _toInt(goals['home']);
    final awayScore = _toInt(goals['away']);
    final homeTeamId = _toInt(homeInfo['id']);
    final awayTeamId = _toInt(awayInfo['id']);
    final homeTeamName = (homeInfo['name'] ?? homeInfo['teamName'] ?? '')?.toString() ?? '';
    final awayTeamName = (awayInfo['name'] ?? awayInfo['teamName'] ?? '')?.toString() ?? '';
    final statusShort = (statusInfo['short'] ?? '')?.toString() ?? '';
    final statusLong = (statusInfo['long'] ?? '')?.toString() ?? '';
    final venue = (fixture['venue'] as Map<String, dynamic>?)?['name']?.toString() ?? '';
    final result = statusLong.isNotEmpty ? statusLong : statusShort;

    return MatchH2HMeeting(
      date: date,
      homeTeamId: homeTeamId,
      awayTeamId: awayTeamId,
      homeTeam: homeTeamName,
      awayTeam: awayTeamName,
      homeScore: homeScore,
      awayScore: awayScore,
      status: result,
      statusShort: statusShort,
      venue: venue,
      result: result,
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
