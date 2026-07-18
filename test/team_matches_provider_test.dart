import 'package:flutter_test/flutter_test.dart';
import 'package:fover/core/network/api_result.dart';
import 'package:fover/features/home/domain/models/match_model.dart';
import 'package:fover/features/standings/domain/models/standing_model.dart';
import 'package:fover/features/team/models/team_finished_match.dart';
import 'package:fover/features/team/models/team_model.dart';
import 'package:fover/features/team/models/team_squad_model.dart';
import 'package:fover/features/team/providers/team_provider.dart';
import 'package:fover/features/team/providers/team_state.dart';
import 'package:fover/features/team/repositories/team_repository.dart';

class _FakeTeamRepository implements TeamRepository {
  @override
  Future<ApiResult<TeamModel>> fetchTeam(int teamId) async {
    return ApiResult.success(
      const TeamModel(teamId: 1, name: 'Test Team'),
    );
  }

  @override
  Future<ApiResult<List<MatchInfo>>> fetchTeamMatches(int teamId) async {
    return ApiResult.success([
      const MatchInfo(
        teamA: 'Home',
        teamB: 'Away',
        score: '1 - 0',
        kickOffTime: '18:00',
        status: 'FT',
      ),
    ]);
  }

  @override
  Future<ApiResult<List<StandingInfo>>> fetchTeamStandings(int teamId) async {
    return ApiResult.success(const []);
  }

  @override
  Future<ApiResult<TeamSquadInfo>> fetchTeamSquad(int teamId) async {
    return ApiResult.success(
      const TeamSquadInfo(
        teamId: 1,
        teamName: 'Test Team',
        players: [],
      ),
    );
  }

  @override
  Future<ApiResult<List<TeamFinishedMatch>>> fetchFinishedMatches(int teamId) async {
    return ApiResult.success(const []);
  }
}

void main() {
  test('TeamNotifier loads matches from the team repository', () async {
    final repository = _FakeTeamRepository();
    final notifier = TeamNotifier(repository);

    await notifier.loadMatches(1);

    expect(notifier.state.matchesStatus, TeamMatchesStatus.loaded);
    expect(notifier.state.matches, hasLength(1));
    expect(notifier.state.matches.first.teamA, 'Home');
  });
}
