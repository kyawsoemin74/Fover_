import 'package:go_router/go_router.dart';
import 'package:fover/features/favorites/presentation/favorites_page.dart';
import 'package:fover/features/home/presentation/home_page.dart';
import 'package:fover/features/leagues/presentation/leagues_page.dart';
import 'package:fover/features/matches/presentation/match_detail_page.dart';
import 'package:fover/features/news/presentation/news_detail_page.dart';
import 'package:fover/features/news/presentation/news_page.dart';
import 'package:fover/features/navigation/presentation/bottom_nav_page.dart';
import 'package:fover/features/navigation/presentation/more_page.dart';

class AppRouter {
  AppRouter._();

  static const String _initialLocation = String.fromEnvironment(
    'FOOVER_INITIAL_ROUTE',
    defaultValue: '/',
  );

  static final router = GoRouter(
    initialLocation: _initialLocation,
    routes: [
      ShellRoute(
        builder: (context, state, child) => BottomNavPage(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'matches',
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: '/news',
            name: 'news',
            builder: (context, state) => const NewsPage(),
          ),
          GoRoute(
            path: '/news/:id',
            name: 'newsDetail',
            builder: (context, state) {
              final articleId = state.pathParameters['id'] ?? '';
              return NewsDetailPage(articleId: Uri.decodeComponent(articleId));
            },
          ),
          GoRoute(
            path: '/leagues',
            name: 'leagues',
            builder: (context, state) => const LeaguesPage(),
          ),
          GoRoute(
            path: '/favorites',
            name: 'favorites',
            builder: (context, state) => const FavoritesPage(),
          ),
          GoRoute(
            path: '/more',
            name: 'more',
            builder: (context, state) => const MorePage(),
          ),
        ],
      ),
      GoRoute(
        path: '/match/:matchId',
        name: 'matchDetail',
        builder: (context, state) {
          final matchId =
              int.tryParse(state.pathParameters['matchId'] ?? '') ?? 0;
          final homeTeamId =
              int.tryParse(state.uri.queryParameters['homeTeamId'] ?? '') ?? 0;
          final awayTeamId =
              int.tryParse(state.uri.queryParameters['awayTeamId'] ?? '') ?? 0;
          return MatchDetailPage(
            matchId: matchId,
            homeTeamId: homeTeamId,
            awayTeamId: awayTeamId,
          );
        },
      ),
    ],
  );
}
