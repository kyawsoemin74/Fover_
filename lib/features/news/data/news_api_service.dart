import 'package:dio/dio.dart';
import 'package:fover/core/constants/api_constants.dart';
import 'package:fover/core/network/api_result.dart';
import 'package:fover/core/network/dio_client.dart';
import 'package:fover/features/news/domain/models/news_model.dart';

class NewsApiService {
  NewsApiService(this._dioClient);

  final DioClient _dioClient;

  Future<ApiResult<List<NewsInfo>>> fetchNews() async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.news);
      final payload = response.data;
      if (payload is Map<String, dynamic>) {
        final items = payload['news'] as List<dynamic>? ?? [];
        final news = items
            .whereType<Map<String, dynamic>>()
            .map((item) => NewsInfo.fromJson(item))
            .toList();
        return ApiResult.success(news);
      }
      return ApiResult.failure('Unexpected news response format.');
    } on DioException catch (exception, stackTrace) {
      return ApiResult.failure(exception.message ?? 'Unable to load news.', stackTrace);
    } catch (error, stackTrace) {
      return ApiResult.failure(error.toString(), stackTrace);
    }
  }
}
