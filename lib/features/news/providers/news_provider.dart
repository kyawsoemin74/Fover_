import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fover/core/network/api_result.dart';
import 'package:fover/core/network/dio_client.dart';
import 'package:fover/features/news/data/news_repository_impl.dart';
import 'package:fover/features/news/domain/models/news_model.dart';
import 'package:fover/features/news/domain/news_repository.dart';

enum NewsCategory { forYou, latest, transfers, tips }

enum NewsStatus { initial, loading, loaded, empty, error }

class NewsState {
  const NewsState({
    this.status = NewsStatus.initial,
    this.news = const [],
    this.errorMessage,
    this.isRefreshing = false,
  });

  final NewsStatus status;
  final List<NewsInfo> news;
  final String? errorMessage;
  final bool isRefreshing;

  NewsState copyWith({
    NewsStatus? status,
    List<NewsInfo>? news,
    String? errorMessage,
    bool? isRefreshing,
  }) {
    return NewsState(
      status: status ?? this.status,
      news: news ?? this.news,
      errorMessage: errorMessage ?? this.errorMessage,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  return NewsRepositoryImpl(dioClient: DioClient(dio: ref.watch(dioProvider)));
});

final newsProvider = StateNotifierProvider<NewsNotifier, NewsState>((ref) {
  final repository = ref.watch(newsRepositoryProvider);
  return NewsNotifier(repository);
});

class NewsNotifier extends StateNotifier<NewsState> {
  NewsNotifier(this._repository) : super(const NewsState()) {
    loadNews();
  }

  final NewsRepository _repository;
  List<NewsInfo>? _memoryCache;
  int _requestSequence = 0;
  int? _activeRequestId;
  Future<void>? _inFlightRequest;

  bool get _hasValidMemoryCache => _memoryCache != null && _memoryCache!.isNotEmpty;

  Future<void> loadNews({bool forceRefresh = false, bool isRetry = false}) async {
    final shouldForceFetch = forceRefresh || isRetry;

    if (!shouldForceFetch && _hasValidMemoryCache) {
      state = state.copyWith(status: NewsStatus.loaded, news: _memoryCache!, errorMessage: null, isRefreshing: false);
      return;
    }

    if (_inFlightRequest != null && !shouldForceFetch) {
      return _inFlightRequest!;
    }

    final shouldBypassCaches = shouldForceFetch || state.status == NewsStatus.error || state.status == NewsStatus.empty;
    final requestId = ++_requestSequence;
    _activeRequestId = requestId;

    if (shouldBypassCaches || state.status == NewsStatus.initial) {
      state = state.copyWith(status: NewsStatus.loading, errorMessage: null, isRefreshing: shouldForceFetch);
    } else if (state.news.isEmpty) {
      state = state.copyWith(status: NewsStatus.loading, errorMessage: null, isRefreshing: shouldForceFetch);
    }

    final requestFuture = _fetchNews(requestId, forceRefresh: shouldForceFetch);
    _inFlightRequest = requestFuture;
    await requestFuture;
    if (identical(_inFlightRequest, requestFuture)) {
      _inFlightRequest = null;
    }
  }

  Future<void> refreshNews() async {
    state = state.copyWith(isRefreshing: true, errorMessage: null);
    return loadNews(forceRefresh: true);
  }

  Future<void> retryNews() async {
    state = state.copyWith(isRefreshing: true, errorMessage: null);
    return loadNews(forceRefresh: true, isRetry: true);
  }

  Future<void> _fetchNews(int requestId, {required bool forceRefresh}) async {
    final result = await _repository.fetchNews(forceRefresh: forceRefresh);
    if (requestId != _requestSequence || _activeRequestId != requestId) {
      return;
    }
    _handleResult(result);
  }

  void _handleResult(ApiResult<List<NewsInfo>> result) {
    if (result.isSuccess) {
      final items = result.data ?? const [];
      _memoryCache = items;
      final nextStatus = items.isEmpty ? NewsStatus.empty : NewsStatus.loaded;
      state = state.copyWith(status: nextStatus, news: items, isRefreshing: false);
    } else {
      state = state.copyWith(status: NewsStatus.error, errorMessage: result.error, isRefreshing: false);
    }
  }
}
