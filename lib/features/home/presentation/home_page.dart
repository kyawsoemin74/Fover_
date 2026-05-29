import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fover/features/favorites/providers/favorites_provider.dart';
import 'package:fover/features/home/providers/home_provider.dart';
import 'package:fover/features/home/providers/home_state.dart';
import 'package:fover/features/home/presentation/widgets/home_section_header.dart';
import 'package:fover/features/home/presentation/widgets/home_top_section.dart';
import 'package:fover/shared/widgets/empty_state.dart';
import 'package:fover/shared/widgets/home_loading_skeleton.dart';
import 'package:fover/shared/widgets/league_card.dart';
import 'package:fover/shared/widgets/match_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static const _sectionPadding = EdgeInsets.symmetric(horizontal: 16);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);
    final homeNotifier = ref.read(homeProvider.notifier);
    final favoritesState = ref.watch(favoritesProvider);
    final followingCount = ref.watch(followingCountProvider);
    final followingItems = favoritesState.items;

    return RefreshIndicator(
      onRefresh: homeNotifier.refresh,
      edgeOffset: 0,
      color: Theme.of(context).colorScheme.primary,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: HomeTopHeaderDelegate(
              minExtent: 138,
              maxExtent: 138,
              child: HomeTopSection(
                onNotifications: () {},
                onCalendar: () {},
                onSearch: () {},
                onMenu: () {},
              ),
            ),
          ),
          if (followingCount > 0) ...[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              sliver: SliverToBoxAdapter(
                child: HomeSectionHeader(
                  title: 'Following ($followingCount)',
                  actionLabel: homeState.showFollowing ? 'Hide' : 'Show',
                  onAction: homeNotifier.toggleFollowing,
                ),
              ),
            ),
            if (homeState.showFollowing)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: _FollowingPreview(items: followingItems),
                ),
              ),
          ],
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            sliver: SliverToBoxAdapter(
              child: const HomeSectionHeader(
                title: '',
              ),
            ),
          ),
          if (homeState.status == HomeStatus.loading || homeState.status == HomeStatus.initial)
            SliverPadding(
              padding: _sectionPadding,
              sliver: const SliverToBoxAdapter(child: HomeLoadingSkeleton()),
            )
          else if (homeState.status == HomeStatus.error)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
                child: EmptyState(
                  title: 'Unable to load matches',
                  message: homeState.errorMessage ?? 'Please check your connection and try again.',
                  actionLabel: 'Retry',
                  onAction: homeNotifier.retry,
                ),
              ),
            )
          else if (homeState.status == HomeStatus.empty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
                child: EmptyState(
                  title: 'No Matches',
                  message: 'No matches were found for the selected date. Try another day or pull to refresh.',
                  actionLabel: 'Refresh',
                  onAction: homeNotifier.retry,
                ),
              ),
            )
          else
            SliverPadding(
              padding: _sectionPadding,
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final league = homeState.leagues[index];
                    final expanded = homeState.expandedLeagueIds.contains(league.id);

                    return LeagueCard(
                      countryCode: league.countryCode,
                      countryFlagUrl: league.countryFlagUrl,
                      leagueName: league.leagueName,
                      matchCount: league.matches.length,
                      expanded: expanded,
                      onToggle: () => homeNotifier.toggleLeagueExpanded(league.id),
                      matches: league.matches
                          .map(
                            (match) => MatchCard(
                              teamA: match.teamA,
                              teamB: match.teamB,
                              score: match.score,
                              kickOffTime: match.kickOffTime,
                              status: match.status,
                              redCardsA: match.redCardsA,
                              redCardsB: match.redCardsB,
                              yellowCardsA: match.yellowCardsA,
                              yellowCardsB: match.yellowCardsB,
                              teamALogoUrl: match.teamALogoUrl,
                              teamBLogoUrl: match.teamBLogoUrl,
                              onTap: match.matchId > 0
                                  ? () => context.goNamed(
                                        'matchDetail',
                                        pathParameters: {'matchId': match.matchId.toString()},
                                        queryParameters: {
                                          'homeTeamId': match.homeTeamId.toString(),
                                          'awayTeamId': match.awayTeamId.toString(),
                                        },
                                      )
                                  : null,
                            ),
                          )
                          .toList(),
                    );
                  },
                  childCount: homeState.leagues.length,
                ),
              ),
            ),
          const SliverPadding(
            padding: EdgeInsets.only(bottom: 32),
          ),
        ],
      ),
    );
  }
}

class _FollowingPreview extends StatelessWidget {
  const _FollowingPreview({required this.items});

  final List<FavoriteItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items
          .map(
            (item) => Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: theme.colorScheme.onSurface.withAlpha(20),
                ),
              ),
              child: Text(
                item.title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
