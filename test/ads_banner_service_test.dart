import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:fover/features/ads/services/banner_service.dart';
import 'package:fover/features/ads/services/sdk_adapter.dart';

class FakeSDKAdapterPlatform implements SDKAdapterPlatform {
  int createBannerAdCallCount = 0;

  @override
  Future<void> dispose() async {}

  @override
  Future<void> initialize({String? appId}) async {}

  @override
  Future<void> preloadBanner({required String adUnitId}) async {}

  @override
  Future<void> preloadInterstitial({required String adUnitId}) async {}

  @override
  Future<void> preloadRewarded({required String adUnitId}) async {}

  @override
  Future<BannerAd?> createBannerAd({required String adUnitId}) async {
    createBannerAdCallCount++;
    return null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('initialize creates a banner ad when a unit id is provided', () async {
    final platform = FakeSDKAdapterPlatform();
    final service = BannerService(sdkAdapter: SDKAdapter(platform: platform));

    await service.initialize(adUnitId: 'test-banner-id');

    expect(platform.createBannerAdCallCount, 1);
    expect(service.status, BannerServiceStatus.ready);
  });
}
