import 'package:hive/hive.dart';
import 'package:fover/core/constants/app_constants.dart';
import 'package:fover/core/network/api_result.dart';
import 'package:fover/core/network/dio_client.dart';
import 'package:fover/core/storage/hive_service.dart';
import 'package:fover/features/ads/config/ads_config_model.dart';
import 'package:fover/features/ads/config/data/ads_config_api_service.dart';
import 'package:fover/features/ads/config/domain/ads_config_repository.dart';

class AdsConfigRepositoryImpl implements AdsConfigRepository {
  AdsConfigRepositoryImpl({DioClient? dioClient})
      : _apiService = AdsConfigApiService(dioClient ?? DioClient.shared);

  final AdsConfigApiService _apiService;
  static const _cacheBoxName = 'ads_config_cache';
  static const _cacheKey = 'ads_config';

  @override
  Future<ApiResult<AdsConfigModel>> fetchConfig({bool forceRefresh = false}) async {
    final box = await _openCacheBox();

    if (!forceRefresh) {
      final cached = box.get(_cacheKey);
      final cachedConfig = _readCachedConfig(cached);
      if (cachedConfig != null) {
        return ApiResult.success(cachedConfig);
      }
    }

    final result = await _apiService.fetchConfig();
    if (!result.isSuccess) {
      if (!forceRefresh) {
        final cached = box.get(_cacheKey);
        final cachedConfig = _readCachedConfig(cached);
        if (cachedConfig != null) {
          return ApiResult.success(cachedConfig);
        }
      }
      return ApiResult.failure(result.error ?? 'Unable to load ads config.');
    }

    final config = result.data!;
    await box.put(_cacheKey, {
      'cachedAt': DateTime.now().toIso8601String(),
      'payload': config.toJson(),
    });
    return ApiResult.success(config);
  }

  Future<Box<dynamic>> _openCacheBox() async {
    if (HiveService.instance.boxExists(_cacheBoxName)) {
      return HiveService.instance.openBox<dynamic>(_cacheBoxName);
    }
    return HiveService.instance.openBoxAsync<dynamic>(_cacheBoxName);
  }

  AdsConfigModel? _readCachedConfig(Object? cached) {
    if (cached is Map<String, dynamic>) {
      final cachedDate = cached['cachedAt'] as String?;
      if (cachedDate != null && !_isExpired(cachedDate)) {
        final payload = cached['payload'];
        if (payload is Map<String, dynamic>) {
          return AdsConfigModel.fromJson(payload);
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
