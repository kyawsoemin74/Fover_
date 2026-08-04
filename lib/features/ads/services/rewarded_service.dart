import 'package:fover/features/ads/services/sdk_adapter.dart';

enum RewardedServiceStatus {
  idle,
  loading,
  ready,
  failed,
  disposed,
}

class RewardedService {
  RewardedService({SDKAdapter? sdkAdapter}) : _sdkAdapter = sdkAdapter ?? SDKAdapter();

  final SDKAdapter _sdkAdapter;
  RewardedServiceStatus _status = RewardedServiceStatus.idle;
  String? _adUnitId;

  RewardedServiceStatus get status => _status;
  bool get isReady => _status == RewardedServiceStatus.ready;

  Future<void> initialize({required String adUnitId}) async {
    if (_status == RewardedServiceStatus.ready) {
      return;
    }

    _adUnitId = adUnitId;
    _status = RewardedServiceStatus.loading;

    try {
      await _sdkAdapter.initialize();
      await _sdkAdapter.preloadRewarded(adUnitId: adUnitId);
      _status = RewardedServiceStatus.ready;
    } catch (_) {
      _status = RewardedServiceStatus.failed;
      rethrow;
    }
  }

  Future<void> dispose() async {
    if (_status == RewardedServiceStatus.disposed) {
      return;
    }

    _status = RewardedServiceStatus.disposed;
  }

  Future<void> reload({required String adUnitId}) async {
    _adUnitId = adUnitId;
    _status = RewardedServiceStatus.loading;

    try {
      await _sdkAdapter.initialize();
      await _sdkAdapter.preloadRewarded(adUnitId: adUnitId);
      _status = RewardedServiceStatus.ready;
    } catch (_) {
      _status = RewardedServiceStatus.failed;
      rethrow;
    }
  }

  Future<void> show({required String adUnitId}) async {
    if (_status == RewardedServiceStatus.disposed) {
      throw StateError('RewardedService has been disposed.');
    }

    if (_status != RewardedServiceStatus.ready || _adUnitId != adUnitId) {
      await initialize(adUnitId: adUnitId);
    }
  }

  Future<void> complete() async {
    if (_status == RewardedServiceStatus.disposed) {
      throw StateError('RewardedService has been disposed.');
    }

    if (_status != RewardedServiceStatus.ready) {
      return;
    }
  }
}
