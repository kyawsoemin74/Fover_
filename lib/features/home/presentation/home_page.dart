import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fover/core/providers/navigation_provider.dart';
import 'package:fover/features/home/domain/models/league_model.dart';
import 'package:fover/features/home/domain/models/match_model.dart';
import 'package:fover/shared/widgets/custom_appbar.dart';
import 'package:fover/shared/widgets/date_selector.dart';
import 'package:fover/shared/widgets/empty_state.dart';
import 'package:fover/shared/widgets/league_card.dart';
import 'package:fover/shared/widgets/match_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static const _sectionPadding = EdgeInsets.symmetric(horizontal: 16);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(selectedDateTabProvider);
    final showFollowing = ref.watch(showFollowingProvider);
    final expandedLeagueIds = ref.watch(expandedLeagueIdsProvider);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
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
                  selectedTab: selectedTab,
                  onTabSelected: (tab) {
                    ref.read(selectedDateTabProvider.notifier).state = tab;
                  },
                ),
                const SizedBox(height: 24),
                _SectionHeader(
                  title: 'Following',
                  actionLabel: showFollowing ? 'Hide' : 'Show',
                  onAction: () {
                    ref.read(showFollowingProvider.notifier).state = !showFollowing;
                  },
                ),
                const SizedBox(height: 14),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 280),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: EmptyState(
                    key: ValueKey(showFollowing),
                    title: showFollowing ? 'No followed matches yet' : 'Following section hidden',
                    message: showFollowing
                        ? 'Add teams and leagues to keep your personalised live score feed in view.'
                        : 'Restore the following section to resume updates from teams and competitions you care about.',
                    actionLabel: showFollowing ? 'Hide section' : 'Show section',
                    onAction: () {
                      ref.read(showFollowingProvider.notifier).state = !showFollowing;
                    },
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
        SliverPadding(
          padding: _sectionPadding,
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final league = _leagueGroups[index];
                final expanded = expandedLeagueIds.contains(league.id);

                return LeagueCard(
                  countryCode: league.countryCode,
                  leagueName: league.leagueName,
                  matchCount: league.matches.length,
                  expanded: expanded,
                  onToggle: () {
                    ref.read(expandedLeagueIdsProvider.notifier).update(
                          (state) {
                            final next = Set<String>.from(state);
                            if (next.contains(league.id)) {
                              next.remove(league.id);
                            } else {
                              next.add(league.id);
                            }
                            return next;
                          },
                        );
                  },
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
                        ),
                      )
                      .toList(),
                );
              },
              childCount: _leagueGroups.length,
            ),
          ),
        ),
        const SliverPadding(
          padding: EdgeInsets.only(bottom: 32),
        ),
      ],
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

const _leagueGroups = [
  LeagueInfo(
    id: 'premier-league',
    countryCode: 'ENG',
    leagueName: 'Premier League',
    matches: [
      MatchInfo(
        teamA: 'Manchester Utd',
        teamB: 'Liverpool',
        score: '1 - 2',
        kickOffTime: '72',
        status: 'LIVE',
        redCardsA: 0,
        redCardsB: 1,
        yellowCardsA: 1,
        yellowCardsB: 0,
      ),
      MatchInfo(
        teamA: 'Chelsea',
        teamB: 'Arsenal',
        score: '0 - 0',
        kickOffTime: 'HT',
        status: 'HT',
      ),
    ],
  ),
  LeagueInfo(
    id: 'la-liga',
    countryCode: 'ESP',
    leagueName: 'La Liga',
    matches: [
      MatchInfo(
        teamA: 'Barcelona',
        teamB: 'Real Madrid',
        score: '2 - 1',
        kickOffTime: 'FT',
        status: 'FT',
      ),
    ],
  ),
  LeagueInfo(
    id: 'champions-league',
    countryCode: 'EU',
    leagueName: 'Champions League',
    matches: [
      MatchInfo(
        teamA: 'Bayern',
        teamB: 'PSG',
        score: '3 - 3',
        kickOffTime: '88',
        status: 'LIVE',
        redCardsA: 1,
        redCardsB: 0,
        yellowCardsA: 1,
        yellowCardsB: 2,
      ),
    ],
  ),
];
