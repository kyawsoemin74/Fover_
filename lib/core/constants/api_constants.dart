class ApiConstants {
  static const matches = '/api/matches/';
  static const liveMatches = '/api/matches/live_all';
  static String matchesByDate(String date) => '/api/matches/date/$date';
  static String matchById(int matchId) => '/api/matches/$matchId';
  static String matchEvents(int matchId) => '/api/matches/$matchId/events';
  static String matchLineup(int matchId) => '/api/matches/$matchId/lineup';
  static String matchOdds(int matchId) => '/api/matches/$matchId/odds';
  static String matchH2H(int matchId, int homeTeamId, int awayTeamId) => '/api/matches/h2h/$matchId/$homeTeamId/$awayTeamId';

  static String standings(int leagueId, String season) =>
      '/api/leagues/$leagueId/standing/$season';

  static String teamById(int teamId) => '/api/teams/$teamId';

  static const news = '/api/news';
  static String newsById(String id) => '/api/news/$id';
  static const ads = '/api/ads/';

  static const login = '/api/auth/login';
}