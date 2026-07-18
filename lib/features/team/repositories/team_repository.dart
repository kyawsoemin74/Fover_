import 'package:fover/core/network/api_result.dart';
import 'package:fover/features/home/domain/models/match_model.dart';
import 'package:fover/features/standings/domain/models/standing_model.dart';
import 'package:fover/features/team/models/team_finished_match.dart';
import 'package:fover/features/team/models/team_model.dart';
import 'package:fover/features/team/models/team_squad_model.dart';

abstract class TeamRepository {
  Future<ApiResult<TeamModel>> fetchTeam(int teamId);
  Future<ApiResult<List<MatchInfo>>> fetchTeamMatches(int teamId);
  Future<ApiResult<List<StandingInfo>>> fetchTeamStandings(int teamId) async {
    return ApiResult.failure('Not implemented');
  }
  Future<ApiResult<TeamSquadInfo>> fetchTeamSquad(int teamId) async {
    return ApiResult.failure('Not implemented');
  }
  Future<ApiResult<List<TeamFinishedMatch>>> fetchFinishedMatches(int teamId) async {
    return ApiResult.failure('Not implemented');
  }
}
