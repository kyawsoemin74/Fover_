class MatchDetailInfo {
  const MatchDetailInfo({
    required this.matchId,
    required this.leagueId,
    required this.season,
    required this.leagueName,
    required this.leagueLogo,
    required this.countryName,
    required this.countryLogo,
    required this.matchTime,
    required this.status,
    required this.elapsed,
    required this.homeTeam,
    required this.homeTeamId,
    required this.homeTeamLogo,
    required this.awayTeam,
    required this.awayTeamId,
    required this.awayTeamLogo,
    required this.homeScore,
    required this.awayScore,
    this.venueName,
    this.venueCity,
    this.createdAt,
    this.updatedAt,
  });

  final int matchId;
  final int leagueId;
  final String season;
  final String leagueName;
  final String leagueLogo;
  final String countryName;
  final String countryLogo;
  final String matchTime;
  final String status;
  final int elapsed;
  final String homeTeam;
  final int homeTeamId;
  final String homeTeamLogo;
  final String awayTeam;
  final int awayTeamId;
  final String awayTeamLogo;
  final int homeScore;
  final int awayScore;
  final String? venueName;
  final String? venueCity;
  final String? createdAt;
  final String? updatedAt;
}
