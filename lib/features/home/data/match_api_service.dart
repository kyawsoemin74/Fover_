import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:fover/core/config/app_config.dart';
import 'package:fover/core/constants/api_constants.dart';
import 'package:fover/core/network/api_result.dart';
import 'package:fover/core/network/dio_client.dart';
import 'package:fover/features/home/data/models/league_response_model.dart';

class MatchApiService {
  MatchApiService(this._dioClient);

  final DioClient _dioClient;

  Future<ApiResult<List<LeagueResponseModel>>> fetchLeagueMatches(DateTime date) async {
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      final response = await _execute(
        () => _dioClient.dio.get(
          ApiConstants.matches,
          queryParameters: {
            'date': formattedDate,
            'include': 'competitions,live,scores',
          },
        ),
      );

      final json = response.data;
      final rawLeagues = _extractList(json, ['leagues', 'data', 'items']);
      final leagues = rawLeagues
          .map((item) => LeagueResponseModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();

      return ApiResult.success(leagues);
    } on DioException catch (exception, stackTrace) {
      return ApiResult.failure(_extractError(exception), stackTrace);
    } catch (error, stackTrace) {
      return ApiResult.failure(error.toString(), stackTrace);
    }
  }

  Future<Response> _execute(Future<Response> Function() request) async {
    const maxAttempts = 2;
    var attempt = 0;
    while (true) {
      try {
        attempt += 1;
        return await request().timeout(
              Duration(seconds: AppConfig.receiveTimeout),
            );
      } on DioException catch (_) {
        if (attempt >= maxAttempts) rethrow;
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }
    }
  }

  List<dynamic> _extractList(Object? payload, List<String> keys) {
    if (payload is Map<String, dynamic>) {
      for (final key in keys) {
        final value = payload[key];
        if (value is List) {
          return value;
        }
      }
    }
    return [];
  }

  String _extractError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout || error.type == DioExceptionType.receiveTimeout) {
      return 'Request timed out. Please check your connection.';
    }
    if (error.response != null) {
      return error.response?.data?.toString() ?? error.message ?? 'Unknown error';
    }
    return error.message ?? 'Unknown error';
  }
}
