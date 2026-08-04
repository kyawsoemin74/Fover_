import 'package:google_mobile_ads/google_mobile_ads.dart';

enum SDKAdapterStatus {
  uninitialized,
  initializing,
  ready,
  failed,
  disposed,
}

abstract class SDKAdapterPlatform {
  Future<void> initialize({String? appId});
  Future<void> dispose();
  Future<void> preloadBanner({required String adUnitId});
  Future<void> preloadInterstitial({required String adUnitId});
  Future<void> preloadRewarded({required String adUnitId});
  Future<BannerAd?> createBannerAd({required String adUnitId});
}

class GoogleMobileAdsSDKAdapterPlatform implements SDKAdapterPlatform {
  const GoogleMobileAdsSDKAdapterPlatform();

  @override
  Future<void> initialize({String? appId}) async {
    await MobileAds.instance.initialize();
  }

  @override
  Future<void> dispose() async {
    return;
  }

  @override
  Future<void> preloadBanner({required String adUnitId}) async {
    return;
  }

  @override
  Future<void> preloadInterstitial({required String adUnitId}) async {
    return;
  }

  @override
  Future<void> preloadRewarded({required String adUnitId}) async {
    return;
  }

  @override
  Future<BannerAd?> createBannerAd({required String adUnitId}) async {
    final ad = BannerAd(
      adUnitId: adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(),
    );

    await ad.load();
    return ad;
  }
}

class SDKAdapter {
  SDKAdapter({SDKAdapterPlatform? platform})
    : _platform = platform ?? const GoogleMobileAdsSDKAdapterPlatform();

  final SDKAdapterPlatform _platform;
  SDKAdapterStatus _status = SDKAdapterStatus.uninitialized;
  

  SDKAdapterStatus get status => _status;
  bool get isReady => _status == SDKAdapterStatus.ready;
  bool get isInitialized => _status == SDKAdapterStatus.ready;

  Future<void> initialize({String? appId}) async {
    if (_status == SDKAdapterStatus.ready) {
      return;
    }

    _status = SDKAdapterStatus.initializing;
    

    try {
      await _platform.initialize(appId: appId);
      _status = SDKAdapterStatus.ready;
    } catch (_) {
      _status = SDKAdapterStatus.failed;
      rethrow;
    }
  }

  Future<void> dispose() async {
    if (_status == SDKAdapterStatus.disposed) {
      return;
    }

    await _platform.dispose();
    _status = SDKAdapterStatus.disposed;
  }

  Future<void> preloadBanner({required String adUnitId}) async {
    if (_status != SDKAdapterStatus.ready) {
      throw StateError('SDKAdapter must be initialized before preloading banner ads.');
    }

    await _platform.preloadBanner(adUnitId: adUnitId);
  }

  Future<void> preloadInterstitial({required String adUnitId}) async {
    if (_status != SDKAdapterStatus.ready) {
      throw StateError('SDKAdapter must be initialized before preloading interstitial ads.');
    }

    await _platform.preloadInterstitial(adUnitId: adUnitId);
  }

  Future<void> preloadRewarded({required String adUnitId}) async {
    if (_status != SDKAdapterStatus.ready) {
      throw StateError('SDKAdapter must be initialized before preloading rewarded ads.');
    }

    await _platform.preloadRewarded(adUnitId: adUnitId);
  }

  Future<BannerAd?> createBannerAd({required String adUnitId}) async {
    if (_status != SDKAdapterStatus.ready) {
      throw StateError('SDKAdapter must be initialized before creating banner ads.');
    }

    return _platform.createBannerAd(adUnitId: adUnitId);
  }
}
