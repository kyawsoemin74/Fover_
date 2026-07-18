import 'package:dio/dio.dart';
import 'package:fover/core/constants/api_constants.dart';
import 'package:fover/core/network/api_result.dart';
import 'package:fover/core/network/dio_client.dart';
import 'package:fover/core/network/dio_error_mapper.dart';
import 'package:fover/features/home/domain/models/match_model.dart';
import 'package:fover/features/standings/domain/models/standing_model.dart';
import 'package:fover/features/team/models/team_finished_match.dart';
import 'package:fover/features/team/models/team_model.dart';
import 'package:fover/features/team/models/team_squad_model.dart';

class TeamApiService {
  TeamApiService(this._dioClient);

  final DioClient _dioClient;

  Future<ApiResult<TeamModel>> fetchTeam(int teamId) async {
    try {
      final response = await _dioClient.dio.get(ApiConstants.teamById(teamId));
      final payload = response.data;
      if (payload is Map<String, dynamic>) {
        return ApiResult.success(TeamModel.fromJson(payload));
      }
      return ApiResult.failure('Invalid team payload received from server.');
    } on DioException catch (exception, stackTrace) {
      return ApiResult.failure(DioErrorMapper.map(exception), stackTrace);
    } catch (error, stackTrace) {
      return ApiResult.failure(error.toString(), stackTrace);
    }
  }

  Future<ApiResult<List<MatchInfo>>> fetchTeamMatches(int teamId) async {
    try {
      final response = await _dioClient.dio.get(
        '/api/teams/$teamId/matches',
      );
      final payload = response.data;
      if (payload is List) {
        final matches = payload
            .whereType<Map<String, dynamic>>()
            .map((item) => MatchInfo.fromJson(item))
            .toList();
        return ApiResult.success(matches);
      }
      if (payload is Map<String, dynamic> && payload['results'] is List) {
        final matches = (payload['results'] as List)
            .whereType<Map<String, dynamic>>()
            .map((item) => MatchInfo.fromJson(item))
            .toList();
        return ApiResult.success(matches);
      }
      return ApiResult.failure('Invalid team matches payload received from server.');
    } on DioException catch (exception, stackTrace) {
      return ApiResult.failure(DioErrorMapper.map(exception), stackTrace);
    } catch (error, stackTrace) {
      return ApiResult.failure(error.toString(), stackTrace);
    }
  }

