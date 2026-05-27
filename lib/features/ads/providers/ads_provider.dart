import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fover/core/network/api_result.dart';
import 'package:fover/core/network/dio_client.dart';
import 'package:fover/features/ads/data/ads_repository_impl.dart';
import 'package:fover/features/ads/domain/ads_repository.dart';
import 'package:fover/features/ads/domain/models/ad_model.dart';

enum AdsStatus { initial, loading, loaded, empty, error }

class AdsState {
  const AdsState({
    this.status = AdsStatus.initial,
    this.ads = const [],
    this.errorMessage,
    this.isRefreshing = false,
  });

  final AdsStatus status;
  final List<AdInfo> ads;
  final String? errorMessage;
  final bool isRefreshing;

  AdsState copyWith({
    AdsStatus? status,
    List<AdInfo>? ads,
    String? errorMessage,
    bool? isRefreshing,
  }) {
    return AdsState(
      status: status ?? this.status,
      ads: ads ?? this.ads,
      errorMessage: errorMessage ?? this.errorMessage,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

final adsRepositoryProvider = Provider<AdsRepository>((ref) {
  return AdsRepositoryImpl(dioClient: DioClient());
});

final adsProvider = StateNotifierProvider.autoDispose<AdsNotifier, AdsState>((ref) {
  final repository = ref.watch(adsRepositoryProvider);
  return AdsNotifier(repository);
});

class AdsNotifier extends StateNotifier<AdsState> {
  AdsNotifier(this._repository) : super(const AdsState()) {
    loadAds();
  }

  final AdsRepository _repository;

  Future<void> loadAds() async {
    state = state.copyWith(status: AdsStatus.loading, errorMessage: null);
    final result = await _repository.fetchAds();
    _handleResult(result);
  }

  Future<void> refreshAds() async {
    state = state.copyWith(isRefreshing: true, errorMessage: null);
    final result = await _repository.fetchAds(forceRefresh: true);
    _handleResult(result);
  }

  void _handleResult(ApiResult<List<AdInfo>> result) {
    if (result.isSuccess) {
      final ads = result.data ?? const [];
      final nextStatus = ads.isEmpty ? AdsStatus.empty : AdsStatus.loaded;
      state = state.copyWith(status: nextStatus, ads: ads, isRefreshing: false);
    } else {
      state = state.copyWith(status: AdsStatus.error, errorMessage: result.error, isRefreshing: false);
    }
  }
}
