import 'dart:math' show min;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fover/features/news/domain/models/news_model.dart';
import 'package:fover/features/news/providers/news_provider.dart';
// custom_appbar intentionally not used on News page; using compact header instead
import 'package:fover/shared/widgets/empty_state.dart';

class NewsPage extends ConsumerStatefulWidget {
  const NewsPage({super.key});

  @override
  ConsumerState<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends ConsumerState<NewsPage> {
  static const _loadStep = 5;
  final _scrollController = ScrollController();
  int _visibleFeedItems = 6;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final filteredCount = ref.read(filteredNewsProvider).length;
    if (_scrollController.position.maxScrollExtent - _scrollController.offset < 120 && _visibleFeedItems < filteredCount) {
      setState(() {
        _visibleFeedItems = min(filteredCount, _visibleFeedItems + _loadStep);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(newsProvider.notifier);
    final status = ref.watch(newsProvider.select((s) => s.status));
    final selectedCategory = ref.watch(selectedNewsCategoryProvider);
    final filtered = ref.watch(filteredNewsProvider);
    final errorMessage = ref.watch(newsProvider.select((s) => s.errorMessage));

    final heroArticle = filtered.isNotEmpty ? filtered.first : null;
    final secondaryArticles = filtered.length > 1 ? filtered.sublist(1, min(filtered.length, 4)) : <NewsInfo>[];
    final feedStart = 1 + secondaryArticles.length;
    final feedArticles = filtered.length > feedStart
        ? filtered.sublist(feedStart, min(filtered.length, feedStart + _visibleFeedItems))
        : <NewsInfo>[];
    final hasMore = filtered.length > feedStart + _visibleFeedItems;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CompactNewsHeader(),
          const SizedBox(height: 8),
          _NewsCategoryBar(
            selectedCategory: selectedCategory,
            onCategorySelected: (category) {
              ref.read(selectedNewsCategoryProvider.notifier).state = category;
              setState(() {
                _visibleFeedItems = 6;
              });
            },
          ),
          const SizedBox(height: 10),
          Expanded(
            child: RefreshIndicator(
              onRefresh: notifier.refreshNews,
              displacement: 36,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Text(
                      '',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 18)),
                  if (status == NewsStatus.loading)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (status == NewsStatus.error)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyState(
                        title: 'Unable to load news',
                        message: errorMessage ?? 'Please check your connection and try again.',
                        actionLabel: 'Retry',
                        onAction: notifier.loadNews,
                      ),
                    )
                  else if (status == NewsStatus.empty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyState(
                        title: 'No news available',
                        message: 'There are no headlines available right now.',
                        actionLabel: 'Refresh',
                        onAction: notifier.refreshNews,
                      ),
                    )
                  else ...[
                    if (heroArticle != null) ...[
                      SliverToBoxAdapter(
                        child: _NewsHeroCard(article: heroArticle, onTap: () => _openArticle(heroArticle)),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    ],
                    if (secondaryArticles.isNotEmpty) ...[
                      SliverToBoxAdapter(child: _SectionHeader(title: 'Secondary Stories')),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 210,
                          child: ListView.separated(
                            padding: const EdgeInsets.only(top: 12),
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: secondaryArticles.length,
                            separatorBuilder: (context, index) => const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final article = secondaryArticles[index];
                              return _SecondaryArticleCard(article: article, onTap: () => _openArticle(article));
                            },
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    ],
                    SliverToBoxAdapter(child: _SectionHeader(title: 'Latest News')),
                    if (feedArticles.isEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Text(
                              'No stories match this category yet.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                            ),
                          ),
                        ),
                      )
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final article = feedArticles[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _LatestNewsTile(article: article, onTap: () => _openArticle(article)),
                            );
                          },
                          childCount: feedArticles.length,
                        ),
                      ),
                    if (hasMore)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 18),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ),
                    const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openArticle(NewsInfo article) {
    context.push('/news/${Uri.encodeComponent(article.id)}');
  }
}

