import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fover/features/home/providers/home_provider.dart';
import 'package:fover/features/home/providers/home_state.dart';
import 'package:fover/shared/widgets/custom_appbar.dart';
import 'package:fover/shared/widgets/date_selector.dart';
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
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomAppBar(
                    title: 'Fover',
                    subtitle: 'Live matches',
                    onNotifications: () {},
                    onCalendar: () {},
                    onSearch: () {},
                    onMenu: () {},
                  ),
                  const SizedBox(height: 18),
                  DateSelector(
                    selectedTab: homeState.selectedTab,
                    onTabSelected: homeNotifier.selectDate,
                  ),
                  const SizedBox(height: 24),
                  _SectionHeader(
                    title: 'Following',
                    actionLabel: homeState.showFollowing ? 'Hide' : 'Show',
                    onAction: homeNotifier.toggleFollowing,
                  ),
                  const SizedBox(height: 14),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: EmptyState(
                      key: ValueKey(homeState.showFollowing),
                      title: homeState.showFollowing ? 'No followed matches yet' : 'Following section hidden',
                      message: homeState.showFollowing
                          ? 'Add teams and leagues to keep your personalised live score feed in view.'
                          : 'Restore the following section to resume updates from teams and competitions you care about.',
                      actionLabel: homeState.showFollowing ? 'Hide section' : 'Show section',
                      onAction: homeNotifier.toggleFollowing,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 8),
            sliver: SliverToBoxAdapter(
              child: _SectionHeader(
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        TextButton(
          onPressed: onAction,
          child: Text(actionLabel.toUpperCase()),
        ),
      ],
    );
  }
}
