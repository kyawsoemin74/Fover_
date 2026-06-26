import 'dart:async';
import 'dart:collection';

import 'package:flutter_test/flutter_test.dart';
import 'package:fover/core/network/api_result.dart';
import 'package:fover/features/news/domain/models/news_model.dart';
import 'package:fover/features/news/domain/news_repository.dart';
import 'package:fover/features/news/providers/news_provider.dart';

class FakeNewsRepository implements NewsRepository {
  FakeNewsRepository({List<Future<ApiResult<List<NewsInfo>>>> responses = const []})
      : _responses = Queue<Future<ApiResult<List<NewsInfo>>>>.from(responses);

  final Queue<Future<ApiResult<List<NewsInfo>>>> _responses;
  int fetchNewsCalls = 0;

  @override
  Future<ApiResult<List<NewsInfo>>> fetchNews({bool forceRefresh = false}) async {
    fetchNewsCalls += 1;
    if (_responses.isEmpty) {
      return ApiResult.success([
        const NewsInfo(
          id: '1',
          title: 'default',
          content: 'default content',
        ),
      ]);
    }
    return _responses.removeFirst();
  }
}

void main() {
  group('NewsNotifier reliability', () {
    test('prevents duplicate overlapping list requests', () async {
      final firstResponse = Completer<ApiResult<List<NewsInfo>>>();
      final repo = FakeNewsRepository(responses: [firstResponse.future]);
      final notifier = NewsNotifier(repo);

      final firstRequest = notifier.loadNews();
      final secondRequest = notifier.loadNews();

      firstResponse.complete(ApiResult.success([
        const NewsInfo(id: '1', title: 'first', content: 'first content'),
      ]));

      await Future.wait([firstRequest, secondRequest]);

      expect(repo.fetchNewsCalls, 1);
      expect(notifier.state.status, NewsStatus.loaded);
      expect(notifier.state.news.single.title, 'first');
    });

    test('latest request wins when a newer request starts', () async {
      final firstResponse = Completer<ApiResult<List<NewsInfo>>>();
      final secondResponse = Completer<ApiResult<List<NewsInfo>>>();
      final repo = FakeNewsRepository(responses: [firstResponse.future, secondResponse.future]);
      final notifier = NewsNotifier(repo);

      final firstRequest = notifier.loadNews();
      final secondRequest = notifier.refreshNews();

      secondResponse.complete(ApiResult.success([
        const NewsInfo(id: '2', title: 'second', content: 'second content'),
      ]));
      await secondRequest;

      firstResponse.complete(ApiResult.success([
        const NewsInfo(id: '1', title: 'first', content: 'first content'),
      ]));
      await firstRequest;

      expect(repo.fetchNewsCalls, 2);
      expect(notifier.state.news.single.title, 'second');
    });

    test('uses in-memory cache before calling repository again', () async {
      final repo = FakeNewsRepository();
      final notifier = NewsNotifier(repo);

      await notifier.loadNews();
      await notifier.loadNews();

      expect(repo.fetchNewsCalls, 1);
      expect(notifier.state.status, NewsStatus.loaded);
      expect(notifier.state.news.single.title, 'default');
    });

    test('force refresh bypasses memory cache and re-fetches', () async {
      final repo = FakeNewsRepository();
      final notifier = NewsNotifier(repo);

      await notifier.loadNews();
      await notifier.loadNews(forceRefresh: true);

      expect(repo.fetchNewsCalls, 2);
      expect(notifier.state.status, NewsStatus.loaded);
    });
  });
}
