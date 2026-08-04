import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fover/features/ads/services/banner_service.dart';
import 'package:fover/features/ads/services/interstitial_service.dart';
import 'package:fover/features/ads/services/rewarded_service.dart';

enum AdsRuntimeStatus { initial, loading, ready, error }

class AdsRuntimeState {
  const AdsRuntimeState({
    this.status = AdsRuntimeStatus.initial,
    this.isLoading = false,
    this.errorMessage,
    this.isBannerAvailable = false,
    this.isInterstitialAvailable = false,
    this.isRewardedAvailable = false,
  });

  final AdsRuntimeStatus status;
  final bool isLoading;
  final String? errorMessage;
  final bool isBannerAvailable;
  final bool isInterstitialAvailable;
  final bool isRewardedAvailable;

  AdsRuntimeState copyWith({
    AdsRuntimeStatus? status,
    bool? isLoading,
    String? errorMessage,
    bool? isBannerAvailable,
    bool? isInterstitialAvailable,
    bool? isRewardedAvailable,
  }) {
    return AdsRuntimeState(
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isBannerAvailable: isBannerAvailable ?? this.isBannerAvailable,
      isInterstitialAvailable: isInterstitialAvailable ?? this.isInterstitialAvailable,
      isRewardedAvailable: isRewardedAvailable ?? this.isRewardedAvailable,
    );
  }
}

final adsRuntimeProvider = StateNotifierProvider<AdsRuntimeProvider, AdsRuntimeState>((ref) {
  return AdsRuntimeProvider();
});

class AdsRuntimeProvider extends StateNotifier<AdsRuntimeState> {
  AdsRuntimeProvider() : super(const AdsRuntimeState());

  BannerService? _sharedBannerService;
  InterstitialService? _sharedInterstitialService;
  RewardedService? _sharedRewardedService;

  BannerService? get sharedBannerService => _sharedBannerService;
  InterstitialService? get sharedInterstitialService => _sharedInterstitialService;
  RewardedService? get sharedRewardedService => _sharedRewardedService;

  void registerSharedBannerService(BannerService service) {
    _sharedBannerService ??= service;
  }

  void registerSharedInterstitialService(InterstitialService service) {
    _sharedInterstitialService ??= service;
  }

  void registerSharedRewardedService(RewardedService service) {
    _sharedRewardedService ??= service;
  }

  void setConfigLoading() {
    state = state.copyWith(status: AdsRuntimeStatus.loading, isLoading: true, errorMessage: null);
  }

  void setConfigReady() {
    state = state.copyWith(
      status: AdsRuntimeStatus.ready,
      isLoading: false,
      errorMessage: null,
      isBannerAvailable: false,
      isInterstitialAvailable: false,
      isRewardedAvailable: false,
    );
  }

  void setLoading() {
    state = state.copyWith(status: AdsRuntimeStatus.loading, isLoading: true, errorMessage: null);
  }

  @override
  void dispose() {
    _sharedBannerService?.dispose();
    _sharedInterstitialService?.dispose();
    _sharedRewardedService?.dispose();
    super.dispose();
  }

  void setReady({required bool bannerAvailable, required bool interstitialAvailable, required bool rewardedAvailable}) {
    state = state.copyWith(
      status: AdsRuntimeStatus.ready,
      isLoading: false,
      errorMessage: null,
      isBannerAvailable: bannerAvailable,
      isInterstitialAvailable: interstitialAvailable,
      isRewardedAvailable: rewardedAvailable,
    );
  }

  void setError(String message) {
    state = state.copyWith(
      status: AdsRuntimeStatus.error,
      isLoading: false,
      errorMessage: message,
      isBannerAvailable: false,
      isInterstitialAvailable: false,
      isRewardedAvailable: false,
    );
  }
}
