import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fover/core/network/api_result.dart';
import 'package:fover/features/auth/providers/auth_provider.dart';
import 'package:fover/features/home/domain/home_repository.dart';
import 'package:fover/features/home/domain/models/league_model.dart';
import 'package:fover/features/home/presentation/home_page.dart';
import 'package:fover/features/home/providers/date_selection_provider.dart';
import 'package:fover/features/home/providers/home_provider.dart';
import 'package:fover/features/home/providers/home_state.dart';

class _FakeAuthStorage implements AuthStorage {
  @override
  Future<void> clearSession() async {}

  @override
  Future<AuthSession?> readSession() async => null;

  @override
  Future<void> saveSession(AuthSession session) async {}
}

class _TestHomeNotifier extends HomeNotifier {
  _TestHomeNotifier(DateTime selectedDate) : super(_TestHomeRepository()) {
    state = HomeState(
      status: HomeStatus.loaded,
      selectedDate: selectedDate,
      leagues: const [],
    );
  }

  @override
  Future<void> loadMatches() async {}

  @override
  Future<void> refresh() async {}

  @override
  void startLiveRefresh() {}

  @override
  void stopLiveRefresh() {}

  @override
  Future<void> selectDate(DateTime date) async {
    state = state.copyWith(selectedDate: DateUtils.dateOnly(date));
  }
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
  testWidgets('HomePage keeps PageView and date selector in sync', (
    WidgetTester tester,
  ) async {
    final selectedDate = DateTime(2026, 6, 21);
    final dates = List.generate(15, (index) => DateTime(2026, 6, 14 + index));
    final container = ProviderContainer(
      overrides: [
        authStorageProvider.overrideWith((ref) => _FakeAuthStorage()),
        homeProvider.overrideWith((ref) => _TestHomeNotifier(selectedDate)),
        dateRangeProvider.overrideWith((ref) => dates),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(body: HomePage()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(container.read(homeProvider).selectedDate, selectedDate);

    await tester.tap(find.text('Tomorrow'));
    await tester.pumpAndSettle();

    expect(
      container.read(homeProvider).selectedDate,
      DateTime(2026, 6, 22),
    );

    await tester.fling(find.byType(PageView), const Offset(-800, 0), 1800);
    await tester.pumpAndSettle();

    final pageView = tester.widget<PageView>(find.byType(PageView));
    expect(pageView.controller?.page?.round(), 9);
    expect(
      container.read(homeProvider).selectedDate,
      DateTime(2026, 6, 23),
    );
  });
}