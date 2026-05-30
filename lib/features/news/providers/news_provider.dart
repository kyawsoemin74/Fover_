import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fover/core/network/api_result.dart';
import 'package:fover/core/network/dio_client.dart';
import 'package:fover/features/news/data/news_repository_impl.dart';
import 'package:fover/features/news/domain/models/news_model.dart';
import 'package:fover/features/news/domain/news_repository.dart';

enum NewsCategory { forYou, latest, transfers, tips }

final selectedNewsCategoryProvider = StateProvider<NewsCategory>((ref) => NewsCategory.forYou);

final filteredNewsProvider = Provider<List<NewsInfo>>((ref) {
  final state = ref.watch(newsProvider);
  final category = ref.watch(selectedNewsCategoryProvider);
  final items = state.news;

  String normalize(String s) => s.toLowerCase();

  switch (category) {
    case NewsCategory.forYou:
      // Placeholder: currently returns all items; replace with personalization later.
      return items;
    case NewsCategory.latest:
      // Latest: return as-is (assumed already sorted by freshness)
      return items;
    case NewsCategory.transfers:
      final keywords = RegExp(r"transfer|signed|joins|loan|transfermarkt|transfered", caseSensitive: false);
      return items.where((n) => keywords.hasMatch(normalize(n.title)) || keywords.hasMatch(normalize(n.content))).toList();
    case NewsCategory.tips:
      final keywords = RegExp(r"tip|prediction|bet|odds|forecast", caseSensitive: false);
      return items.where((n) => keywords.hasMatch(normalize(n.title)) || keywords.hasMatch(normalize(n.content))).toList();
  }
});

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

  Future<void> loadNews() async {
    state = state.copyWith(status: NewsStatus.loading, errorMessage: null);
    final result = await _repository.fetchNews();
    _handleResult(result);
  }

  Future<void> refreshNews() async {
    state = state.copyWith(isRefreshing: true, errorMessage: null);
    final result = await _repository.fetchNews(forceRefresh: true);
    _handleResult(result);
  }

  void _handleResult(ApiResult<List<NewsInfo>> result) {
    if (result.isSuccess) {
      final items = result.data ?? const [];
      final nextStatus = items.isEmpty ? NewsStatus.empty : NewsStatus.loaded;
      state = state.copyWith(status: nextStatus, news: items, isRefreshing: false);
    } else {
      state = state.copyWith(status: NewsStatus.error, errorMessage: result.error, isRefreshing: false);
    }
  }
}
