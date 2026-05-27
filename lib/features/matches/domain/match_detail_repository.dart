import 'package:fover/core/network/api_result.dart';
import 'package:fover/features/matches/domain/models/match_detail_model.dart';
import 'package:fover/features/matches/domain/models/match_odds_model.dart';

abstract class MatchDetailRepository {
  Future<ApiResult<MatchDetailInfo>> fetchMatchDetail(int matchId);

  Future<ApiResult<dynamic>> fetchMatchEvents(int matchId);

  Future<ApiResult<dynamic>> fetchMatchLineup(int matchId);

  Future<ApiResult<MatchOddsInfo>> fetchMatchOdds(int matchId);

  Future<ApiResult<dynamic>> fetchMatchH2H(int matchId, int homeTeamId, int awayTeamId);
}
