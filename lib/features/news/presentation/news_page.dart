import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fover/features/news/providers/news_provider.dart';
import 'package:fover/shared/widgets/custom_appbar.dart';
import 'package:fover/shared/widgets/empty_state.dart';

class NewsPage extends ConsumerWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(newsProvider);
    final notifier = ref.read(newsProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomAppBar(
            title: 'News',
          ),
          const SizedBox(height: 14),
          Text(
            'Latest headlines from across the football world.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 26),
          Expanded(
            child: _buildBody(context, state, notifier),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, NewsState state, NewsNotifier notifier) {
    switch (state.status) {
      case NewsStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case NewsStatus.error:
        return EmptyState(
          title: 'Unable to load news',
          message: state.errorMessage ?? 'Please check your connection and try again.',
          actionLabel: 'Retry',
          onAction: notifier.loadNews,
        );
      case NewsStatus.empty:
        return EmptyState(
          title: 'No news available',
          message: 'There are no headlines available right now.',
          actionLabel: 'Refresh',
          onAction: notifier.refreshNews,
        );
      case NewsStatus.loaded:
        return RefreshIndicator(
          onRefresh: notifier.refreshNews,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: state.news.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = state.news[index];
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.content,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            },
          ),
        );
      case NewsStatus.initial:
        return const SizedBox.shrink();
    }
  }
}
