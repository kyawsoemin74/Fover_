import 'package:fover/core/network/api_result.dart';
import 'package:fover/features/ads/config/ads_config_model.dart';

abstract class AdsConfigRepository {
  Future<ApiResult<AdsConfigModel>> fetchConfig({bool forceRefresh = false});
}
