import 'package:hive/hive.dart';
import 'package:fover/core/constants/app_constants.dart';
import 'package:fover/core/network/api_result.dart';
import 'package:fover/core/network/dio_client.dart';
import 'package:fover/core/storage/hive_service.dart';
import 'package:fover/features/news/data/news_detail_api_service.dart';
import 'package:fover/features/news/domain/models/news_model.dart';
import 'package:fover/features/news/domain/news_detail_repository.dart';

class NewsDetailRepositoryImpl implements NewsDetailRepository {
  NewsDetailRepositoryImpl({DioClient? dioClient})
      : _apiService = NewsDetailApiService(dioClient ?? DioClient.shared);

  final NewsDetailApiService _apiService;
  static const _cacheBoxName = 'news_detail_cache';
  static const _cachePrefix = 'article_';

  @override
  Future<ApiResult<NewsInfo>> fetchNewsDetail(String articleId, {bool forceRefresh = false}) async {
    final box = await _openCacheBox();
    final cacheKey = '$_cachePrefix$articleId';

    if (!forceRefresh) {
      final cached = box.get(cacheKey);
      final cachedDetail = _readCachedArticle(cached);
      if (cachedDetail != null) {
        return ApiResult.success(cachedDetail);
      }
    }

    final result = await _apiService.fetchNewsDetail(articleId);
    if (!result.isSuccess) {
      if (!forceRefresh) {
        final cached = box.get(cacheKey);
        final cachedDetail = _readCachedArticle(cached);
        if (cachedDetail != null) {
          return ApiResult.success(cachedDetail);
        }
      }
      return ApiResult.failure(result.error ?? 'Unable to load news article.');
    }

    try {
      final article = NewsInfo.fromJson(result.data!);
      await box.put(cacheKey, {
        'cachedAt': DateTime.now().toIso8601String(),
        'payload': article.toJson(),
      });
      return ApiResult.success(article);
    } catch (error, stackTrace) {
      return ApiResult.failure(error.toString(), stackTrace);
    }
  }

  Future<Box<dynamic>> _openCacheBox() async {
    if (HiveService.instance.boxExists(_cacheBoxName)) {
      return HiveService.instance.openBox<dynamic>(_cacheBoxName);
    }
    return await HiveService.instance.openBoxAsync<dynamic>(_cacheBoxName);
  }

  NewsInfo? _readCachedArticle(Object? cached) {
    if (cached is Map<String, dynamic>) {
      final cachedAt = cached['cachedAt'] as String?;
      if (cachedAt != null && !_isExpired(cachedAt)) {
        final payload = cached['payload'];
        if (payload is Map<String, dynamic>) {
          return NewsInfo.fromJson(payload);
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
