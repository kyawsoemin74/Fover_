import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fover/core/providers/navigation_provider.dart';
import 'package:fover/shared/widgets/custom_appbar.dart';
import 'package:fover/shared/widgets/date_selector.dart';
import 'package:fover/shared/widgets/empty_following.dart';
import 'package:fover/shared/widgets/league_card.dart';
import 'package:fover/shared/widgets/match_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(selectedDateTabProvider);
    final showFollowing = ref.watch(showFollowingProvider);
    final expandedLeagueIds = ref.watch(expandedLeagueIdsProvider);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [
                CustomAppBar(
                  title: 'Live matches',
                  onCalendar: () {},
                  onNotifications: () {},
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
                EmptyFollowing(
                  isExpanded: showFollowing,
                  onToggle: () {
                    ref.read(showFollowingProvider.notifier).state = !showFollowing;
                  },
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          sliver: SliverToBoxAdapter(
            child: _SectionHeader(
              title: 'Competitions',
              actionLabel: 'Sort',
              onAction: () {},
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final group = _leagueGroups[index];
                final expanded = expandedLeagueIds.contains(group.id);

                return LeagueCard(
                  countryCode: group.countryCode,
                  leagueName: group.leagueName,
                  matchCount: group.matches.length,
                  expanded: expanded,
                  onToggle: () {
                    ref.read(expandedLeagueIdsProvider.notifier).update(
                          (state) {
                            final next = Set<String>.from(state);
                            if (next.contains(group.id)) {
                              next.remove(group.id);
                            } else {
                              next.add(group.id);
                            }
                            return next;
                          },
                        );
                  },
                  matches: group.matches
                      .map(
                        (match) => MatchCard(
                          teamA: match.teamA,
                          teamB: match.teamB,
                          score: match.score,
                          matchTime: match.matchTime,
                          status: match.status,
                          redCardsA: match.redCardsA,
                          redCardsB: match.redCardsB,
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
          padding: EdgeInsets.symmetric(vertical: 24),
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

class _LeagueGroup {
  const _LeagueGroup({
    required this.id,
    required this.countryCode,
    required this.leagueName,
    required this.matches,
  });

  final String id;
  final String countryCode;
  final String leagueName;
  final List<_MatchInfo> matches;
}

class _MatchInfo {
  const _MatchInfo({
    required this.teamA,
    required this.teamB,
    required this.score,
    required this.matchTime,
    required this.status,
    this.redCardsA = 0,
    this.redCardsB = 0,
  });

  final String teamA;
  final String teamB;
  final String score;
  final String matchTime;
  final String status;
  final int redCardsA;
  final int redCardsB;
}

const _leagueGroups = [
  _LeagueGroup(
    id: 'premier-league',
    countryCode: 'ENG',
    leagueName: 'Premier League',
    matches: [
      _MatchInfo(
        teamA: 'Manchester Utd',
        teamB: 'Liverpool',
        score: '1 - 2',
        matchTime: '72',
        status: 'LIVE',
        redCardsA: 0,
        redCardsB: 1,
      ),
      _MatchInfo(
        teamA: 'Chelsea',
        teamB: 'Arsenal',
        score: '0 - 0',
        matchTime: 'HT',
        status: 'HT',
      ),
    ],
  ),
  _LeagueGroup(
    id: 'la-liga',
    countryCode: 'ESP',
    leagueName: 'La Liga',
    matches: [
      _MatchInfo(
        teamA: 'Barcelona',
        teamB: 'Real Madrid',
        score: '2 - 1',
        matchTime: 'FT',
        status: 'FT',
      ),
    ],
  ),
  _LeagueGroup(
    id: 'champions-league',
    countryCode: 'EU',
    leagueName: 'Champions League',
    matches: [
      _MatchInfo(
        teamA: 'Bayern',
        teamB: 'PSG',
        score: '3 - 3',
        matchTime: '88',
        status: 'LIVE',
        redCardsA: 1,
        redCardsB: 0,
      ),
    ],
  ),
];
