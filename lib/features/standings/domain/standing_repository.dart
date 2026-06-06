import 'package:fover/core/network/api_result.dart';
import 'package:fover/features/standings/domain/models/standing_model.dart';

abstract class StandingRepository {
  Future<ApiResult<List<StandingInfo>>> fetchStandings(
    int leagueId,
    String season,
  );
}
