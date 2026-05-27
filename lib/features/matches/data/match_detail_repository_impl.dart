import 'package:fover/core/network/api_result.dart';
import 'package:fover/core/network/dio_client.dart';
import 'package:fover/features/home/data/match_api_service.dart';
import 'package:fover/features/matches/domain/match_detail_repository.dart';
import 'package:fover/features/matches/domain/models/match_detail_model.dart';
import 'package:fover/features/matches/domain/models/match_odds_model.dart';

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
  Future<ApiResult<dynamic>> fetchMatchEvents(int matchId) async {
    final result = await _apiService.fetchMatchEvents(matchId);
    if (!result.isSuccess) {
      return ApiResult.failure(result.error ?? 'Unable to load match events');
    }
    return ApiResult.success(result.data);
  }

  @override
  Future<ApiResult<dynamic>> fetchMatchLineup(int matchId) async {
    final result = await _apiService.fetchMatchLineup(matchId);
    if (!result.isSuccess) {
      return ApiResult.failure(result.error ?? 'Unable to load match lineup');
    }
    return ApiResult.success(result.data);
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
  Future<ApiResult<dynamic>> fetchMatchH2H(int matchId, int homeTeamId, int awayTeamId) async {
    final result = await _apiService.fetchMatchH2H(matchId, homeTeamId, awayTeamId);
    if (!result.isSuccess) {
      return ApiResult.failure(result.error ?? 'Unable to load head-to-head details');
    }
    return ApiResult.success(result.data);
  }
}
