class MatchInfo {
  const MatchInfo({
    this.matchId = 0,
    this.homeTeamId = 0,
    this.awayTeamId = 0,
    required this.teamA,
    required this.teamB,
    required this.score,
    required this.kickOffTime,
    required this.status,
    this.elapsed = 0,
    this.redCardsA = 0,
    this.redCardsB = 0,
    this.yellowCardsA = 0,
    this.yellowCardsB = 0,
    this.teamALogoUrl,
    this.teamBLogoUrl,
  });

  final int matchId;
  final int homeTeamId;
  final int awayTeamId;
  final String teamA;
  final String teamB;
  final String score;
  final String kickOffTime;
  final String status;
  final int elapsed;
  final int redCardsA;
  final int redCardsB;
  final int yellowCardsA;
  final int yellowCardsB;
  final String? teamALogoUrl;
  final String? teamBLogoUrl;

  factory MatchInfo.fromJson(Map<String, dynamic> json) {
    final homeScore = _parseInt(json['home_score'] ?? json['homeScore'] ?? json['home'] ?? 0);
    final awayScore = _parseInt(json['away_score'] ?? json['awayScore'] ?? json['away'] ?? 0);
    final scoreValue = json['score'] as String? ?? json['result'] as String? ?? '$homeScore - $awayScore';

    return MatchInfo(
      matchId: _parseId(json['match_id'] ?? json['matchId'] ?? json['id']),
      homeTeamId: _parseId(json['home_team_id'] ?? json['homeTeamId'] ?? json['team1_id'] ?? json['teamAId']),
      awayTeamId: _parseId(json['away_team_id'] ?? json['awayTeamId'] ?? json['team2_id'] ?? json['teamBId']),
      teamA: json['teamA'] as String? ?? json['homeTeam'] as String? ?? json['home_team'] as String? ?? '',
      teamB: json['teamB'] as String? ?? json['awayTeam'] as String? ?? json['away_team'] as String? ?? '',
      score: scoreValue,
      kickOffTime: json['kickOffTime'] as String? ?? json['time'] as String? ?? json['match_time'] as String? ?? '',
      status: json['status'] as String? ?? json['matchStatus'] as String? ?? 'UPCOMING',
      elapsed: json['elapsed'] as int? ?? int.tryParse(json['elapsed']?.toString() ?? '') ?? 0,
      redCardsA: json['redCardsA'] as int? ?? 0,
      redCardsB: json['redCardsB'] as int? ?? 0,
      yellowCardsA: json['yellowCardsA'] as int? ?? 0,
      yellowCardsB: json['yellowCardsB'] as int? ?? 0,
      teamALogoUrl: json['teamALogoUrl'] as String? ?? json['home_team_logo'] as String? ?? json['homeLogo'] as String?,
      teamBLogoUrl: json['teamBLogoUrl'] as String? ?? json['away_team_logo'] as String? ?? json['awayLogo'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'matchId': matchId,
      'homeTeamId': homeTeamId,
      'awayTeamId': awayTeamId,
      'teamA': teamA,
      'teamB': teamB,
      'score': score,
      'kickOffTime': kickOffTime,
      'status': status,
      'elapsed': elapsed,
      'redCardsA': redCardsA,
      'redCardsB': redCardsB,
      'yellowCardsA': yellowCardsA,
      'yellowCardsB': yellowCardsB,
      'teamALogoUrl': teamALogoUrl,
      'teamBLogoUrl': teamBLogoUrl,
    };
  }

  static const Set<String> _finishedStatuses = {
    'PEN',
    'FT',
    'AET',
    'FT_PEN',
    'CANC',
    'PST',
    'ABD',
    'SUSP',
    'INT',
    'AWD',
    'WO',
  };

  static const Map<String, String> _statusLabels = {
    'AET': 'FT',
    'FT_PEN': 'PEN',
    'CANC': 'Cancelled',
    'PST': 'Postponed',
    'ABD': 'Abandoned',
    'SUSP': 'Suspended',
    'INT': 'Interrupted',
  };

  static bool isFinishedStatus(String status) {
    return _finishedStatuses.contains(status.toUpperCase().trim());
  }

  static bool isLiveStatus(String status) {
    final normalizedStatus = status.toUpperCase().trim();

    if (normalizedStatus.isEmpty || isFinishedStatus(normalizedStatus)) {
      return false;
    }

    return normalizedStatus.startsWith('1H') ||
        normalizedStatus.startsWith('HT') ||
        normalizedStatus.startsWith('2H') ||
        normalizedStatus.startsWith('ET') ||
        normalizedStatus.startsWith('BT') ||
        normalizedStatus == 'P';
  }

  static String displayStatus(String status, {int elapsed = 0}) {
    final normalizedStatus = status.toUpperCase().trim();

    if (isFinishedStatus(normalizedStatus)) {
      return _statusLabels[normalizedStatus] ?? normalizedStatus;
    }

    if (isLiveStatus(normalizedStatus)) {
      return elapsed > 0 ? '$elapsed\'' : normalizedStatus;
    }

    return '';
  }

  static int _parseId(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
