import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import 'package:fover/core/constants/app_constants.dart';
import 'package:fover/core/network/api_result.dart';
import 'package:fover/core/network/dio_client.dart';
import 'package:fover/core/storage/hive_service.dart';
import 'package:fover/features/news/data/news_api_service.dart';
import 'package:fover/features/news/domain/models/news_model.dart';
import 'package:fover/features/news/domain/news_repository.dart';

class NewsRepositoryImpl implements NewsRepository {
    NewsRepositoryImpl({DioClient? dioClient})
      : _apiService = NewsApiService(dioClient ?? DioClient.shared);

  final NewsApiService _apiService;
  static const _cacheBoxName = 'news_cache';
  static const _cacheKey = 'news_list';

  @override
  Future<ApiResult<List<NewsInfo>>> fetchNews({bool forceRefresh = false}) async {
    final box = await _openCacheBox();

    if (!forceRefresh) {
      final cached = box.get(_cacheKey);
      final cachedData = _readCachedNews(cached);
      if (cachedData != null) {
        return ApiResult.success(cachedData);
      }
    }

    final result = await _apiService.fetchNews();
    if (!result.isSuccess) {
      if (!forceRefresh) {
        final cached = box.get(_cacheKey);
        final cachedData = _readCachedNews(cached);
        if (cachedData != null) {
          return ApiResult.success(cachedData);
        }
      }
      return ApiResult.failure(result.error ?? 'Unable to load news.');
    }

    final news = result.data!;
    final payloadToStore = news.map((item) => item.toJson()).toList();
    await box.put(_cacheKey, {
      'cachedAt': DateTime.now().toIso8601String(),
      'payload': payloadToStore,
    });

    if (news.isNotEmpty) {
      // debug log saved cache image urls
      for (final item in payloadToStore) {
        final id = item['id']?.toString() ?? '(no-id)';
        final img = item['image_url'] ?? item['imageUrl'] ?? item['thumbnail'];
        // ignore: avoid_print
        print('[NewsRepo] cached id=$id image=$img');
      }
    }
    return ApiResult.success(news);
  }

  Future<Box<dynamic>> _openCacheBox() async {
    if (HiveService.instance.boxExists(_cacheBoxName)) {
      return HiveService.instance.openBox<dynamic>(_cacheBoxName);
    }
    return await HiveService.instance.openBoxAsync<dynamic>(_cacheBoxName);
  }

  List<NewsInfo>? _readCachedNews(Object? cached) {
    if (cached is Map<String, dynamic>) {
      final cachedDate = cached['cachedAt'] as String?;
      if (cachedDate != null && !_isExpired(cachedDate)) {
        final payload = cached['payload'];
        if (payload is List) {
          if (kDebugMode) {
            for (final item in payload.whereType<Map<String, dynamic>>()) {
              final id = item['id']?.toString() ?? '(no-id)';
              final img = item['image_url'] ?? item['imageUrl'] ?? item['thumbnail'];
              // ignore: avoid_print
              print('[NewsRepo] read cached id=$id image=$img');
            }
          }
          return payload
              .whereType<Map<String, dynamic>>()
              .map((item) => NewsInfo.fromJson(item))
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
