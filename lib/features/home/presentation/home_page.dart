import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
              minExtent: 160,
              maxExtent: 160,
              child: HomeTopSection(
                selectedTab: homeState.selectedTab,
                onTabSelected: homeNotifier.selectDate,
                onNotifications: () {},
                onCalendar: () {},
                onSearch: () {},
                onMenu: () {},
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            sliver: SliverToBoxAdapter(
              child: HomeSectionHeader(
                title: 'Following',
                actionLabel: homeState.showFollowing ? 'Hide' : 'Show',
                onAction: homeNotifier.toggleFollowing,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            sliver: SliverToBoxAdapter(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: EmptyState(
                  key: ValueKey(homeState.showFollowing),
                  title: homeState.showFollowing
                      ? 'No followed matches yet'
                      : 'Following section hidden',
                  message: homeState.showFollowing
                      ? 'Add teams and leagues to keep your personalised live score feed in view.'
                      : 'Restore the following section to resume updates from teams and competitions you care about.',
                  actionLabel: homeState.showFollowing ? 'Hide section' : 'Show section',
                  onAction: homeNotifier.toggleFollowing,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            sliver: SliverToBoxAdapter(
              child: HomeSectionHeader(
                title: 'Competitions',
                actionLabel: 'Sort',
                onAction: () {},
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
                  title: 'No matches available',
                  message: 'There are no live or scheduled matches for the selected date.',
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