  Future<ApiResult<List<StandingInfo>>> fetchTeamStandings(int teamId) async {
    try {
      final response = await _dioClient.dio.get('/api/teams/$teamId/standings');
      final payload = response.data;
      if (payload is List) {
        final standings = payload
            .whereType<Map<String, dynamic>>()
            .map((item) => StandingInfo(
                  leagueId: item['league_id'] as int? ?? int.tryParse(item['league_id']?.toString() ?? '') ?? 0,
                  season: item['season']?.toString() ?? '',
                  groupName: item['group_name']?.toString(),
                  description: item['description']?.toString(),
                  status: item['status']?.toString(),
                  form: item['form']?.toString(),
                  position: item['position'] as int? ?? int.tryParse(item['position']?.toString() ?? '') ?? 0,
                  teamId: item['team_id'] as int? ?? int.tryParse(item['team_id']?.toString() ?? '') ?? 0,
                  teamName: item['team_name']?.toString() ?? '',
                  teamLogo: item['team_logo']?.toString(),
                  points: item['points'] as int? ?? int.tryParse(item['points']?.toString() ?? '') ?? 0,
                  played: item['played'] as int? ?? int.tryParse(item['played']?.toString() ?? '') ?? 0,
                  won: item['won'] as int? ?? int.tryParse(item['won']?.toString() ?? '') ?? 0,
                  drawn: item['drawn'] as int? ?? int.tryParse(item['drawn']?.toString() ?? '') ?? 0,
                  lost: item['lost'] as int? ?? int.tryParse(item['lost']?.toString() ?? '') ?? 0,
                  goalsFor: item['goals_for'] as int? ?? int.tryParse(item['goals_for']?.toString() ?? '') ?? 0,
                  goalsAgainst: item['goals_against'] as int? ?? int.tryParse(item['goals_against']?.toString() ?? '') ?? 0,
                  goalDifference: item['goal_difference'] as int? ?? int.tryParse(item['goal_difference']?.toString() ?? '') ?? 0,
                ))
            .toList();
        return ApiResult.success(standings);
      }
      if (payload is Map<String, dynamic> && payload['results'] is List) {
        final standings = (payload['results'] as List)
            .whereType<Map<String, dynamic>>()
            .map((item) => StandingInfo(
                  leagueId: item['league_id'] as int? ?? int.tryParse(item['league_id']?.toString() ?? '') ?? 0,
                  season: item['season']?.toString() ?? '',
                  groupName: item['group_name']?.toString(),
                  description: item['description']?.toString(),
                  status: item['status']?.toString(),
                  form: item['form']?.toString(),
                  position: item['position'] as int? ?? int.tryParse(item['position']?.toString() ?? '') ?? 0,
                  teamId: item['team_id'] as int? ?? int.tryParse(item['team_id']?.toString() ?? '') ?? 0,
                  teamName: item['team_name']?.toString() ?? '',
                  teamLogo: item['team_logo']?.toString(),
                  points: item['points'] as int? ?? int.tryParse(item['points']?.toString() ?? '') ?? 0,
                  played: item['played'] as int? ?? int.tryParse(item['played']?.toString() ?? '') ?? 0,
                  won: item['won'] as int? ?? int.tryParse(item['won']?.toString() ?? '') ?? 0,
                  drawn: item['drawn'] as int? ?? int.tryParse(item['drawn']?.toString() ?? '') ?? 0,
                  lost: item['lost'] as int? ?? int.tryParse(item['lost']?.toString() ?? '') ?? 0,
                  goalsFor: item['goals_for'] as int? ?? int.tryParse(item['goals_for']?.toString() ?? '') ?? 0,
                  goalsAgainst: item['goals_against'] as int? ?? int.tryParse(item['goals_against']?.toString() ?? '') ?? 0,
                  goalDifference: item['goal_difference'] as int? ?? int.tryParse(item['goal_difference']?.toString() ?? '') ?? 0,
                ))
            .toList();
        return ApiResult.success(standings);
      }
      return ApiResult.failure('Invalid team standings payload received from server.');
    } on DioException catch (exception, stackTrace) {
      return ApiResult.failure(DioErrorMapper.map(exception), stackTrace);
    } catch (error, stackTrace) {
      return ApiResult.failure(error.toString(), stackTrace);
    }
  }

  Future<ApiResult<TeamSquadInfo>> fetchTeamSquad(int teamId) async {
    try {
      final response = await _dioClient.dio.get('/api/teams/$teamId/squad');
      final payload = response.data;
      if (payload is Map<String, dynamic>) {
        return ApiResult.success(TeamSquadInfo.fromJson(payload));
      }
      return ApiResult.failure('Invalid team squad payload received from server.');
    } on DioException catch (exception, stackTrace) {
      return ApiResult.failure(DioErrorMapper.map(exception), stackTrace);
    } catch (error, stackTrace) {
      return ApiResult.failure(error.toString(), stackTrace);
    }
  }

  Future<ApiResult<List<TeamFinishedMatch>>> fetchFinishedMatches(int teamId) async {
    try {
      final response = await _dioClient.dio.get('/api/teams/$teamId/finished-matches');
      final payload = response.data;
      if (payload is List) {
        final finishedMatches = payload
            .whereType<Map<String, dynamic>>()
            .map(TeamFinishedMatch.fromJson)
            .toList();
        return ApiResult.success(finishedMatches);
      }
      if (payload is Map<String, dynamic> && payload['results'] is List) {
        final finishedMatches = (payload['results'] as List)
            .whereType<Map<String, dynamic>>()
            .map(TeamFinishedMatch.fromJson)
            .toList();
        return ApiResult.success(finishedMatches);
      }
      return ApiResult.failure('Invalid team finished matches payload received from server.');
    } on DioException catch (exception, stackTrace) {
      return ApiResult.failure(DioErrorMapper.map(exception), stackTrace);
    } catch (error, stackTrace) {
      return ApiResult.failure(error.toString(), stackTrace);
    }
  }
}
