import 'package:intl/intl.dart';
import 'package:fover/features/matches/domain/models/match_detail_model.dart';

class MatchDetailResponseModel {
  MatchDetailResponseModel({
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

  factory MatchDetailResponseModel.fromJson(Map<String, dynamic> json) {
    final rawMatchTime = json['match_time'] as String? ?? '';
    return MatchDetailResponseModel(
      matchId: json['match_id'] as int? ?? int.tryParse(json['match_id']?.toString() ?? '') ?? 0,
      leagueId: json['league_id'] as int? ?? int.tryParse(json['league_id']?.toString() ?? '') ?? 0,
      season: _parseSeason(json),
      leagueName: json['league_name'] as String? ?? '',
      leagueLogo: json['league_logo'] as String? ?? '',
      countryName: json['country_name'] as String? ?? '',
      countryLogo: json['country_logo'] as String? ?? '',
      matchTime: _formatLocalTime(rawMatchTime),
      status: json['status'] as String? ?? 'UPCOMING',
      elapsed: json['elapsed'] as int? ?? int.tryParse(json['elapsed']?.toString() ?? '') ?? 0,
      homeTeam: json['home_team'] as String? ?? '',
      homeTeamId: json['home_team_id'] as int? ?? int.tryParse(json['home_team_id']?.toString() ?? '') ?? 0,
      homeTeamLogo: json['home_team_logo'] as String? ?? '',
      awayTeam: json['away_team'] as String? ?? '',
      awayTeamId: json['away_team_id'] as int? ?? int.tryParse(json['away_team_id']?.toString() ?? '') ?? 0,
      awayTeamLogo: json['away_team_logo'] as String? ?? '',
      homeScore: json['home_score'] as int? ?? int.tryParse(json['home_score']?.toString() ?? '') ?? 0,
      awayScore: json['away_score'] as int? ?? int.tryParse(json['away_score']?.toString() ?? '') ?? 0,
      venueName: json['venue_name'] as String?,
      venueCity: json['venue_city'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  MatchDetailInfo toDomain() {
    return MatchDetailInfo(
      matchId: matchId,
      leagueId: leagueId,
      season: season,
      leagueName: leagueName,
      leagueLogo: leagueLogo,
      countryName: countryName,
      countryLogo: countryLogo,
      matchTime: matchTime,
      status: status,
      elapsed: elapsed,
      homeTeam: homeTeam,
      homeTeamId: homeTeamId,
      homeTeamLogo: homeTeamLogo,
      awayTeam: awayTeam,
      awayTeamId: awayTeamId,
      awayTeamLogo: awayTeamLogo,
      homeScore: homeScore,
      awayScore: awayScore,
      venueName: venueName,
      venueCity: venueCity,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static String _parseSeason(Map<String, dynamic> json) {
    return json['season']?.toString() ??
        json['season_name']?.toString() ??
        json['competition_season']?.toString() ??
        json['league_season']?.toString() ??
        '';
  }

  static String _formatLocalTime(String rawTime) {
    try {
      final parsed = DateTime.parse(rawTime).toLocal();
      return DateFormat('h:mm a').format(parsed);
    } catch (_) {
      return rawTime;
    }
  }
}
