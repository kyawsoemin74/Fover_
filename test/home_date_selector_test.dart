import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fover/core/network/api_result.dart';
import 'package:fover/features/home/domain/home_repository.dart';
import 'package:fover/features/home/domain/models/league_model.dart';
import 'package:fover/features/home/presentation/widgets/home_date_selector.dart';
import 'package:fover/features/home/providers/date_selection_provider.dart';
import 'package:fover/features/home/providers/home_provider.dart';
import 'package:fover/features/home/providers/home_state.dart';

class _TestHomeNotifier extends HomeNotifier {
  _TestHomeNotifier(DateTime selectedDate) : super(_TestHomeRepository()) {
    state = HomeState(
      status: HomeStatus.loaded,
      selectedDate: selectedDate,
    );
  }

  @override
  Future<void> loadMatches() async {}

  @override
  void startLiveRefresh() {}

  @override
  void stopLiveRefresh() {}
}

class _TestHomeRepository implements HomeRepository {
  @override
  Future<ApiResult<List<LeagueInfo>>> fetchLeagueMatches(
    DateTime date, {
    bool forceRefresh = false,
  }) async {
    return ApiResult.success(<LeagueInfo>[]);
  }
}

void main() {
  testWidgets('HomeDateSelector centers today and clamps at edges', (
    WidgetTester tester,
  ) async {
    final selectedDate = DateTime(2026, 6, 21);
    final dates = List.generate(15, (index) => DateTime(2026, 6, 14 + index));

    await tester.binding.setSurfaceSize(const Size(360, 120));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeProvider.overrideWith((ref) => _TestHomeNotifier(selectedDate)),
          dateRangeProvider.overrideWith((ref) => dates),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 360,
              child: HomeDateSelector(),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final todayTile = find.ancestor(
      of: find.text('Today'),
      matching: find.byType(AnimatedContainer),
    );
    expect(todayTile, findsOneWidget);
    expect(
      tester.getRect(todayTile).center.dx,
      moreOrLessEquals(180, epsilon: 8),
    );

    await tester.drag(find.byType(ListView), const Offset(1000, 0));
    await tester.pumpAndSettle();

    final firstTile = find.ancestor(
      of: find.text('14'),
      matching: find.byType(AnimatedContainer),
    );
    expect(firstTile, findsOneWidget);
    expect(tester.getRect(firstTile).left, lessThanOrEqualTo(1));

    await tester.drag(find.byType(ListView), const Offset(-2000, 0));
    await tester.pumpAndSettle();

    final lastTile = find.ancestor(
      of: find.text('28'),
      matching: find.byType(AnimatedContainer),
    );
    expect(lastTile, findsOneWidget);
    expect(
      tester.getRect(lastTile).right,
      moreOrLessEquals(360, epsilon: 1),
    );
  });
}