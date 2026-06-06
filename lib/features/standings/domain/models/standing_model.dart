class StandingInfo {
  const StandingInfo({
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
}
