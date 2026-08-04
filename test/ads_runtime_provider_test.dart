import 'package:flutter_test/flutter_test.dart';
import 'package:fover/features/ads/providers/ads_runtime_provider.dart';
import 'package:fover/features/ads/services/banner_service.dart';
import 'package:fover/features/ads/services/sdk_adapter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class FakeSDKAdapterPlatform implements SDKAdapterPlatform {
  @override
  Future<void> initialize({String? appId}) async {}

  @override
  Future<void> dispose() async {}

  @override
  Future<void> preloadBanner({required String adUnitId}) async {}

  @override
  Future<void> preloadInterstitial({required String adUnitId}) async {}

  @override
  Future<void> preloadRewarded({required String adUnitId}) async {}

  @override
  Future<BannerAd?> createBannerAd({required String adUnitId}) async => null;
}

void main() {
  test('disposing runtime provider disposes the shared banner service', () {
    final provider = AdsRuntimeProvider();
    final service = BannerService(sdkAdapter: SDKAdapter(platform: FakeSDKAdapterPlatform()));

    provider.registerSharedBannerService(service);
    provider.dispose();

    expect(service.status, BannerServiceStatus.disposed);
  });
}
