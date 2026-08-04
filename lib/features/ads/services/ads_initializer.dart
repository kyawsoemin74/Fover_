import 'package:flutter/foundation.dart';
import 'package:fover/features/ads/config/ads_config_model.dart';
import 'package:fover/features/ads/providers/ads_runtime_provider.dart';
import 'package:fover/features/ads/services/banner_service.dart';
import 'package:fover/features/ads/services/interstitial_service.dart';
import 'package:fover/features/ads/services/rewarded_service.dart';
import 'package:fover/features/ads/services/sdk_adapter.dart';

class AdsInitializer {
  AdsInitializer({
    SDKAdapter? sdkAdapter,
    BannerService? bannerService,
    InterstitialService? interstitialService,
    RewardedService? rewardedService,
  }) : _sdkAdapter = sdkAdapter ?? SDKAdapter(),
       _bannerService = bannerService ?? BannerService(sdkAdapter: sdkAdapter),
       _interstitialService = interstitialService,
       _rewardedService = rewardedService;

  final SDKAdapter _sdkAdapter;
  final BannerService _bannerService;
  final InterstitialService? _interstitialService;
  final RewardedService? _rewardedService;

  bool _initialized = false;

  bool get isInitialized => _initialized;

  Future<void> initialize(
    dynamic config, {
    String? bannerAdUnitId,
    String? interstitialAdUnitId,
    String? rewardedAdUnitId,
    AdsRuntimeProvider? runtimeProvider,
  }) async {
    if (_initialized) {
      return;
    }

    final resolvedConfig = config is AdsConfigModel ? config : null;
    final resolvedBannerAdUnitId = resolvedConfig != null
        ? _selectAdUnitId(resolvedConfig.bannerAndroid, resolvedConfig.bannerIos)
        : (bannerAdUnitId ?? '');
    final resolvedInterstitialAdUnitId = resolvedConfig != null
        ? _selectAdUnitId(resolvedConfig.interstitialAndroid, resolvedConfig.interstitialIos)
        : (interstitialAdUnitId ?? '');
    final resolvedRewardedAdUnitId = resolvedConfig != null
        ? _selectAdUnitId(resolvedConfig.rewardedAndroid, resolvedConfig.rewardedIos)
        : (rewardedAdUnitId ?? '');

    try {
      await _sdkAdapter.initialize();

      if (runtimeProvider != null) {
        runtimeProvider.setLoading();
      }

      if (resolvedBannerAdUnitId.isNotEmpty && !_initialized) {
        if (_bannerService.status == BannerServiceStatus.ready) {
          return;
        }

        await _bannerService.initialize(adUnitId: resolvedBannerAdUnitId);
        if (runtimeProvider != null) {
          runtimeProvider.registerSharedBannerService(_bannerService);
          runtimeProvider.setReady(
            bannerAvailable: _bannerService.bannerAd != null,
            interstitialAvailable: false,
            rewardedAvailable: false,
          );
        }
      } else if (resolvedBannerAdUnitId.isEmpty && runtimeProvider != null) {
        runtimeProvider.setError('Banner ad unit id is not available.');
      }

      final interstitialService = runtimeProvider?.sharedInterstitialService ?? _interstitialService ?? InterstitialService(sdkAdapter: _sdkAdapter);
      if (runtimeProvider != null && runtimeProvider.sharedInterstitialService == null) {
        runtimeProvider.registerSharedInterstitialService(interstitialService);
      }

      await interstitialService.initialize(adUnitId: resolvedInterstitialAdUnitId);
      final rewardedService = runtimeProvider?.sharedRewardedService ?? _rewardedService ?? RewardedService(sdkAdapter: _sdkAdapter);
      if (runtimeProvider != null && runtimeProvider.sharedRewardedService == null) {
        runtimeProvider.registerSharedRewardedService(rewardedService);
      }

      await rewardedService.initialize(adUnitId: resolvedRewardedAdUnitId);
      _initialized = true;
    } catch (error) {
      if (runtimeProvider != null) {
        runtimeProvider.setError(error.toString());
      }
      _initialized = false;
      rethrow;
    }
  }

  String _selectAdUnitId(String androidValue, String iosValue) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return androidValue;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return iosValue;
    }
    return androidValue.isNotEmpty ? androidValue : iosValue;
  }
}
