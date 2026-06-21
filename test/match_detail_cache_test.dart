import 'package:flutter_test/flutter_test.dart';
import 'package:fover/core/network/api_result.dart';
import 'package:fover/features/matches/domain/match_detail_repository.dart';
import 'package:fover/features/matches/domain/models/match_detail_model.dart';
import 'package:fover/features/matches/domain/models/match_event_model.dart';
import 'package:fover/features/matches/domain/models/match_h2h_model.dart';
import 'package:fover/features/matches/domain/models/match_lineup_model.dart';
import 'package:fover/features/matches/domain/models/match_odds_model.dart';
import 'package:fover/features/matches/domain/models/match_stats_model.dart';
import 'package:fover/features/matches/providers/match_events_provider.dart';
import 'package:fover/features/matches/providers/match_stats_provider.dart';

void main() {
  group('Match Detail cache guards', () {
    test('keeps finished events cached across repeated loads', () async {
      final repository = _FakeMatchDetailRepository(
        matchStatus: 'FT',
        eventsResult: ApiResult.success([
          const MatchEventInfo(
            minute: 10,
            extraMinute: 0,
            period: MatchEventPeriod.firstHalf,
            teamId: 1,
            teamName: 'Home',
            playerName: 'Player',
            playerNumber: 9,
            type: MatchEventType.goal,
            detail: 'Goal',
            description: 'Goal',
            assistName: null,
            raw: {},
          ),
        ]),
        statsResult: ApiResult.success(const MatchStatsInfo(
          homePossession: 60,
          awayPossession: 40,
          homeShots: 10,
          awayShots: 5,
          homeShotsOnTarget: 4,
          awayShotsOnTarget: 2,
        )),
      );

      final notifier = MatchEventsNotifier(repository, 1, () => 'FT');

      await notifier.loadEvents();
      await notifier.loadEvents();

      expect(repository.eventsCalls, 1);
      expect(notifier.state.status, MatchEventsStatus.loaded);
    });

    test('refreshes live events after cache ttl expires', () async {
      final repository = _FakeMatchDetailRepository(
        matchStatus: 'LIVE',
        eventsResult: ApiResult.success([
          const MatchEventInfo(
            minute: 20,
            extraMinute: 0,
            period: MatchEventPeriod.firstHalf,
            teamId: 1,
            teamName: 'Home',
            playerName: 'Player',
            playerNumber: 9,
            type: MatchEventType.goal,
            detail: 'Goal',
            description: 'Goal',
            assistName: null,
            raw: {},
          ),
        ]),
        statsResult: ApiResult.success(const MatchStatsInfo(
          homePossession: 60,
          awayPossession: 40,
          homeShots: 10,
          awayShots: 5,
          homeShotsOnTarget: 4,
          awayShotsOnTarget: 2,
        )),
      );

      final notifier = MatchEventsNotifier(repository, 1, () => 'LIVE');

      await notifier.loadEvents();
      notifier.state = notifier.state.copyWith(
        status: MatchEventsStatus.loaded,
        lastLoadedAt: DateTime.now().subtract(const Duration(seconds: 61)),
      );
      await notifier.loadEvents();

      expect(repository.eventsCalls, 2);
    });

    test('bypasses cached events on force refresh', () async {
      final repository = _FakeMatchDetailRepository(
        matchStatus: 'FT',
        eventsResult: ApiResult.success([
          const MatchEventInfo(
            minute: 42,
            extraMinute: 0,
            period: MatchEventPeriod.firstHalf,
            teamId: 1,
            teamName: 'Home',
            playerName: 'Player',
            playerNumber: 9,
            type: MatchEventType.goal,
            detail: 'Goal',
            description: 'Goal',
            assistName: null,
            raw: {},
          ),
        ]),
        statsResult: ApiResult.success(const MatchStatsInfo(
          homePossession: 60,
          awayPossession: 40,
          homeShots: 10,
          awayShots: 5,
          homeShotsOnTarget: 4,
          awayShotsOnTarget: 2,
        )),
      );

      final notifier = MatchEventsNotifier(repository, 1, () => 'FT');

      await notifier.loadEvents();
      await notifier.loadEvents(forceRefresh: true);

      expect(repository.eventsCalls, 2);
    });

    test('keeps finished statistics cached across repeated loads', () async {
      final repository = _FakeMatchDetailRepository(
        matchStatus: 'FT',
        eventsResult: ApiResult.success(const <MatchEventInfo>[]),
        statsResult: ApiResult.success(const MatchStatsInfo(
          homePossession: 60,
          awayPossession: 40,
          homeShots: 10,
          awayShots: 5,
          homeShotsOnTarget: 4,
          awayShotsOnTarget: 2,
        )),
      );

      final notifier = MatchStatsNotifier(repository, 1, () => 'FT');

      await notifier.loadStats();
      await notifier.loadStats();

      expect(repository.statsCalls, 1);
      expect(notifier.state.status, MatchStatsStatus.loaded);
    });

    test('bypasses cached statistics on force refresh', () async {
      final repository = _FakeMatchDetailRepository(
        matchStatus: 'FT',
        eventsResult: ApiResult.success(const <MatchEventInfo>[]),
        statsResult: ApiResult.success(const MatchStatsInfo(
          homePossession: 55,
          awayPossession: 45,
          homeShots: 8,
          awayShots: 7,
          homeShotsOnTarget: 3,
          awayShotsOnTarget: 3,
        )),
      );

      final notifier = MatchStatsNotifier(repository, 1, () => 'FT');

      await notifier.loadStats();
      await notifier.loadStats(forceRefresh: true);

      expect(repository.statsCalls, 2);
    });
  });
}

class _FakeMatchDetailRepository implements MatchDetailRepository {
  _FakeMatchDetailRepository({
    required this.matchStatus,
    required this.eventsResult,
    required this.statsResult,
  });

  final String matchStatus;
  final ApiResult<List<MatchEventInfo>> eventsResult;
  final ApiResult<MatchStatsInfo> statsResult;

  var eventsCalls = 0;
  var statsCalls = 0;

  @override
  Future<ApiResult<MatchDetailInfo>> fetchMatchDetail(int matchId) async {
    return ApiResult.success(
      MatchDetailInfo(
        matchId: matchId,
        leagueId: 1,
        season: '2024',
        leagueName: 'League',
        leagueLogo: '',
        countryName: 'Country',
        countryLogo: '',
        matchTime: '19:00',
        status: matchStatus,
        elapsed: 90,
        homeTeam: 'Home',
        homeTeamId: 1,
        homeTeamLogo: '',
        awayTeam: 'Away',
        awayTeamId: 2,
        awayTeamLogo: '',
        homeScore: 1,
        awayScore: 0,
      ),
    );
  }

  @override
  Future<ApiResult<List<MatchEventInfo>>> fetchMatchEvents(int matchId) async {
    eventsCalls += 1;
    return eventsResult;
  }

  @override
  Future<ApiResult<MatchLineupInfo>> fetchMatchLineup(int matchId) async {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<MatchOddsInfo>> fetchMatchOdds(int matchId) async {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<MatchH2HInfo>> fetchMatchH2H(int matchId, int homeTeamId, int awayTeamId) async {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<MatchStatsInfo>> fetchMatchStats(int matchId) async {
    statsCalls += 1;
    return statsResult;
  }
}