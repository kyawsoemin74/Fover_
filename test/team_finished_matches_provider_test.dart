import 'package:flutter_test/flutter_test.dart';
import 'package:fover/core/network/api_result.dart';
import 'package:fover/features/home/domain/models/match_model.dart';
import 'package:fover/features/standings/domain/models/standing_model.dart';
import 'package:fover/features/team/models/team_finished_match.dart';
import 'package:fover/features/team/models/team_model.dart';
import 'package:fover/features/team/models/team_squad_model.dart';
import 'package:fover/features/team/providers/team_finished_matches_provider.dart';
import 'package:fover/features/team/providers/team_finished_matches_state.dart';
import 'package:fover/features/team/repositories/team_repository.dart';

void main() {
  group('TeamFinishedMatchesNotifier', () {
    test('filters to completed matches, sorts newest first, and limits to 5', () async {
      final notifier = TeamFinishedMatchesNotifier(_FakeTeamRepository(const [
        TeamFinishedMatch(matchId: 1, status: 'FT', date: '2024-01-01T00:00:00.000Z'),
        TeamFinishedMatch(matchId: 2, status: 'PST', date: '2024-02-01T00:00:00.000Z'),
        TeamFinishedMatch(matchId: 3, status: 'AET', date: '2024-03-01T00:00:00.000Z'),
        TeamFinishedMatch(matchId: 4, status: 'FT', date: '2024-04-01T00:00:00.000Z'),
        TeamFinishedMatch(matchId: 5, status: 'PEN', date: '2024-05-01T00:00:00.000Z'),
        TeamFinishedMatch(matchId: 6, status: 'FT', date: '2024-06-01T00:00:00.000Z'),
        TeamFinishedMatch(matchId: 7, status: 'NS', date: '2024-07-01T00:00:00.000Z'),
      ]), 42);

      await notifier.load(forceRefresh: true);

      expect(notifier.state.status, TeamFinishedMatchesStatus.loaded);
      expect(notifier.state.matches.length, 5);
      expect(notifier.state.matches.map((match) => match.matchId).toList(), [6, 5, 4, 3, 1]);
    });

    test('parses home and away logo URLs from the api payload', () {
      final match = TeamFinishedMatch.fromJson({
        'home_team_id': 10,
        'away_team_id': 20,
        'home_team_name': 'Bahia',
        'away_team_name': 'Corinthians',
        'home_team_logo': 'https://media.api-sports.io/football/teams/10.png',
        'away_team_logo': 'https://media.api-sports.io/football/teams/20.png',
      });

      expect(match.homeTeamLogo, 'https://media.api-sports.io/football/teams/10.png');
      expect(match.awayTeamLogo, 'https://media.api-sports.io/football/teams/20.png');
    });
  });
}

class _FakeTeamRepository implements TeamRepository {
  _FakeTeamRepository(this._matches);

  final List<TeamFinishedMatch> _matches;

  @override
  Future<ApiResult<TeamModel>> fetchTeam(int teamId) async {
    return ApiResult.success(const TeamModel(teamId: 42, name: 'Test'));
  }

  @override
  Future<ApiResult<List<MatchInfo>>> fetchTeamMatches(int teamId) async {
    return ApiResult.success(const []);
  }

  @override
  Future<ApiResult<List<StandingInfo>>> fetchTeamStandings(int teamId) async {
    return ApiResult.success(const []);
  }

  @override
  Future<ApiResult<TeamSquadInfo>> fetchTeamSquad(int teamId) async {
    return ApiResult.success(const TeamSquadInfo(teamId: 42, teamName: 'Test', players: []));
  }

  @override
  Future<ApiResult<List<TeamFinishedMatch>>> fetchFinishedMatches(int teamId) async {
    return ApiResult.success(_matches);
  }
}
