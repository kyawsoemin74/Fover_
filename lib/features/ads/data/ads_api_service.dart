import 'package:dio/dio.dart';
import 'package:fover/core/constants/api_constants.dart';
import 'package:fover/core/network/api_result.dart';
import 'package:fover/core/network/dio_client.dart';
import 'package:fover/core/network/dio_error_mapper.dart';
import 'package:fover/features/ads/domain/models/ad_model.dart';

class AdsApiService {
  AdsApiService(this._dioClient);

  final DioClient _dioClient;

  Future<ApiResult<List<AdInfo>>> fetchAds() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.ads);
      final payload = response.data;

      if (payload is Map<String, dynamic>) {
        final items = payload['ads'] as List<dynamic>? ?? [];
        final ads = items
            .whereType<Map<String, dynamic>>()
            .map((item) => AdInfo.fromJson(item))
            .toList();
        return ApiResult.success(ads);
      }

      return ApiResult.failure('Unexpected ads response format.');
    } on DioException catch (exception, stackTrace) {
      return ApiResult.failure(DioErrorMapper.map(exception), stackTrace);
    } catch (error, stackTrace) {
      return ApiResult.failure(error.toString(), stackTrace);
    }
  }
}
