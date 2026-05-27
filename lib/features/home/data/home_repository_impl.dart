import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:fover/core/constants/app_constants.dart';
import 'package:fover/core/network/api_result.dart';
import 'package:fover/core/network/dio_client.dart';
import 'package:fover/core/storage/hive_service.dart';
import 'package:fover/features/home/data/match_api_service.dart';
import 'package:fover/features/home/domain/home_repository.dart';
import 'package:fover/features/home/domain/models/league_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl({DioClient? dioClient})
      : _apiService = MatchApiService(dioClient ?? DioClient());

  final MatchApiService _apiService;
  static const _cacheBoxName = 'home_match_cache';

  @override
  Future<ApiResult<List<LeagueInfo>>> fetchLeagueMatches(
    DateTime date, {
    bool forceRefresh = false,
  }) async {
    final cacheKey = _cacheKey(date);
    final box = await _openCacheBox();

    if (!forceRefresh) {
      final cached = box.get(cacheKey);
      if (cached is Map<String, dynamic>) {
        final cachedDate = cached['cachedAt'] as String?;
        if (cachedDate != null && !_isExpired(cachedDate)) {
          final payload = cached['payload'];
          if (payload is List) {
            final leagues = payload
                .map((item) => LeagueInfo.fromJson(Map<String, dynamic>.from(item as Map)))
                .toList();
            return ApiResult.success(leagues);
          }
        }
      }
    }

    final result = await _apiService.fetchLeagueMatches(date);
    if (!result.isSuccess) {
      if (!forceRefresh) {
        final cached = box.get(cacheKey);
        if (cached is Map<String, dynamic>) {
          final payload = cached['payload'];
          if (payload is List) {
            final leagues = payload
                .map((item) => LeagueInfo.fromJson(Map<String, dynamic>.from(item as Map)))
                .toList();
            return ApiResult.success(leagues);
          }
        }
      }
      return ApiResult.failure(result.error ?? 'Unknown error');
    }

    final leagues = result.data!.map((league) => league.toDomain()).toList();
    await box.put(cacheKey, {
      'cachedAt': DateTime.now().toIso8601String(),
      'payload': leagues.map((league) => league.toJson()).toList(),
    });

    return ApiResult.success(leagues);
  }

  Future<Box<dynamic>> _openCacheBox() async {
    if (HiveService.instance.boxExists(_cacheBoxName)) {
      return HiveService.instance.openBox<dynamic>(_cacheBoxName);
    }
    return await HiveService.instance.openBoxAsync<dynamic>(_cacheBoxName);
  }

  String _cacheKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  bool _isExpired(String cachedAt) {
    final dateTime = DateTime.tryParse(cachedAt);
    if (dateTime == null) return true;
    return DateTime.now().difference(dateTime).inDays >= AppConstants.cacheDays;
  }
}
