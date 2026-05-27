import 'package:fover/core/network/api_result.dart';
import 'package:fover/features/home/domain/models/league_model.dart';

abstract class HomeRepository {
  Future<ApiResult<List<LeagueInfo>>> fetchLeagueMatches(
    DateTime date, {
    bool forceRefresh = false,
  });
}
