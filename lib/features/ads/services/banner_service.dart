import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:fover/features/ads/services/sdk_adapter.dart';

enum BannerServiceStatus {
  idle,
  loading,
  ready,
  failed,
  disposed,
}

class BannerService {
  BannerService({SDKAdapter? sdkAdapter}) : _sdkAdapter = sdkAdapter ?? SDKAdapter();

  final SDKAdapter _sdkAdapter;
  BannerServiceStatus _status = BannerServiceStatus.idle;
  String? _adUnitId;
  BannerAd? _bannerAd;

  BannerServiceStatus get status => _status;
  bool get isReady => _status == BannerServiceStatus.ready;
  BannerAd? get bannerAd => _bannerAd;

  Future<void> initialize({required String adUnitId}) async {
    if (adUnitId.isEmpty) {
      throw StateError('BannerService requires a non-empty ad unit id.');
    }

    if (_status == BannerServiceStatus.ready) {
      return;
    }

    _adUnitId = adUnitId;
    _status = BannerServiceStatus.loading;

    try {
      await _sdkAdapter.initialize();
      await _sdkAdapter.preloadBanner(adUnitId: adUnitId);
      _bannerAd = await _sdkAdapter.createBannerAd(adUnitId: adUnitId);
      _status = BannerServiceStatus.ready;
    } catch (_) {
      _bannerAd = null;
      _status = BannerServiceStatus.failed;
      rethrow;
    }
  }

  Future<void> dispose() async {
    if (_status == BannerServiceStatus.disposed) {
      return;
    }

    _bannerAd?.dispose();
    _bannerAd = null;
    _status = BannerServiceStatus.disposed;
  }

  Future<void> reload({required String adUnitId}) async {
    _adUnitId = adUnitId;
    _status = BannerServiceStatus.loading;

    try {
      await _sdkAdapter.initialize();
      await _sdkAdapter.preloadBanner(adUnitId: adUnitId);
      _bannerAd = await _sdkAdapter.createBannerAd(adUnitId: adUnitId);
      _status = BannerServiceStatus.ready;
    } catch (_) {
      _bannerAd = null;
      _status = BannerServiceStatus.failed;
      rethrow;
    }
  }

  Future<void> show({required String adUnitId}) async {
    if (_status == BannerServiceStatus.disposed) {
      throw StateError('BannerService has been disposed.');
    }

    if (_status != BannerServiceStatus.ready || _adUnitId != adUnitId) {
      await initialize(adUnitId: adUnitId);
    }
  }
}
