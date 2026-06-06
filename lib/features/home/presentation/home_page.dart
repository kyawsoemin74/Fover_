import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fover/features/favorites/providers/favorites_provider.dart';
import 'package:fover/features/home/providers/date_selection_provider.dart';
import 'package:fover/features/home/providers/home_provider.dart';
import 'package:fover/features/home/providers/home_state.dart';
import 'package:fover/features/home/presentation/widgets/home_section_header.dart';
import 'package:fover/features/home/presentation/widgets/home_top_section.dart';
import 'package:fover/shared/widgets/empty_state.dart';
import 'package:fover/shared/widgets/home_loading_skeleton.dart';
import 'package:fover/shared/widgets/league_card.dart';
// match widgets are now built lazily inside LeagueCard

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  static const _sectionPadding = EdgeInsets.symmetric(horizontal: 16);

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late final HomeNotifier _homeNotifier;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _homeNotifier = ref.read(homeProvider.notifier);
    final dates = ref.read(dateRangeProvider);
    final selectedDate = ref.read(homeProvider).selectedDate;
    final initialPage = dates.indexWhere((date) => DateUtils.isSameDay(date, selectedDate));
    _pageController = PageController(initialPage: initialPage >= 0 ? initialPage : 0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _homeNotifier.loadMatches();
      _homeNotifier.startLiveRefresh();
    });
  }

  @override
  void dispose() {
    _homeNotifier.stopLiveRefresh();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);
    final homeNotifier = _homeNotifier;
    final favoritesState = ref.watch(favoritesProvider);
    final followingCount = ref.watch(followingCountProvider);
    final followingItems = favoritesState.items;
    final dates = ref.watch(dateRangeProvider);
    final initialPage = dates.indexWhere((date) => DateUtils.isSameDay(date, homeState.selectedDate));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_pageController.hasClients) return;
      final currentPage = _pageController.page?.round() ?? _pageController.initialPage;
      if (initialPage >= 0 && currentPage != initialPage) {
        _pageController.animateToPage(
          initialPage,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
        );
      }
    });

    return Column(
      children: [
        HomeTopSection(
          onNotifications: () {},
          onCalendar: () {},
          onSearch: () {},
          onMenu: () {},
          pageController: _pageController,
        ),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: dates.length,
            physics: const PageScrollPhysics(),
            onPageChanged: (index) async {
              final targetDate = dates[index];
              if (!DateUtils.isSameDay(targetDate, homeState.selectedDate)) {
                await homeNotifier.selectDate(targetDate);
              }
            },
            itemBuilder: (context, index) {
              return RefreshIndicator(
                onRefresh: homeNotifier.refresh,
                edgeOffset: 0,
                color: Theme.of(context).colorScheme.primary,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  children: [
                    if (followingCount > 0) ...[
                      HomeSectionHeader(
                        title: 'Following ($followingCount)',
                        actionLabel: homeState.showFollowing ? 'Hide' : 'Show',
                        onAction: homeNotifier.toggleFollowing,
                      ),
                      if (homeState.showFollowing)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: _FollowingPreview(items: followingItems),
                        ),
                    ],
                    const SizedBox(height: 12),
                    const HomeSectionHeader(title: ''),
                    const SizedBox(height: 12),
                    if (homeState.status == HomeStatus.loading ||
                        homeState.status == HomeStatus.initial)
                      const HomeLoadingSkeleton()
                    else if (homeState.status == HomeStatus.error)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 24),
                        child: EmptyState(
                          title: 'Unable to load matches',
                          message: homeState.errorMessage ??
                              'Please check your connection and try again.',
                          actionLabel: 'Retry',
                          onAction: homeNotifier.retry,
                        ),
                      )
                    else if (homeState.status == HomeStatus.empty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 24),
                        child: EmptyState(
                          title: 'No Matches',
                          message: 'No matches were found for the selected date. Try another day or pull to refresh.',
                          actionLabel: 'Refresh',
                          onAction: homeNotifier.retry,
                        ),
                      )
                    else
                      ...homeState.leagues.map((league) {
                        final expanded = homeState.expandedLeagueIds.contains(league.id);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: LeagueCard(
                            countryCode: league.countryCode,
                            countryFlagUrl: league.countryFlagUrl,
                            leagueLogoUrl: league.leagueLogoUrl,
                            leagueName: league.leagueName,
                            matchCount: league.matches.length,
                            expanded: expanded,
                            onToggle: () => homeNotifier.toggleLeagueExpanded(league.id),
                            matches: league.matches,
                            onMatchTap: (match) => context.pushNamed(
                              'matchDetail',
                              pathParameters: {'matchId': match.matchId.toString()},
                              queryParameters: {
                                'homeTeamId': match.homeTeamId.toString(),
                                'awayTeamId': match.awayTeamId.toString(),
                              },
                            ),
                          ),
                        );
                      }).toList(),
                  ],
                ),
              );
            },
          ),
        ),
      ],
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
