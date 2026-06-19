import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fover/core/network/dio_error_mapper.dart';
import 'package:fover/features/matches/data/models/match_detail_response_model.dart';
import 'package:fover/features/matches/domain/models/match_detail_model.dart';
import 'package:fover/features/standings/data/models/standing_response_model.dart';
import 'package:fover/features/standings/domain/models/standing_model.dart';
import 'package:fover/features/matches/presentation/pages/match_detail_page.dart';

void main() {
  group('Match detail tab architecture', () {
    test('does not surface raw backend error text for 404 responses', () {
      final exception = DioException(
        requestOptions: RequestOptions(path: '/match/stats/1'),
        response: Response<dynamic>(
          statusCode: 404,
          statusMessage: 'Not Found',
          requestOptions: RequestOptions(path: '/match/stats/1'),
          data: {'message': 'Statistics endpoint is unavailable'},
        ),
        type: DioExceptionType.badResponse,
      );

      final mapped = DioErrorMapper.map(exception);

      expect(mapped, isNot(contains('Statistics endpoint is unavailable')));
      expect(mapped, isNot(contains('DioException')));
      expect(mapped, isNot(contains('Not Found')));
    });

    test('parses backend flags into the domain model', () {
      final response = MatchDetailResponseModel.fromJson({
        'match_id': 1,
        'league_id': 2,
        'season': '2024',
        'league_name': 'League',
        'league_logo': '',
        'country_name': 'Country',
        'country_logo': '',
        'match_time': '2024-06-10T19:00:00.000',
        'status': 'FT',
        'elapsed': 90,
        'home_team': 'Home',
        'home_team_id': 10,
        'home_team_logo': '',
        'away_team': 'Away',
        'away_team_id': 20,
        'away_team_logo': '',
        'home_score': 2,
        'away_score': 1,
        'has_events': true,
        'has_stats': true,
        'has_lineups': true,
        'has_odds': true,
        'has_h2h': true,
        'has_standings': false,
        'is_knockout': true,
        'has_bracket': true,
      });

      final detail = response.toDomain();

      expect(detail.hasLineups, isTrue);
      expect(detail.hasOdds, isTrue);
      expect(detail.hasH2H, isTrue);
      expect(detail.hasStandings, isFalse);
      expect(detail.hasEvents, isTrue);
      expect(detail.hasStats, isTrue);
      expect(detail.isKnockout, isTrue);
      expect(detail.hasBracket, isTrue);
    });

    test('parses standings group information', () {
      final matchResponse = MatchDetailResponseModel.fromJson({
        'match_id': 1,
        'league_id': 2,
        'season': '2024',
        'league_name': 'League',
        'league_logo': '',
        'country_name': 'Country',
        'country_logo': '',
        'match_time': '2024-06-10T19:00:00.000',
        'status': 'FT',
        'elapsed': 90,
        'home_team': 'Home',
        'home_team_id': 10,
        'home_team_logo': '',
        'away_team': 'Away',
        'away_team_id': 20,
        'away_team_logo': '',
        'home_score': 2,
        'away_score': 1,
        'has_events': false,
        'has_stats': false,
      });

      final detail = matchResponse.toDomain();
      expect(detail.leagueId, 2);

      final standingResponse = StandingResponseModel.fromJson({
        'league_id': 2,
        'season': '2024',
        'group_name': 'Group K',
        'description': 'Round of 32',
        'status': 'same',
        'form': 'D',
        'position': 1,
        'team_id': 11,
        'team_name': 'Team',
        'team_logo': '',
        'points': 3,
        'played': 1,
        'won': 1,
        'drawn': 0,
        'lost': 0,
        'goals_for': 1,
        'goals_against': 0,
        'goal_difference': 1,
      });

      final standing = standingResponse.toDomain();
      expect(standing.groupName, 'Group K');
      expect(standing.description, 'Round of 32');
      expect(standing.status, 'same');
      expect(standing.form, 'D');
    });

    test('supports detecting and filtering a current group from standings data', () {
      final standings = <StandingInfo>[
        const StandingInfo(
          leagueId: 1,
          season: '2024',
          groupName: 'Group K',
          position: 1,
          teamId: 11,
          teamName: 'Team A',
          points: 3,
          played: 1,
          won: 1,
          drawn: 0,
          lost: 0,
          goalsFor: 1,
          goalsAgainst: 0,
          goalDifference: 1,
        ),
        const StandingInfo(
          leagueId: 1,
          season: '2024',
          groupName: 'Group L',
          position: 2,
          teamId: 12,
          teamName: 'Team B',
          points: 0,
          played: 1,
          won: 0,
          drawn: 0,
          lost: 1,
          goalsFor: 0,
          goalsAgainst: 1,
          goalDifference: -1,
        ),
      ];

      StandingInfo? currentTeamRow;
      for (final row in standings) {
        if (row.teamId == 11 || row.teamId == 999) {
          currentTeamRow = row;
          break;
        }
      }

      expect(currentTeamRow?.groupName, 'Group K');

      final detectedGroup = currentTeamRow?.groupName;
      final filteredStandings = detectedGroup == null
          ? standings
          : standings.where((row) => row.groupName == detectedGroup).toList();

      expect(filteredStandings, hasLength(1));
      expect(filteredStandings.first.groupName, 'Group K');
    });

    test('builds the expected tab order from match flags', () {
      final detail = MatchDetailInfo(
        matchId: 1,
        leagueId: 2,
        season: '2024',
        leagueName: 'League',
        leagueLogo: '',
        countryName: 'Country',
        countryLogo: '',
        matchTime: '19:00',
        status: 'FT',
        elapsed: 90,
        homeTeam: 'Home',
        homeTeamId: 10,
        homeTeamLogo: '',
        awayTeam: 'Away',
        awayTeamId: 20,
        awayTeamLogo: '',
        homeScore: 2,
        awayScore: 1,
        hasLineups: true,
        hasOdds: true,
        hasH2H: true,
        hasStandings: false,
        isKnockout: true,
        hasBracket: true,
      );

      final tabs = buildMatchDetailTabs(detail);

      expect(
        tabs,
        equals([
          MatchDetailTab.details,
          MatchDetailTab.lineups,
          MatchDetailTab.odds,
          MatchDetailTab.knockout,
          MatchDetailTab.h2h,
        ]),
      );
    });
  });
}
