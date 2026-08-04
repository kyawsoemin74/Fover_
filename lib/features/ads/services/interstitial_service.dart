import 'package:fover/features/ads/services/sdk_adapter.dart';

enum InterstitialServiceStatus {
  idle,
  loading,
  ready,
  failed,
  disposed,
}

class InterstitialService {
  InterstitialService({SDKAdapter? sdkAdapter}) : _sdkAdapter = sdkAdapter ?? SDKAdapter();

  final SDKAdapter _sdkAdapter;
  InterstitialServiceStatus _status = InterstitialServiceStatus.idle;
  String? _adUnitId;

  InterstitialServiceStatus get status => _status;
  bool get isReady => _status == InterstitialServiceStatus.ready;

  Future<void> initialize({required String adUnitId}) async {
    if (_status == InterstitialServiceStatus.ready) {
      return;
    }

    _adUnitId = adUnitId;
    _status = InterstitialServiceStatus.loading;

    try {
      await _sdkAdapter.initialize();
      await _sdkAdapter.preloadInterstitial(adUnitId: adUnitId);
      _status = InterstitialServiceStatus.ready;
    } catch (_) {
      _status = InterstitialServiceStatus.failed;
      rethrow;
    }
  }

  Future<void> dispose() async {
    if (_status == InterstitialServiceStatus.disposed) {
      return;
    }

    _status = InterstitialServiceStatus.disposed;
  }

  Future<void> reload({required String adUnitId}) async {
    _adUnitId = adUnitId;
    _status = InterstitialServiceStatus.loading;

    try {
      await _sdkAdapter.initialize();
      await _sdkAdapter.preloadInterstitial(adUnitId: adUnitId);
      _status = InterstitialServiceStatus.ready;
    } catch (_) {
      _status = InterstitialServiceStatus.failed;
      rethrow;
    }
  }

  Future<void> show({required String adUnitId}) async {
    if (_status == InterstitialServiceStatus.disposed) {
      throw StateError('InterstitialService has been disposed.');
    }

    if (_status != InterstitialServiceStatus.ready || _adUnitId != adUnitId) {
      await initialize(adUnitId: adUnitId);
    }
  }

  Future<void> complete() async {
    if (_status == InterstitialServiceStatus.disposed) {
      throw StateError('InterstitialService has been disposed.');
    }

    if (_status != InterstitialServiceStatus.ready) {
      return;
    }
  }
}
