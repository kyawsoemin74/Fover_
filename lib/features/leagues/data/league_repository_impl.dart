import 'package:fover/core/network/api_result.dart';
import 'package:fover/core/network/dio_client.dart';
import 'package:fover/features/leagues/data/league_api_service.dart';
import 'package:fover/features/leagues/domain/league_repository.dart';
import 'package:fover/features/leagues/domain/models/league_section_model.dart';

class LeagueRepositoryImpl implements LeagueRepository {
  LeagueRepositoryImpl({DioClient? dioClient})
      : _apiService = LeagueApiService(dioClient ?? DioClient.shared);

  final LeagueApiService _apiService;

  @override
  Future<ApiResult<List<LeagueSectionModel>>> fetchGroupedLeagues() async {
    final result = await _apiService.fetchGroupedLeagues();

    if (!result.isSuccess) {
      return ApiResult.failure(result.error ?? 'Unable to load grouped leagues');
    }

    return ApiResult.success(result.data ?? const []);
  }
}
