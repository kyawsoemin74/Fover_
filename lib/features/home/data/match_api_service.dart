import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:fover/core/config/app_config.dart';
import 'package:fover/core/constants/api_constants.dart';
import 'package:fover/core/network/api_result.dart';
import 'package:fover/core/network/dio_client.dart';
import 'package:fover/features/home/data/models/league_response_model.dart';
import 'package:fover/features/home/data/models/match_response_model.dart';
import 'package:fover/features/matches/data/models/match_detail_response_model.dart';

class MatchApiService {
  MatchApiService(this._dioClient);

  final DioClient _dioClient;

  Future<ApiResult<List<LeagueResponseModel>>> fetchLiveMatches() async {
    try {
      final response = await _execute(() => _dioClient.dio.get(ApiConstants.liveMatches));
      final items = _extractList(response.data);
      final leagues = _groupMatches(items);
      return ApiResult.success(leagues);
    } on DioException catch (exception, stackTrace) {
      return ApiResult.failure(_extractError(exception), stackTrace);
    } catch (error, stackTrace) {
      return ApiResult.failure(error.toString(), stackTrace);
    }
  }

  Future<ApiResult<List<LeagueResponseModel>>> fetchMatchesByDate(DateTime date) async {
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);
      final response = await _execute(
        () => _dioClient.dio.get(ApiConstants.matchesByDate(formattedDate)),
      );
      final items = _extractList(response.data);
      final leagues = _groupMatches(items);
      return ApiResult.success(leagues);
    } on DioException catch (exception, stackTrace) {
      return ApiResult.failure(_extractError(exception), stackTrace);
    } catch (error, stackTrace) {
      return ApiResult.failure(error.toString(), stackTrace);
    }
  }

  Future<ApiResult<MatchDetailResponseModel>> fetchMatchDetail(int matchId) async {
    try {
      final response = await _execute(() => _dioClient.dio.get(ApiConstants.matchById(matchId)));
      final payload = response.data;
      if (payload is Map<String, dynamic>) {
        return ApiResult.success(MatchDetailResponseModel.fromJson(payload));
      }
      return ApiResult.failure('Unexpected match detail response format.');
    } on DioException catch (exception, stackTrace) {
      return ApiResult.failure(_extractError(exception), stackTrace);
    } catch (error, stackTrace) {
      return ApiResult.failure(error.toString(), stackTrace);
    }
  }

  Future<ApiResult<dynamic>> fetchMatchEvents(int matchId) async {
    try {
      final response = await _execute(() => _dioClient.dio.get(ApiConstants.matchEvents(matchId)));
      return ApiResult.success(response.data);
    } on DioException catch (exception, stackTrace) {
      return ApiResult.failure(_extractError(exception), stackTrace);
    } catch (error, stackTrace) {
      return ApiResult.failure(error.toString(), stackTrace);
    }
  }

  Future<ApiResult<dynamic>> fetchMatchLineup(int matchId) async {
    try {
      final response = await _execute(() => _dioClient.dio.get(ApiConstants.matchLineup(matchId)));
      return ApiResult.success(response.data);
    } on DioException catch (exception, stackTrace) {
      return ApiResult.failure(_extractError(exception), stackTrace);
    } catch (error, stackTrace) {
      return ApiResult.failure(error.toString(), stackTrace);
    }
  }

  Future<ApiResult<dynamic>> fetchMatchOdds(int matchId) async {
    try {
      final response = await _execute(() => _dioClient.dio.get(ApiConstants.matchOdds(matchId)));
      return ApiResult.success(response.data);
    } on DioException catch (exception, stackTrace) {
      return ApiResult.failure(_extractError(exception), stackTrace);
    } catch (error, stackTrace) {
      return ApiResult.failure(error.toString(), stackTrace);
    }
  }

  Future<ApiResult<dynamic>> fetchMatchH2H(int matchId, int homeTeamId, int awayTeamId) async {
    try {
      final response = await _execute(() => _dioClient.dio.get(ApiConstants.matchH2H(matchId, homeTeamId, awayTeamId)));
      return ApiResult.success(response.data);
    } on DioException catch (exception, stackTrace) {
      return ApiResult.failure(_extractError(exception), stackTrace);
    } catch (error, stackTrace) {
      return ApiResult.failure(error.toString(), stackTrace);
    }
  }

  Future<Response> _execute(Future<Response> Function() request) async {
    var attempt = 0;
    while (true) {
      try {
        attempt += 1;
        return await request().timeout(
              Duration(seconds: AppConfig.receiveTimeout),
            );
      } on DioException catch (_) {
        if (attempt >= AppConfig.retryAttempts) rethrow;
        await Future<void>.delayed(const Duration(milliseconds: AppConfig.retryDelayMillis));
      }
    }
  }

  List<dynamic> _extractList(Object? payload) {
    if (payload is List) {
      return payload;
    }
    if (payload is Map<String, dynamic>) {
      for (final value in payload.values) {
        if (value is List) {
          return value;
        }
      }
    }
    return [];
  }

  List<LeagueResponseModel> _groupMatches(List<dynamic> items) {
    final leagueGroups = <String, List<MatchResponseModel>>{};
    final leagueMetadata = <String, Map<String, dynamic>>{};

    for (final item in items) {
      if (item is! Map<String, dynamic>) continue;
      final leagueId = item['league_id']?.toString() ?? item['leagueId']?.toString() ?? '';
      if (leagueId.isEmpty) continue;

      final match = MatchResponseModel.fromJson(item);
      leagueGroups.putIfAbsent(leagueId, () => []).add(match);
      leagueMetadata.putIfAbsent(leagueId, () {
        return {
          'id': leagueId,
          'leagueName': item['league_name'] as String? ?? item['leagueName'] as String? ?? '',
          'countryCode': item['country_name'] as String? ?? item['countryCode'] as String? ?? '',
          'countryFlagUrl': item['country_logo'] as String? ?? item['countryFlagUrl'] as String?,
        };
      });
    }

    return leagueGroups.entries.map((entry) {
      final meta = leagueMetadata[entry.key]!;
      return LeagueResponseModel(
        id: meta['id'] as String,
        countryCode: meta['countryCode'] as String,
        leagueName: meta['leagueName'] as String,
        countryFlagUrl: meta['countryFlagUrl'] as String?,
        matches: entry.value,
      );
    }).toList();
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
