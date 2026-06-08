import 'package:dio/dio.dart';
import 'package:fover/core/config/app_config.dart';
import 'package:fover/core/constants/api_constants.dart';
import 'package:fover/core/network/api_result.dart';
import 'package:fover/core/network/dio_client.dart';
import 'package:fover/core/network/dio_error_mapper.dart';
import 'package:fover/features/leagues/domain/models/league_section_model.dart';

class LeagueApiService {
  LeagueApiService(this._dioClient);

  final DioClient _dioClient;

  Future<ApiResult<List<LeagueSectionModel>>> fetchGroupedLeagues() async {
    try {
      final response = await _execute(
        'groupedLeagues',
        () => _dioClient.dio.get(ApiConstants.groupedLeagues),
      );

      final payload = response.data;
      final rawSections = _extractSections(payload);

      if (rawSections != null) {
        final sections = rawSections
            .whereType<Map>()
            .map((item) => LeagueSectionModel.fromJson(
                  Map<String, dynamic>.from(item),
                ))
            .toList();
        return ApiResult.success(sections);
      }

      return ApiResult.failure('Unexpected grouped leagues response format.');
    } on DioException catch (exception, stackTrace) {
      return ApiResult.failure(DioErrorMapper.map(exception), stackTrace);
    } catch (error, stackTrace) {
      return ApiResult.failure(error.toString(), stackTrace);
    }
  }

  List<dynamic>? _extractSections(dynamic payload) {
    if (payload is List) {
      return payload;
    }

    if (payload is Map<String, dynamic>) {
      final data = payload['data'];
      if (data is List) {
        return data;
      }

      final sections = payload['sections'];
      if (sections is List) {
        return sections;
      }
    }

    return null;
  }

  Future<Response> _execute(
    String requestLabel,
    Future<Response> Function() request,
  ) async {
    var attempt = 0;
    while (true) {
      attempt += 1;
      try {
        return await request().timeout(
          Duration(seconds: AppConfig.receiveTimeout),
        );
      } on DioException catch (exception) {
        final statusCode = exception.response?.statusCode;
        if (statusCode == 404) {
          rethrow;
        }
        if (attempt >= AppConfig.retryAttempts) {
          rethrow;
        }
        await Future<void>.delayed(
          const Duration(milliseconds: AppConfig.retryDelayMillis),
        );
      }
    }
  }
}
