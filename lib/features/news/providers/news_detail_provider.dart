import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fover/core/network/api_result.dart';
import 'package:fover/core/network/dio_client.dart';
import 'package:fover/features/news/data/news_detail_repository_impl.dart';
import 'package:fover/features/news/domain/models/news_model.dart';
import 'package:fover/features/news/domain/news_detail_repository.dart';

enum NewsDetailStatus { initial, loading, loaded, error }

class NewsDetailState {
  const NewsDetailState({
    this.status = NewsDetailStatus.initial,
    this.article,
    this.errorMessage,
    this.isRefreshing = false,
  });

  final NewsDetailStatus status;
  final NewsInfo? article;
  final String? errorMessage;
  final bool isRefreshing;

  NewsDetailState copyWith({
    NewsDetailStatus? status,
    NewsInfo? article,
    String? errorMessage,
    bool? isRefreshing,
  }) {
    return NewsDetailState(
      status: status ?? this.status,
      article: article ?? this.article,
      errorMessage: errorMessage ?? this.errorMessage,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

final newsDetailRepositoryProvider = Provider<NewsDetailRepository>((ref) {
  return NewsDetailRepositoryImpl(dioClient: DioClient(dio: ref.watch(dioProvider)));
});

final newsDetailProvider = StateNotifierProvider.autoDispose.family<NewsDetailNotifier, NewsDetailState, String>(
  (ref, articleId) {
    final repository = ref.watch(newsDetailRepositoryProvider);
    return NewsDetailNotifier(repository, articleId);
  },
);

class NewsDetailNotifier extends StateNotifier<NewsDetailState> {
  NewsDetailNotifier(this._repository, this._articleId) : super(const NewsDetailState()) {
    loadDetail();
  }

  final NewsDetailRepository _repository;
  final String _articleId;
  NewsInfo? _memoryArticle;
  int _requestSequence = 0;
  int? _activeRequestId;
  Future<void>? _inFlightRequest;

  bool get _hasValidMemoryArticle => _memoryArticle != null;

  Future<void> loadDetail({bool forceRefresh = false, bool isRetry = false}) async {
    final shouldForceFetch = forceRefresh || isRetry;

    if (!shouldForceFetch && _hasValidMemoryArticle) {
      state = state.copyWith(status: NewsDetailStatus.loaded, article: _memoryArticle, errorMessage: null, isRefreshing: false);
      return;
    }

    if (_inFlightRequest != null && !shouldForceFetch) {
      return _inFlightRequest!;
    }

    final shouldBypassCaches = shouldForceFetch || state.status == NewsDetailStatus.error;
    final requestId = ++_requestSequence;
    _activeRequestId = requestId;

    if (shouldBypassCaches || state.status == NewsDetailStatus.initial) {
      state = state.copyWith(status: NewsDetailStatus.loading, errorMessage: null, isRefreshing: shouldForceFetch);
    }

    final requestFuture = _fetchDetail(requestId, forceRefresh: shouldForceFetch);
    _inFlightRequest = requestFuture;
    await requestFuture;
    if (identical(_inFlightRequest, requestFuture)) {
      _inFlightRequest = null;
    }
  }

  Future<void> refreshDetail() async {
    state = state.copyWith(isRefreshing: true, errorMessage: null);
    return loadDetail(forceRefresh: true);
  }

  Future<void> retryDetail() async {
    state = state.copyWith(isRefreshing: true, errorMessage: null);
    return loadDetail(forceRefresh: true, isRetry: true);
  }

  Future<void> _fetchDetail(int requestId, {required bool forceRefresh}) async {
    final result = await _repository.fetchNewsDetail(_articleId, forceRefresh: forceRefresh);
    if (requestId != _requestSequence || _activeRequestId != requestId) {
      return;
    }
    _handleResult(result);
  }

  void _handleResult(ApiResult<NewsInfo> result) {
    if (result.isSuccess) {
      _memoryArticle = result.data;
      state = state.copyWith(status: NewsDetailStatus.loaded, article: result.data, isRefreshing: false);
    } else {
      state = state.copyWith(status: NewsDetailStatus.error, errorMessage: result.error, isRefreshing: false);
    }
  }
}
