import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fover/core/network/api_result.dart';
import 'package:fover/features/home/domain/home_repository.dart';
import 'package:fover/features/home/domain/models/league_model.dart';
import 'package:fover/features/home/providers/home_provider.dart';
import 'package:fover/main.dart';

class _TestHomeNotifier extends HomeNotifier {
  _TestHomeNotifier() : super(_TestHomeRepository());

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
  testWidgets('Home page basic render test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeProvider.overrideWith((ref) => _TestHomeNotifier()),
        ],
        child: const FoverApp(),
      ),
    );

    expect(find.byType(FoverApp), findsOneWidget);
  });
}
