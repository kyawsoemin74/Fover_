import 'package:hive/hive.dart';
import 'package:fover/core/constants/app_constants.dart';
import 'package:fover/core/network/api_result.dart';
import 'package:fover/core/network/dio_client.dart';
import 'package:fover/core/storage/hive_service.dart';
import 'package:fover/features/ads/data/ads_api_service.dart';
import 'package:fover/features/ads/domain/ads_repository.dart';
import 'package:fover/features/ads/domain/models/ad_model.dart';

class AdsRepositoryImpl implements AdsRepository {
  AdsRepositoryImpl({DioClient? dioClient})
      : _apiService = AdsApiService(dioClient ?? DioClient());

  final AdsApiService _apiService;
  static const _cacheBoxName = 'ads_cache';
  static const _cacheKey = 'ads_list';

  @override
  Future<ApiResult<List<AdInfo>>> fetchAds({bool forceRefresh = false}) async {
    final box = await _openCacheBox();

    if (!forceRefresh) {
      final cached = box.get(_cacheKey);
      final cachedAds = _readCachedAds(cached);
      if (cachedAds != null) {
        return ApiResult.success(cachedAds);
      }
    }

    final result = await _apiService.fetchAds();
    if (!result.isSuccess) {
      if (!forceRefresh) {
        final cached = box.get(_cacheKey);
        final cachedAds = _readCachedAds(cached);
        if (cachedAds != null) {
          return ApiResult.success(cachedAds);
        }
      }
      return ApiResult.failure(result.error ?? 'Unable to load ads.');
    }

    final ads = result.data!;
    await box.put(_cacheKey, {
      'cachedAt': DateTime.now().toIso8601String(),
      'payload': ads.map((ad) => ad.toJson()).toList(),
    });
    return ApiResult.success(ads);
  }

  Future<Box<dynamic>> _openCacheBox() async {
    if (HiveService.instance.boxExists(_cacheBoxName)) {
      return HiveService.instance.openBox<dynamic>(_cacheBoxName);
    }
    return await HiveService.instance.openBoxAsync<dynamic>(_cacheBoxName);
  }

  List<AdInfo>? _readCachedAds(Object? cached) {
    if (cached is Map<String, dynamic>) {
      final cachedDate = cached['cachedAt'] as String?;
      if (cachedDate != null && !_isExpired(cachedDate)) {
        final payload = cached['payload'];
        if (payload is List) {
          return payload
              .whereType<Map<String, dynamic>>()
              .map((item) => AdInfo.fromJson(item))
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
