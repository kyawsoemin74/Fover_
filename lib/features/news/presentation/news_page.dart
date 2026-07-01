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
  late final PageController _pageController;
  int _currentPageIndex = 0;
  static const _pageAnimationDuration = Duration(milliseconds: 260);
  static const _pageAnimationCurve = Curves.easeOutCubic;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPageIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _animateToPage(int pageIndex) {
    if (!_pageController.hasClients || pageIndex == _currentPageIndex) return;
    _pageController.animateToPage(
      pageIndex,
      duration: _pageAnimationDuration,
      curve: _pageAnimationCurve,
    );
  }

  @override
  Widget build(BuildContext context) {
    final newsState = ref.watch(newsProvider);
    final notifier = ref.read(newsProvider.notifier);
    final selectedCategory = NewsCategory.values[_currentPageIndex];

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
              final pageIndex = NewsCategory.values.indexOf(category);
              _animateToPage(pageIndex);
            },
          ),
          const SizedBox(height: 10),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (pageIndex) {
                setState(() {
                  _currentPageIndex = pageIndex;
                });
              },
              children: NewsCategory.values.map((category) {
                return NewsCategoryPage(
                  key: PageStorageKey(category),
                  category: category,
                  articles: newsState.news,
                  status: newsState.status,
                  errorMessage: newsState.errorMessage,
                  onRefresh: notifier.refreshNews,
                  onRetry: notifier.loadNews,
                  onArticleTap: _openArticle,
                );
              }).toList(),
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

        ],
      ),
    );
  }
}

class NewsCategoryPage extends StatefulWidget {
  const NewsCategoryPage({
    super.key,
    required this.category,
    required this.articles,
    required this.status,
    required this.errorMessage,
    required this.onRefresh,
    required this.onRetry,
    required this.onArticleTap,
  });

  final NewsCategory category;
  final List<NewsInfo> articles;
  final NewsStatus status;
  final String? errorMessage;
  final Future<void> Function() onRefresh;
  final VoidCallback onRetry;
  final ValueChanged<NewsInfo> onArticleTap;

  @override
  State<NewsCategoryPage> createState() => _NewsCategoryPageState();
}

class _NewsCategoryPageState extends State<NewsCategoryPage> {
  static const _loadStep = 5;
  final _scrollController = ScrollController();
  int _visibleFeedItems = 6;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(NewsCategoryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category != widget.category) {
      setState(() {
        _visibleFeedItems = 6;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final filteredCount = _filteredArticles().length;
    if (_scrollController.position.maxScrollExtent - _scrollController.offset < 120 && _visibleFeedItems < filteredCount) {
      setState(() {
        _visibleFeedItems = min(filteredCount, _visibleFeedItems + _loadStep);
      });
    }
  }

  List<NewsInfo> _filteredArticles() {
    final items = widget.articles;
    String normalize(String s) => s.toLowerCase();

    switch (widget.category) {
      case NewsCategory.forYou:
      case NewsCategory.latest:
        return items;
      case NewsCategory.transfers:
        final keywords = RegExp(r"transfer|signed|joins|loan|transfermarkt|transfered", caseSensitive: false);
        return items.where((n) => keywords.hasMatch(normalize(n.title)) || keywords.hasMatch(normalize(n.content))).toList();
      case NewsCategory.tips:
        final keywords = RegExp(r"tip|prediction|bet|odds|forecast", caseSensitive: false);
        return items.where((n) => keywords.hasMatch(normalize(n.title)) || keywords.hasMatch(normalize(n.content))).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredArticles = _filteredArticles();
    final heroArticle = filteredArticles.isNotEmpty ? filteredArticles.first : null;
    final feedArticles = filteredArticles.length > 1
        ? filteredArticles.sublist(1, min(filteredArticles.length, 1 + _visibleFeedItems))
        : <NewsInfo>[];
    final hasMore = filteredArticles.length > 1 + _visibleFeedItems;

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      displacement: 36,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          if (widget.status == NewsStatus.loading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (widget.status == NewsStatus.error)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                title: 'Unable to load news',
                message: widget.errorMessage ?? 'Please check your connection and try again.',
                actionLabel: 'Retry',
                onAction: widget.onRetry,
              ),
            )
          else if (widget.status == NewsStatus.empty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                title: 'No news available',
                message: 'There are no headlines available right now.',
                actionLabel: 'Refresh',
                onAction: widget.onRefresh,
              ),
            )
          else ...[
            if (heroArticle != null) ...[
              SliverToBoxAdapter(
                child: _NewsHeroCard(article: heroArticle, onTap: () => widget.onArticleTap(heroArticle)),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
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
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _LatestNewsTile(article: article, onTap: () => widget.onArticleTap(article)),
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
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              child: article.hasImage
                  ? AspectRatio(
                      aspectRatio: 16 / 9,
                      child: CachedNetworkImage(
                        imageUrl: article.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: theme.colorScheme.surfaceContainerHighest),
                        errorWidget: (context, url, error) => Container(color: theme.colorScheme.surfaceContainerHighest),
                      ),
                    )
                  : Container(
                      height: 184,
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
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HorizontalBadge(label: article.category.isNotEmpty ? article.category : 'Top Story'),
                  const SizedBox(height: 10),
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, height: 1.25),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${article.displaySource} • ${article.publishedTimeLabel} • ${article.readTimeLabel}',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, height: 1.5),
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
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: article.hasImage
                    ? CachedNetworkImage(
                        imageUrl: article.imageUrl,
                        width: 92,
                        height: 72,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: theme.colorScheme.surfaceContainerHighest),
                        errorWidget: (context, url, error) => Container(color: theme.colorScheme.surfaceContainerHighest),
                      )
                    : Container(
                        width: 92,
                        height: 72,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(Icons.sports_soccer, color: Colors.white70, size: 28),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, height: 1.28),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${article.displaySource} • ${article.publishedTimeLabel}',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant, height: 1.5),
                    ),
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
