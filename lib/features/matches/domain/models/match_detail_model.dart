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
    this.hasEvents = false,
    this.hasStats = false,
    this.hasLineups = false,
    this.hasOdds = false,
    this.hasH2H = false,
    this.hasStandings = false,
    this.isKnockout = false,
    this.hasBracket = false,
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
  final bool hasEvents;
  final bool hasStats;
  final bool hasLineups;
  final bool hasOdds;
  final bool hasH2H;
  final bool hasStandings;
  final bool isKnockout;
  final bool hasBracket;
  final String? venueName;
  final String? venueCity;
  final String? createdAt;
  final String? updatedAt;

  MatchDetailInfo copyWith({
    int? matchId,
    int? leagueId,
    String? season,
    String? leagueName,
    String? leagueLogo,
    String? countryName,
    String? countryLogo,
    String? matchTime,
    String? status,
    int? elapsed,
    String? homeTeam,
    int? homeTeamId,
    String? homeTeamLogo,
    String? awayTeam,
    int? awayTeamId,
    String? awayTeamLogo,
    int? homeScore,
    int? awayScore,
    bool? hasEvents,
    bool? hasStats,
    bool? hasLineups,
    bool? hasOdds,
    bool? hasH2H,
    bool? hasStandings,
    bool? isKnockout,
    bool? hasBracket,
    String? venueName,
    String? venueCity,
    String? createdAt,
    String? updatedAt,
  }) {
    return MatchDetailInfo(
      matchId: matchId ?? this.matchId,
      leagueId: leagueId ?? this.leagueId,
      season: season ?? this.season,
      leagueName: leagueName ?? this.leagueName,
      leagueLogo: leagueLogo ?? this.leagueLogo,
      countryName: countryName ?? this.countryName,
      countryLogo: countryLogo ?? this.countryLogo,
      matchTime: matchTime ?? this.matchTime,
      status: status ?? this.status,
      elapsed: elapsed ?? this.elapsed,
      homeTeam: homeTeam ?? this.homeTeam,
      homeTeamId: homeTeamId ?? this.homeTeamId,
      homeTeamLogo: homeTeamLogo ?? this.homeTeamLogo,
      awayTeam: awayTeam ?? this.awayTeam,
      awayTeamId: awayTeamId ?? this.awayTeamId,
      awayTeamLogo: awayTeamLogo ?? this.awayTeamLogo,
      homeScore: homeScore ?? this.homeScore,
      awayScore: awayScore ?? this.awayScore,
      hasEvents: hasEvents ?? this.hasEvents,
      hasStats: hasStats ?? this.hasStats,
      hasLineups: hasLineups ?? this.hasLineups,
      hasOdds: hasOdds ?? this.hasOdds,
      hasH2H: hasH2H ?? this.hasH2H,
      hasStandings: hasStandings ?? this.hasStandings,
      isKnockout: isKnockout ?? this.isKnockout,
      hasBracket: hasBracket ?? this.hasBracket,
      venueName: venueName ?? this.venueName,
      venueCity: venueCity ?? this.venueCity,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatchDetailInfo &&
          runtimeType == other.runtimeType &&
          matchId == other.matchId &&
          leagueId == other.leagueId &&
          season == other.season &&
          leagueName == other.leagueName &&
          leagueLogo == other.leagueLogo &&
          countryName == other.countryName &&
          countryLogo == other.countryLogo &&
          matchTime == other.matchTime &&
          status == other.status &&
          elapsed == other.elapsed &&
          homeTeam == other.homeTeam &&
          homeTeamId == other.homeTeamId &&
          homeTeamLogo == other.homeTeamLogo &&
          awayTeam == other.awayTeam &&
          awayTeamId == other.awayTeamId &&
          awayTeamLogo == other.awayTeamLogo &&
          homeScore == other.homeScore &&
          awayScore == other.awayScore &&
          hasEvents == other.hasEvents &&
          hasStats == other.hasStats &&
          hasLineups == other.hasLineups &&
          hasOdds == other.hasOdds &&
          hasH2H == other.hasH2H &&
          hasStandings == other.hasStandings &&
          isKnockout == other.isKnockout &&
          hasBracket == other.hasBracket &&
          venueName == other.venueName &&
          venueCity == other.venueCity &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hashAll([
        matchId,
        leagueId,
        season,
        leagueName,
        leagueLogo,
        countryName,
        countryLogo,
        matchTime,
        status,
        elapsed,
        homeTeam,
        homeTeamId,
        homeTeamLogo,
        awayTeam,
        awayTeamId,
        awayTeamLogo,
        homeScore,
        awayScore,
        hasEvents,
        hasStats,
        hasLineups,
        hasOdds,
        hasH2H,
        hasStandings,
        isKnockout,
        hasBracket,
        venueName,
        venueCity,
        createdAt,
        updatedAt,
      ]);
}
