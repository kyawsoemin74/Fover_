import 'package:fover/core/network/api_result.dart';
import 'package:fover/core/network/dio_client.dart';
import 'package:fover/features/home/domain/models/match_model.dart';
import 'package:fover/features/standings/domain/models/standing_model.dart';
import 'package:fover/features/team/models/team_finished_match.dart';
import 'package:fover/features/team/models/team_model.dart';
import 'package:fover/features/team/models/team_squad_model.dart';
import 'package:fover/features/team/repositories/team_api_service.dart';
import 'package:fover/features/team/repositories/team_repository.dart';

class TeamRepositoryImpl implements TeamRepository {
  TeamRepositoryImpl({DioClient? dioClient})
      : _apiService = TeamApiService(dioClient ?? DioClient.shared);

  final TeamApiService _apiService;

  @override
  Future<ApiResult<TeamModel>> fetchTeam(int teamId) {
    return _apiService.fetchTeam(teamId);
  }

  @override
  Future<ApiResult<List<MatchInfo>>> fetchTeamMatches(int teamId) {
    return _apiService.fetchTeamMatches(teamId);
  }

  @override
  Future<ApiResult<List<StandingInfo>>> fetchTeamStandings(int teamId) {
    return _apiService.fetchTeamStandings(teamId);
  }

  @override
  Future<ApiResult<TeamSquadInfo>> fetchTeamSquad(int teamId) {
    return _apiService.fetchTeamSquad(teamId);
  }

  @override
  Future<ApiResult<List<TeamFinishedMatch>>> fetchFinishedMatches(int teamId) {
    return _apiService.fetchFinishedMatches(teamId);
  }
}
