import 'package:hive/hive.dart';
import 'package:fover/core/network/api_result.dart';
import 'package:fover/core/network/dio_client.dart';
import 'package:fover/core/storage/hive_service.dart';
import 'package:fover/features/teams/data/team_api_service.dart';
import 'package:fover/features/teams/domain/team_repository.dart';
import 'package:fover/features/teams/domain/models/team_model.dart';

class TeamRepositoryImpl implements TeamRepository {
  TeamRepositoryImpl({DioClient? dioClient})
      : _apiService = TeamApiService(dioClient ?? DioClient());

  final TeamApiService _apiService;
  static const _cacheBoxName = 'team_cache';

  @override
  Future<ApiResult<TeamInfo>> fetchTeam(int teamId, {bool forceRefresh = false}) async {
    final box = await _openCacheBox();
    final cacheKey = teamId.toString();

    if (!forceRefresh) {
      final cached = box.get(cacheKey);
      final cachedTeam = _readCachedTeam(cached);
      if (cachedTeam != null) {
        return ApiResult.success(cachedTeam);
      }
    }

    final result = await _apiService.fetchTeam(teamId);
    if (!result.isSuccess) {
      if (!forceRefresh) {
        final cached = box.get(cacheKey);
        final cachedTeam = _readCachedTeam(cached);
        if (cachedTeam != null) {
          return ApiResult.success(cachedTeam);
        }
      }
      return ApiResult.failure(result.error ?? 'Unable to load team data');
    }

    final team = result.data!;
    await box.put(cacheKey, team.toJson());
    return ApiResult.success(team);
  }

  Future<Box<dynamic>> _openCacheBox() async {
    if (HiveService.instance.boxExists(_cacheBoxName)) {
      return HiveService.instance.openBox<dynamic>(_cacheBoxName);
    }
    return await HiveService.instance.openBoxAsync<dynamic>(_cacheBoxName);
  }

  TeamInfo? _readCachedTeam(Object? cached) {
    if (cached is Map<String, dynamic>) {
      return TeamInfo.fromJson(cached);
    }
    return null;
  }
}
