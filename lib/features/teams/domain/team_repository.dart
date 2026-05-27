import 'package:fover/core/network/api_result.dart';
import 'package:fover/features/teams/domain/models/team_model.dart';

abstract class TeamRepository {
  Future<ApiResult<TeamInfo>> fetchTeam(int teamId, {bool forceRefresh = false});
}
