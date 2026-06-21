import 'package:fover/core/network/api_result.dart';
import 'package:fover/core/network/dio_client.dart';
import 'package:fover/features/team/models/team_model.dart';
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
}
