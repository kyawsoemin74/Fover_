import 'package:dio/dio.dart';
import 'package:fover/core/constants/api_constants.dart';
import 'package:fover/core/network/api_result.dart';
import 'package:fover/core/network/dio_client.dart';
import 'package:fover/core/network/dio_error_mapper.dart';
import 'package:fover/features/ads/config/ads_config_model.dart';

class AdsConfigApiService {
  AdsConfigApiService(this._dioClient);

  final DioClient _dioClient;

  Future<ApiResult<AdsConfigModel>> fetchConfig() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.adsConfig);
      final payload = response.data;

      if (payload is Map<String, dynamic>) {
        return ApiResult.success(AdsConfigModel.fromJson(payload));
      }

      return ApiResult.failure('Unexpected ads config response format.');
    } on DioException catch (exception, stackTrace) {
      return ApiResult.failure(DioErrorMapper.map(exception), stackTrace);
    } catch (error, stackTrace) {
      return ApiResult.failure(error.toString(), stackTrace);
    }
  }
}
