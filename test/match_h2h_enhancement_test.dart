import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fover/core/network/api_result.dart';
import 'package:fover/features/matches/domain/match_detail_repository.dart';
import 'package:fover/features/matches/domain/models/match_detail_model.dart';
import 'package:fover/features/matches/domain/models/match_event_model.dart';
import 'package:fover/features/matches/domain/models/match_h2h_model.dart';
import 'package:fover/features/matches/domain/models/match_lineup_model.dart';
import 'package:fover/features/matches/domain/models/match_odds_model.dart';
import 'package:fover/features/matches/domain/models/match_stats_model.dart';
import 'package:fover/features/matches/presentation/sections/match_detail_h2h_section.dart';
import 'package:fover/features/matches/providers/match_h2h_provider.dart';

class _FakeMatchDetailRepository implements MatchDetailRepository {
  _FakeMatchDetailRepository(this.h2hResult);

  final ApiResult<MatchH2HInfo> h2hResult;
  int h2hCallCount = 0;

  @override
  Future<ApiResult<MatchH2HInfo>> fetchMatchH2H(
    int matchId,
    int homeTeamId,
    int awayTeamId,
  ) async {
    h2hCallCount++;
    return h2hResult;
  }

  @override
  Future<ApiResult<MatchDetailInfo>> fetchMatchDetail(int matchId) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<List<MatchEventInfo>>> fetchMatchEvents(int matchId) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<MatchLineupInfo>> fetchMatchLineup(int matchId) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<MatchOddsInfo>> fetchMatchOdds(int matchId) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<MatchStatsInfo>> fetchMatchStats(int matchId) {
    throw UnimplementedError();
  }
}

MatchH2HInfo _buildH2HInfo({int count = 2}) {
  final meetings = List.generate(
    count,
    (index) => MatchH2HMeeting(
      date: DateTime(2026, 6, index + 1),
      leagueName: 'League $index',
      homeTeamId: 1,
      awayTeamId: 2,
      homeTeam: 'Home $index',
      awayTeam: 'Away $index',
      homeScore: 2,
      awayScore: 1,
      status: 'Match Finished',
      statusShort: 'FT',
      venue: 'Venue $index',
      result: 'FT',
    ),
  );

  return MatchH2HInfo(
    homeTeamId: 1,
    awayTeamId: 2,
    homeTeamName: 'Home',
    awayTeamName: 'Away',
    homeWins: 1,
    awayWins: 0,
    draws: 0,
    totalGoalsHome: 2,
    totalGoalsAway: 1,
    meetings: meetings,
  );
}

void main() {
  group('MatchH2HNotifier cache and refresh', () {
    test('reuses loaded data for FT without duplicate requests', () async {
      final repository = _FakeMatchDetailRepository(
        ApiResult.success(_buildH2HInfo()),
      );
      final notifier = MatchH2HNotifier(
        repository,
        const MatchH2HRequest(matchId: 10, homeTeamId: 1, awayTeamId: 2),
        () => 'FT',
      );

      await notifier.loadH2H();
      await notifier.loadH2H();

      expect(repository.h2hCallCount, 1);
      expect(notifier.state.status, MatchH2HStatus.loaded);
      expect(notifier.state.lastLoadedAt, isNotNull);
    });

    test('forceRefresh bypasses cache and fetches immediately', () async {
      final repository = _FakeMatchDetailRepository(
        ApiResult.success(_buildH2HInfo()),
      );
      final notifier = MatchH2HNotifier(
        repository,
        const MatchH2HRequest(matchId: 11, homeTeamId: 1, awayTeamId: 2),
        () => 'FT',
      );

      await notifier.loadH2H();
      await notifier.loadH2H(forceRefresh: true);

      expect(repository.h2hCallCount, 2);
    });

    test('applies cache for NS status within ttl window', () async {
      final repository = _FakeMatchDetailRepository(
        ApiResult.success(_buildH2HInfo()),
      );
      final notifier = MatchH2HNotifier(
        repository,
        const MatchH2HRequest(matchId: 12, homeTeamId: 1, awayTeamId: 2),
        () => 'NS',
      );

      await notifier.loadH2H();
      await notifier.loadH2H();

      expect(repository.h2hCallCount, 1);
    });
  });

  group('MatchDetailH2HSection league and show more', () {
    testWidgets('shows league name and expands to all matches via show more', (
      tester,
    ) async {
      final request = const MatchH2HRequest(
        matchId: 20,
        homeTeamId: 1,
        awayTeamId: 2,
      );
      final loadedState = MatchH2HState(
        status: MatchH2HStatus.loaded,
        h2h: _buildH2HInfo(count: 6),
      );
      final fakeRepository = _FakeMatchDetailRepository(
        ApiResult.success(_buildH2HInfo(count: 6)),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            matchH2HProvider(request).overrideWith((ref) {
              final notifier = MatchH2HNotifier(
                fakeRepository,
                request,
                () => 'FT',
              );
              notifier.state = loadedState;
              return notifier;
            }),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: MatchDetailH2HSection(
                  matchId: 20,
                  homeTeamId: 1,
                  awayTeamId: 2,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('League 0'), findsOneWidget);
      expect(find.text('Home 5'), findsNothing);
      expect(find.text('Show More'), findsOneWidget);

      await tester.ensureVisible(find.text('Show More'));
      await tester.tap(find.text('Show More'));
      await tester.pumpAndSettle();

      expect(find.text('Home 5'), findsOneWidget);
      expect(find.text('Show Less'), findsOneWidget);
    });
  });
}
