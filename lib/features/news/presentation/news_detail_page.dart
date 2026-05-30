import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fover/features/news/domain/models/news_model.dart';
import 'package:fover/features/news/providers/news_detail_provider.dart';
import 'package:fover/features/news/providers/news_provider.dart';
import 'package:fover/shared/widgets/empty_state.dart';

class NewsDetailPage extends ConsumerWidget {
  const NewsDetailPage({
    super.key,
    required this.articleId,
  });

  final String articleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailState = ref.watch(newsDetailProvider(articleId));
    final notifier = ref.read(newsDetailProvider(articleId).notifier);
    final allNews = ref.watch(newsProvider.select((state) => state.news));
    final article = detailState.article;
    final relatedArticles = _buildRelatedArticles(allNews, articleId, article);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        title: Text('Article', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
      ),
      body: RefreshIndicator(
        onRefresh: notifier.refreshDetail,
        color: theme.colorScheme.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            if (detailState.status == NewsDetailStatus.loading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (detailState.status == NewsDetailStatus.error)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  title: 'Unable to open article',
                  message: detailState.errorMessage ?? 'Something went wrong while loading this story.',
                  actionLabel: 'Retry',
                  onAction: notifier.refreshDetail,
                ),
              )
            else if (article == null)
              const SliverFillRemaining(hasScrollBody: false, child: SizedBox.shrink())
            else ...[
              SliverToBoxAdapter(child: _NewsDetailHero(article: article)),
              SliverToBoxAdapter(child: _NewsDetailHeader(article: article)),
              SliverToBoxAdapter(child: const SizedBox(height: 22)),
              SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: _NewsDetailContent(article: article))),
              if (relatedArticles.isNotEmpty) ...[
                SliverToBoxAdapter(child: const SizedBox(height: 28)),
                SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('Related News', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)))),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final relatedArticle = relatedArticles[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _RelatedArticleCard(article: relatedArticle, onTap: () {
                            context.push('/news/${Uri.encodeComponent(relatedArticle.id)}');
                          }),
                        );
                      },
                      childCount: relatedArticles.length,
                    ),
                  ),
                ),
              ],
              const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
            ],
          ],
        ),
      ),
    );
  }

  List<NewsInfo> _buildRelatedArticles(List<NewsInfo> allNews, String currentId, NewsInfo? article) {
    if (article == null) return const [];
    final categoryMatches = allNews.where((item) => item.id != currentId && item.category == article.category).take(4).toList();
    if (categoryMatches.isNotEmpty) {
      return categoryMatches;
    }
    return allNews.where((item) => item.id != currentId).take(4).toList();
  }
}

class _NewsDetailHero extends StatelessWidget {
  const _NewsDetailHero({required this.article});

  final NewsInfo article;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
            child: article.imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: article.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: theme.colorScheme.surfaceContainerHighest),
                    errorWidget: (context, url, error) => Container(color: theme.colorScheme.surfaceContainerHighest),
                  )
                : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.72)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(child: Icon(Icons.sports_soccer, size: 80, color: Colors.white70)),
                  ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _NewsDetailHeader extends StatelessWidget {
  const _NewsDetailHeader({required this.article});

  final NewsInfo article;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(article.title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _MetadataChip(label: article.displaySource),
              if (article.publishedAt != null) _MetadataChip(label: article.publishedTimeLabel),
              if (article.category.isNotEmpty) _MetadataChip(label: article.category),
              _MetadataChip(label: article.readTimeLabel),
            ],
          ),
          if (article.author.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text('By ${article.author}', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _NewsDetailContent extends StatelessWidget {
  const _NewsDetailContent({required this.article});

  final NewsInfo article;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (article.content.trim().isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Full content is unavailable for this article.', style: theme.textTheme.bodyLarge),
          const SizedBox(height: 14),
          Text(article.externalUrl, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary)),
        ],
      );
    }

    final blocks = _parseContent(article.content);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: blocks.map((block) {
        switch (block.type) {
          case _ArticleBlockType.quote:
            return Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Text.rich(
                  TextSpan(children: _buildInlineSpans(block.text, theme.textTheme.bodyLarge!)),
                  style: theme.textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
                ),
              ),
            );
          case _ArticleBlockType.bullet:
            return Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: block.items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('•', style: theme.textTheme.bodyLarge),
                        const SizedBox(width: 10),
                        Expanded(child: Text.rich(TextSpan(children: _buildInlineSpans(item, theme.textTheme.bodyLarge!))),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            );
          case _ArticleBlockType.paragraph:
            return Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Text.rich(
                TextSpan(children: _buildInlineSpans(block.text, theme.textTheme.bodyLarge!)),
                style: theme.textTheme.bodyLarge,
              ),
            );
        }
      }).toList(),
    );
  }

  static List<_ArticleBlock> _parseContent(String content) {
    final lines = content.trim().split(RegExp(r'\r?\n'));
    final blocks = <_ArticleBlock>[];
    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty) {
        continue;
      }
      if (line.startsWith('- ')) {
        final item = line.substring(2).trim();
        if (blocks.isNotEmpty && blocks.last.type == _ArticleBlockType.bullet) {
          blocks.last.items.add(item);
        } else {
          blocks.add(_ArticleBlock.bullet([item]));
        }
      } else if (line.startsWith('> ')) {
        final quote = line.substring(2).trim();
        blocks.add(_ArticleBlock.quote(quote));
      } else {
        blocks.add(_ArticleBlock.paragraph(line));
      }
    }
    return blocks;
  }

  static List<TextSpan> _buildInlineSpans(String text, TextStyle style) {
    final spans = <TextSpan>[];
    const pattern = r'\*\*(.+?)\*\*';
    final regex = RegExp(pattern);
    var start = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start), style: style));
      }
      spans.add(TextSpan(text: match.group(1), style: style.copyWith(fontWeight: FontWeight.bold)));
      start = match.end;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start), style: style));
    }
    return spans;
  }
}

class _MetadataChip extends StatelessWidget {
  const _MetadataChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}

class _RelatedArticleCard extends StatelessWidget {
  const _RelatedArticleCard({
    required this.article,
    required this.onTap,
  });

  final NewsInfo article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(article.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700), maxLines: 3, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Text('${article.displaySource} • ${article.publishedTimeLabel}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 72,
                height: 72,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: article.imageUrl.isNotEmpty
                      ? CachedNetworkImage(imageUrl: article.imageUrl, fit: BoxFit.cover, placeholder: (context, url) => Container(color: theme.colorScheme.surfaceContainerHighest), errorWidget: (context, url, error) => Container(color: theme.colorScheme.surfaceContainerHighest))
                      : Container(color: theme.colorScheme.surfaceContainerHighest, child: const Icon(Icons.sports_soccer, color: Colors.white70, size: 28)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _ArticleBlockType { paragraph, bullet, quote }

class _ArticleBlock {
  _ArticleBlock.paragraph(this.text)
      : type = _ArticleBlockType.paragraph,
        items = const [];

  _ArticleBlock.bullet(this.items)
      : type = _ArticleBlockType.bullet,
        text = '';

  _ArticleBlock.quote(this.text)
      : type = _ArticleBlockType.quote,
        items = const [];

  final _ArticleBlockType type;
  final String text;
  final List<String> items;
}
