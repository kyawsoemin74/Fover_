import 'package:fover/core/network/api_result.dart';
import 'package:fover/core/network/dio_client.dart';
import 'package:fover/features/home/data/match_api_service.dart';
import 'package:fover/features/standings/domain/models/standing_model.dart';
import 'package:fover/features/standings/domain/standing_repository.dart';

class StandingRepositoryImpl implements StandingRepository {
  StandingRepositoryImpl({DioClient? dioClient})
      : _apiService = MatchApiService(dioClient ?? DioClient.shared);

  final MatchApiService _apiService;

  @override
  Future<ApiResult<List<StandingInfo>>> fetchStandings(
    int leagueId,
    String season,
  ) async {
    final result = await _apiService.fetchStandings(leagueId, season);
    if (!result.isSuccess) {
      return ApiResult.failure(result.error ?? 'Unable to load standings');
    }

    final data = result.data;
    if (data != null) {
      return ApiResult.success(
        data.map((item) => item.toDomain()).toList(),
      );
    }

    return ApiResult.success(const []);
  }
}
