import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:go_router/go_router.dart';
import 'package:fover/features/auth/data/auth_api_service.dart';
import 'package:fover/features/auth/providers/auth_provider.dart';
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

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late final HomeNotifier _homeNotifier;
  late final PageController _pageController;
  bool _isSigningIn = false;

  @override
  void initState() {
    super.initState();
    _homeNotifier = ref.read(homeProvider.notifier);
    _pageController = PageController(initialPage: _initialPageIndex());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _homeNotifier.loadMatches();
      _homeNotifier.startLiveRefresh();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
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
    final dates = ref.watch(dateRangeProvider);

    _syncPageController(homeState.selectedDate, dates);

    return Column(
      children: [
        HomeTopSection(
          onNotifications: () {},
          onSearch: () {},
          onProfile: () => _showProfileSheet(context),
        ),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: dates.length,
            onPageChanged: (index) {
              if (index >= 0 && index < dates.length) {
                homeNotifier.selectDate(dates[index]);
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 24,
                        ),
                        child: EmptyState(
                          title: 'Unable to load matches',
                          message:
                              homeState.errorMessage ??
                              'Please check your connection and try again.',
                          actionLabel: 'Retry',
                          onAction: homeNotifier.retry,
                        ),
                      )
                    else if (homeState.status == HomeStatus.empty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 24,
                        ),
                        child: EmptyState(
                          title: 'No Matches',
                          message:
                              'No matches were found for the selected date. Try another day or pull to refresh.',
                          actionLabel: 'Refresh',
                          onAction: homeNotifier.retry,
                        ),
                      )
                    else
                      ...homeState.leagues.map((league) {
                        final expanded = homeState.expandedLeagueIds.contains(
                          league.id,
                        );
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: LeagueCard(
                            countryCode: league.countryCode,
                            countryFlagUrl: league.countryFlagUrl,
                            leagueLogoUrl: league.leagueLogoUrl,
                            leagueName: league.leagueName,
                            matchCount: league.matches.length,
                            expanded: expanded,
                            onToggle: () =>
                                homeNotifier.toggleLeagueExpanded(league.id),
                            matches: league.matches,
                            onMatchTap: (match) => context.pushNamed(
                              'matchDetail',
                              pathParameters: {
                                'matchId': match.matchId.toString(),
                              },
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
              );
            },
          ),
        ),
      ],
    );
  }

  int _initialPageIndex() {
    final dates = ref.read(dateRangeProvider);
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final index = dates.indexWhere(
      (date) => DateUtils.isSameDay(date, normalizedToday),
    );
    return index == -1 ? 0 : index;
  }

  void _syncPageController(DateTime selectedDate, List<DateTime> dates) {
    final selectedIndex = dates.indexWhere(
      (date) => DateUtils.isSameDay(date, selectedDate),
    );
    if (selectedIndex == -1) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_pageController.hasClients) return;
      final currentPage = _pageController.page?.round() ?? _pageController.initialPage;
      if (currentPage == selectedIndex) return;
      _pageController.animateToPage(
        selectedIndex,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Future<void> _signInWithGoogle(BuildContext sheetContext) async {
    if (_isSigningIn) return;

    setState(() => _isSigningIn = true);

    try {
      final account = await GoogleSignIn.instance.authenticate();
      final authData = account.authentication;
      final idToken = authData.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw const FormatException(
          'Google sign-in did not return an id token.',
        );
      }

      final response = await ref
          .read(authApiServiceProvider)
          .signInWithGoogle(idToken);

      await ref
          .read(authProvider.notifier)
          .saveSession(
            response.user,
            response.accessToken,
            refreshToken: response.refreshToken,
          );

      if (!mounted || !sheetContext.mounted) return;
      Navigator.of(sheetContext).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signed in with Google successfully.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error is Exception ? error.toString() : 'Google sign-in failed.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSigningIn = false);
      }
    }
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
                  onPressed: _isSigningIn
                      ? null
                      : () => _signInWithGoogle(sheetContext),
                  icon: _isSigningIn
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.login_rounded),
                  label: Text(
                    _isSigningIn ? 'Signing in…' : 'Continue with Google',
                  ),
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
