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
// match widgets are now built lazily inside LeagueCard

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late final HomeNotifier _homeNotifier;

  @override
  void initState() {
    super.initState();
    _homeNotifier = ref.read(homeProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _homeNotifier.loadMatches();
      _homeNotifier.startLiveRefresh();
    });
  }

  @override
  void dispose() {
    _homeNotifier.stopLiveRefresh();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);
    final homeNotifier = _homeNotifier;
    final favoritesState = ref.watch(favoritesProvider);
    final followingCount = ref.watch(followingCountProvider);
    final followingItems = favoritesState.items;

    return Column(
      children: [
        HomeTopSection(
          onNotifications: () {},
          onSearch: () {},
          onProfile: () => _showProfileSheet(context),
        ),
        Expanded(
          child: RefreshIndicator(
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
                  }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showProfileSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withAlpha(30),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Welcome to Fover',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to sync favorites and notifications',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  icon: const Icon(Icons.login_rounded),
                  label: const Text('Continue with Google'),
                ),
              ),
            ],
          ),
        );
      },
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
