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

  Future<void> loadDetail() async {
    state = state.copyWith(status: NewsDetailStatus.loading, errorMessage: null);
    final result = await _repository.fetchNewsDetail(_articleId);
    _handleResult(result);
  }

  Future<void> refreshDetail() async {
    state = state.copyWith(isRefreshing: true, errorMessage: null);
    final result = await _repository.fetchNewsDetail(_articleId, forceRefresh: true);
    _handleResult(result);
  }

  void _handleResult(ApiResult<NewsInfo> result) {
    if (result.isSuccess) {
      state = state.copyWith(status: NewsDetailStatus.loaded, article: result.data, isRefreshing: false);
    } else {
      state = state.copyWith(status: NewsDetailStatus.error, errorMessage: result.error, isRefreshing: false);
    }
  }
}
