import 'package:fover/features/ads/providers/ads_runtime_provider.dart';

class AdsOrchestrator {
  AdsOrchestrator(this._runtimeProvider);

  final AdsRuntimeProvider _runtimeProvider;

  Future<void> requestBanner() async {
    final service = _runtimeProvider.sharedBannerService;
    if (service == null) {
      return;
    }
  }

  Future<void> requestInterstitial() async {
    final service = _runtimeProvider.sharedInterstitialService;
    if (service == null) {
      return;
    }
  }

  Future<void> requestRewarded() async {
    final service = _runtimeProvider.sharedRewardedService;
    if (service == null) {
      return;
    }
  }
}
