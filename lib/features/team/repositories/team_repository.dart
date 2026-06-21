import 'package:fover/core/network/api_result.dart';
import 'package:fover/features/team/models/team_model.dart';

abstract class TeamRepository {
  Future<ApiResult<TeamModel>> fetchTeam(int teamId);
}
