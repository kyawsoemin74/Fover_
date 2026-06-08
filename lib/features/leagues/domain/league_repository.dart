import 'package:fover/core/network/api_result.dart';
import 'package:fover/features/leagues/domain/models/league_section_model.dart';

abstract class LeagueRepository {
  Future<ApiResult<List<LeagueSectionModel>>> fetchGroupedLeagues();
}
