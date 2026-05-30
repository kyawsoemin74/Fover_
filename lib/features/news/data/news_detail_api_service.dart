import 'package:dio/dio.dart';
import 'package:fover/core/constants/api_constants.dart';
import 'package:fover/core/network/api_result.dart';
import 'package:fover/core/network/dio_client.dart';
import 'package:fover/core/network/dio_error_mapper.dart';

class NewsDetailApiService {
  NewsDetailApiService(this._dioClient);

  final DioClient _dioClient;

  Future<ApiResult<Map<String, dynamic>>> fetchNewsDetail(String articleId) async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.newsById(articleId));
      final payload = response.data;
      if (payload is Map<String, dynamic>) {
        final article = payload['article'] ?? payload['data'] ?? payload;
        if (article is Map<String, dynamic>) {
          return ApiResult.success(article);
        }
      }
      return ApiResult.failure('Unexpected news detail response format.');
    } on DioException catch (exception, stackTrace) {
      return ApiResult.failure(DioErrorMapper.map(exception), stackTrace);
    } catch (error, stackTrace) {
      return ApiResult.failure(error.toString(), stackTrace);
    }
  }
}
