import 'package:flutter_test/flutter_test.dart';
import 'package:fover/features/ads/orchestration/ads_orchestrator.dart';
import 'package:fover/features/ads/providers/ads_runtime_provider.dart';

void main() {
  test('orchestrator exposes a stable request API without creating services', () async {
    final runtimeProvider = AdsRuntimeProvider();
    final orchestrator = AdsOrchestrator(runtimeProvider);

    await expectLater(orchestrator.requestBanner(), completes);
    await expectLater(orchestrator.requestInterstitial(), completes);
    await expectLater(orchestrator.requestRewarded(), completes);

    expect(runtimeProvider.sharedBannerService, isNull);
    expect(runtimeProvider.sharedInterstitialService, isNull);
    expect(runtimeProvider.sharedRewardedService, isNull);
  });
}
