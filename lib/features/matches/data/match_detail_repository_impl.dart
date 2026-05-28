import 'package:fover/core/network/api_result.dart';
import 'package:fover/core/network/dio_client.dart';
import 'package:fover/features/home/data/match_api_service.dart';
import 'package:fover/features/matches/domain/match_detail_repository.dart';
import 'package:fover/features/matches/domain/models/match_detail_model.dart';
import 'package:fover/features/matches/domain/models/match_event_model.dart';
import 'package:fover/features/matches/domain/models/match_h2h_model.dart';
import 'package:fover/features/matches/domain/models/match_lineup_model.dart';
import 'package:fover/features/matches/domain/models/match_odds_model.dart';
import 'package:fover/features/matches/domain/models/match_stats_model.dart';

class MatchDetailRepositoryImpl implements MatchDetailRepository {
  MatchDetailRepositoryImpl({DioClient? dioClient})
      : _apiService = MatchApiService(dioClient ?? DioClient());

  final MatchApiService _apiService;

  @override
  Future<ApiResult<MatchDetailInfo>> fetchMatchDetail(int matchId) async {
    final result = await _apiService.fetchMatchDetail(matchId);
    if (!result.isSuccess) {
      return ApiResult.failure(result.error ?? 'Unable to load match detail');
    }
    return ApiResult.success(result.data!.toDomain());
  }

  @override
  Future<ApiResult<List<MatchEventInfo>>> fetchMatchEvents(int matchId) async {
    final result = await _apiService.fetchMatchEvents(matchId);
    if (!result.isSuccess) {
      return ApiResult.failure(result.error ?? 'Unable to load match events');
    }

    final data = result.data;
    if (data is List) {
      return ApiResult.success(data
          .whereType<Map<String, dynamic>>()
          .map(MatchEventInfo.fromJson)
          .toList());
    }
    if (data is Map<String, dynamic>) {
      final events = <MatchEventInfo>[];
      final rawEvents = data['events'] ?? data['data'] ?? data['payload'];
      if (rawEvents is List) {
        events.addAll(rawEvents.whereType<Map<String, dynamic>>().map(MatchEventInfo.fromJson));
      }
      return ApiResult.success(events);
    }

    return ApiResult.success(const []);
  }

  @override
  Future<ApiResult<MatchLineupInfo>> fetchMatchLineup(int matchId) async {
    final result = await _apiService.fetchMatchLineup(matchId);
    if (!result.isSuccess) {
      return ApiResult.failure(result.error ?? 'Unable to load match lineup');
    }

    final data = result.data;
    if (data is Map<String, dynamic>) {
      return ApiResult.success(MatchLineupInfo.fromJson(data));
    }
    return ApiResult.failure('Unexpected lineup response format.');
  }

  @override
  Future<ApiResult<MatchOddsInfo>> fetchMatchOdds(int matchId) async {
    final result = await _apiService.fetchMatchOdds(matchId);
    if (!result.isSuccess) {
      return ApiResult.failure(result.error ?? 'Unable to load match odds');
    }

    if (result.data is Map<String, dynamic>) {
      return ApiResult.success(MatchOddsInfo.fromJson(result.data as Map<String, dynamic>));
    }

    return ApiResult.failure('Unexpected odds response format.');
  }

  @override
  Future<ApiResult<MatchH2HInfo>> fetchMatchH2H(int matchId, int homeTeamId, int awayTeamId) async {
    final result = await _apiService.fetchMatchH2H(matchId, homeTeamId, awayTeamId);
    if (!result.isSuccess) {
      return ApiResult.failure(result.error ?? 'Unable to load head-to-head details');
    }

    final data = result.data;
    if (data is Map<String, dynamic>) {
      return ApiResult.success(MatchH2HInfo.fromJson(data));
    }
    return ApiResult.failure('Unexpected H2H response format.');
  }

  @override
  Future<ApiResult<MatchStatsInfo>> fetchMatchStats(int matchId) async {
    final result = await _apiService.fetchMatchStats(matchId);
    if (!result.isSuccess) {
      return ApiResult.failure(result.error ?? 'Unable to load match statistics');
    }

    final data = result.data;
    if (data is Map<String, dynamic>) {
      return ApiResult.success(MatchStatsInfo.fromJson(data));
    }
    return ApiResult.success(MatchStatsInfo.empty());
  }
}
