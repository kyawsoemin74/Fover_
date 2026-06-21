import 'package:dio/dio.dart';
import 'package:fover/core/constants/api_constants.dart';
import 'package:fover/core/network/api_result.dart';
import 'package:fover/core/network/dio_client.dart';
import 'package:fover/core/network/dio_error_mapper.dart';
import 'package:fover/features/team/models/team_model.dart';

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
}
