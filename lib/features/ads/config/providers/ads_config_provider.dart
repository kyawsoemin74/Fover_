import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fover/features/ads/config/ads_config_model.dart';
import 'package:fover/features/ads/config/data/ads_config_repository_impl.dart';
import 'package:fover/features/ads/config/domain/ads_config_repository.dart';
import 'package:fover/features/ads/providers/ads_runtime_provider.dart';
import 'package:fover/features/ads/services/ads_initializer.dart';

enum AdsConfigStatus { initial, loading, ready, error }

class AdsConfigState {
  const AdsConfigState({
    this.status = AdsConfigStatus.initial,
    this.isLoading = false,
    this.errorMessage,
    this.config,
  });

  final AdsConfigStatus status;
  final bool isLoading;
  final String? errorMessage;
  final AdsConfigModel? config;

  AdsConfigState copyWith({
    AdsConfigStatus? status,
    bool? isLoading,
    String? errorMessage,
    AdsConfigModel? config,
  }) {
    return AdsConfigState(
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      config: config ?? this.config,
    );
  }
}

final adsConfigProvider = StateNotifierProvider<AdsConfigProvider, AdsConfigState>((ref) {
  return AdsConfigProvider(AdsConfigRepositoryImpl(), ref);
});

class AdsConfigProvider extends StateNotifier<AdsConfigState> {
  AdsConfigProvider(this._repository, this._ref) : super(const AdsConfigState());

  final AdsConfigRepository _repository;
  final Ref _ref;

  Future<AdsConfigModel?> loadConfig() async {
    final runtimeNotifier = _ref.read(adsRuntimeProvider.notifier);
    runtimeNotifier.setConfigLoading();
    state = state.copyWith(status: AdsConfigStatus.loading, isLoading: true, errorMessage: null);

    final result = await _repository.fetchConfig();
    if (!result.isSuccess) {
      runtimeNotifier.setError(result.error ?? 'Unable to load ads config.');
      state = state.copyWith(
        status: AdsConfigStatus.error,
        isLoading: false,
        errorMessage: result.error,
      );
      return null;
    }

    runtimeNotifier.setConfigReady();
    state = state.copyWith(
      status: AdsConfigStatus.ready,
      isLoading: false,
      errorMessage: null,
      config: result.data,
    );
    return result.data;
  }

  Future<void> initializeAdsFromConfig() async {
    final config = await loadConfig();
    if (config == null || !config.isEnabled) {
      return;
    }

    final runtimeNotifier = _ref.read(adsRuntimeProvider.notifier);
    runtimeNotifier.setLoading();

    final initializer = AdsInitializer();
    await initializer.initialize(config, runtimeProvider: runtimeNotifier);
  }
}
