import 'package:fover/core/network/api_result.dart';
import 'package:fover/features/ads/domain/models/ad_model.dart';

abstract class AdsRepository {
  Future<ApiResult<List<AdInfo>>> fetchAds({bool forceRefresh = false});
}
