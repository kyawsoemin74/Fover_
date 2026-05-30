import 'dart:async';

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
      : _apiService = MatchApiService(dioClient ?? DioClient.shared);

  final MatchApiService _apiService;
  static const _cacheBoxName = 'home_match_cache';
  static const _liveCacheKey = 'live_all';

  @override
  Future<ApiResult<List<LeagueInfo>>> fetchLeagueMatches(
    DateTime date, {
    bool forceRefresh = false,
  }) async {
    final cacheKey = _cacheKey(date);

    if (!forceRefresh) {
      final cachedData = _readCachedLeaguesIfAvailable(cacheKey);
      if (cachedData != null) {
        return ApiResult.success(cachedData);
      }
    }

    final result = await _apiService.fetchMatchesByDate(date);
    if (!result.isSuccess) {
      if (!forceRefresh) {
        final fallback = await _readCachedLeaguesFromDisk(cacheKey);
        if (fallback != null) {
          return ApiResult.success(fallback);
        }
      }
      return ApiResult.failure(result.error ?? 'Unknown error');
    }

    final leagues = result.data!.map((league) => league.toDomain()).toList();
    unawaited(_saveCache(cacheKey, leagues));

    return ApiResult.success(leagues);
  }

  Future<ApiResult<List<LeagueInfo>>> fetchLiveMatches({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cachedData = _readCachedLeaguesIfAvailable(_liveCacheKey);
      if (cachedData != null) {
        return ApiResult.success(cachedData);
      }
    }

    final result = await _apiService.fetchLiveMatches();
    if (!result.isSuccess) {
      if (!forceRefresh) {
        final fallback = await _readCachedLeaguesFromDisk(_liveCacheKey);
        if (fallback != null) {
          return ApiResult.success(fallback);
        }
      }
      return ApiResult.failure(result.error ?? 'Unknown error');
    }

    final leagues = result.data!.map((league) => league.toDomain()).toList();
    unawaited(_saveCache(_liveCacheKey, leagues));
    return ApiResult.success(leagues);
  }

  Future<List<LeagueInfo>?> _readCachedLeaguesFromDisk(String cacheKey) async {
    final box = await _openCacheBox();
    final cached = box.get(cacheKey);
    return _readCachedLeagues(cached);
  }

  List<LeagueInfo>? _readCachedLeaguesIfAvailable(String cacheKey) {
    if (!HiveService.instance.boxExists(_cacheBoxName)) {
      return null;
    }

    final box = HiveService.instance.openBox<dynamic>(_cacheBoxName);
    final cached = box.get(cacheKey);
    return _readCachedLeagues(cached);
  }

  Future<void> _saveCache(String cacheKey, List<LeagueInfo> leagues) async {
    final box = await _openCacheBox();
    await box.put(cacheKey, {
      'cachedAt': DateTime.now().toIso8601String(),
      'payload': leagues.map((league) => league.toJson()).toList(),
    });
  }

  Future<Box<dynamic>> _openCacheBox() async {
    if (HiveService.instance.boxExists(_cacheBoxName)) {
      return HiveService.instance.openBox<dynamic>(_cacheBoxName);
    }
    return HiveService.instance.openBoxAsync<dynamic>(_cacheBoxName);
  }

  String _cacheKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  List<LeagueInfo>? _readCachedLeagues(Object? cached) {
    if (cached is Map<String, dynamic>) {
      final cachedDate = cached['cachedAt'] as String?;
      if (cachedDate != null && !_isExpired(cachedDate)) {
        final payload = cached['payload'];
        if (payload is List) {
          return payload
              .map((item) => LeagueInfo.fromJson(Map<String, dynamic>.from(item as Map)))
              .toList();
        }
      }
    }
    return null;
  }

  bool _isExpired(String cachedAt) {
    final dateTime = DateTime.tryParse(cachedAt);
    if (dateTime == null) return true;
    return DateTime.now().difference(dateTime).inDays >= AppConstants.cacheDays;
  }
}