class _NewsCategoryBar extends StatelessWidget {
  const _NewsCategoryBar({
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final NewsCategory selectedCategory;
  final ValueChanged<NewsCategory> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 4),
        itemCount: NewsCategory.values.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = NewsCategory.values[index];
          final isSelected = category == selectedCategory;
          final label = {
            NewsCategory.forYou: 'For You',
            NewsCategory.latest: 'Latest',
            NewsCategory.transfers: 'Transfers',
            NewsCategory.tips: 'Tips',
          }[category]!;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withAlpha(16),
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () => onCategorySelected(category),
              child: Center(
                child: Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CompactNewsHeader extends StatelessWidget {
  const _CompactNewsHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final color = theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: primary.withValues(alpha: 0.18),
            ),
            child: Icon(Icons.sports_soccer, color: primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('News', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, fontSize: 20)),
                      const SizedBox(height: 2),
                      Text(
                        '',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
          IconButton(
            onPressed: null,
            icon: const Icon(Icons.notifications_none),
            tooltip: 'Notifications',
            color: color,
            splashRadius: 18,
          ),
          IconButton(
            onPressed: null,
            icon: const Icon(Icons.calendar_today_outlined),
            tooltip: 'Calendar',
            color: color,
            splashRadius: 18,
          ),
          IconButton(
            onPressed: null,
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            color: color,
            splashRadius: 18,
          ),
          PopupMenuButton<String>(
            color: Theme.of(context).colorScheme.surface,
            icon: Icon(Icons.more_vert, color: color),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'refresh', child: Text('Refresh')),
              const PopupMenuItem(value: 'settings', child: Text('Settings')),
            ],
            onSelected: (_) {},
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _NewsHeroCard extends StatelessWidget {
  const _NewsHeroCard({required this.article, required this.onTap});

  final NewsInfo article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: article.hasImage
                  ? CachedNetworkImage(
                      imageUrl: article.imageUrl,
                      height: 220,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: theme.colorScheme.surfaceContainerHighest),
                      errorWidget: (context, url, error) => Container(color: theme.colorScheme.surfaceContainerHighest),
                    )
                  : Container(
                      height: 220,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.72)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Center(child: Icon(Icons.sports_soccer, size: 72, color: Colors.white70)),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HorizontalBadge(label: article.category.isNotEmpty ? article.category : 'Top Story'),
                  const SizedBox(height: 10),
                  Text(article.title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(
                    '${article.displaySource} • ${article.publishedTimeLabel} • ${article.readTimeLabel}',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecondaryArticleCard extends StatelessWidget {
  const _SecondaryArticleCard({required this.article, required this.onTap});

  final NewsInfo article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 240,
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                child: article.hasImage
                    ? CachedNetworkImage(
                        imageUrl: article.imageUrl,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: theme.colorScheme.surfaceContainerHighest),
                        errorWidget: (context, url, error) => Container(color: theme.colorScheme.surfaceContainerHighest),
                      )
                    : Container(
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [theme.colorScheme.primary.withValues(alpha: 0.88), theme.colorScheme.primary.withValues(alpha: 0.55)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: const Center(child: Icon(Icons.sports_soccer, size: 48, color: Colors.white70)),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(article.title, maxLines: 3, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    Text('${article.displaySource} • ${article.publishedTimeLabel}', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LatestNewsTile extends StatelessWidget {
  const _LatestNewsTile({required this.article, required this.onTap});

  final NewsInfo article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (article.hasImage)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: article.imageUrl,
                    width: 90,
                    height: 82,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: theme.colorScheme.surfaceContainerHighest),
                    errorWidget: (context, url, error) => Container(color: theme.colorScheme.surfaceContainerHighest),
                  ),
                )
              else
                Container(
                  width: 90,
                  height: 82,
                     decoration: BoxDecoration(
                       color: theme.colorScheme.primary.withValues(alpha: 0.18),
                       borderRadius: BorderRadius.circular(16),
                     ),
                  child: const Icon(Icons.sports_soccer, color: Colors.white70, size: 28),
                ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(article.title, maxLines: 3, overflow: TextOverflow.ellipsis, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    Text('${article.displaySource} • ${article.publishedTimeLabel}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HorizontalBadge extends StatelessWidget {
  const _HorizontalBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700)),
    );
  }
}
