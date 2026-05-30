import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:fover/core/constants/api_constants.dart';
import 'package:fover/core/network/api_result.dart';
import 'package:fover/core/network/dio_client.dart';
import 'package:fover/core/network/dio_error_mapper.dart';
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

        if (kDebugMode) {
          // Print raw image fields and resolved imageUrl for debugging
          for (final raw in items.whereType<Map<String, dynamic>>()) {
            final resolved = raw['image_url'] as String? ?? raw['imageUrl'] as String? ?? raw['thumbnail'] as String? ?? '';
            final id = raw['id']?.toString() ?? '(no-id)';
            // ignore: avoid_print
            print('[NewsApi] id=$id image_url_raw=${raw['image_url'] ?? raw['imageUrl'] ?? raw['thumbnail']} resolved=$resolved');
          }
        }
        return ApiResult.success(news);
      }
      return ApiResult.failure('Unexpected news response format.');
    } on DioException catch (exception, stackTrace) {
      return ApiResult.failure(DioErrorMapper.map(exception), stackTrace);
    } catch (error, stackTrace) {
      return ApiResult.failure(error.toString(), stackTrace);
    }
  }
}
