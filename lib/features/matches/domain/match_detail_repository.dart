import 'package:fover/core/network/api_result.dart';
import 'package:fover/features/matches/domain/models/match_detail_model.dart';
import 'package:fover/features/matches/domain/models/match_event_model.dart';
import 'package:fover/features/matches/domain/models/match_h2h_model.dart';
import 'package:fover/features/matches/domain/models/match_lineup_model.dart';
import 'package:fover/features/matches/domain/models/match_odds_model.dart';
import 'package:fover/features/matches/domain/models/match_stats_model.dart';

abstract class MatchDetailRepository {
  Future<ApiResult<MatchDetailInfo>> fetchMatchDetail(int matchId);

  Future<ApiResult<List<MatchEventInfo>>> fetchMatchEvents(int matchId);

  Future<ApiResult<MatchLineupInfo>> fetchMatchLineup(int matchId);

  Future<ApiResult<MatchOddsInfo>> fetchMatchOdds(int matchId);

  Future<ApiResult<MatchH2HInfo>> fetchMatchH2H(int matchId, int homeTeamId, int awayTeamId);

  Future<ApiResult<MatchStatsInfo>> fetchMatchStats(int matchId);
}
