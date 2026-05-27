import 'package:go_router/go_router.dart';
import 'package:fover/features/favorites/presentation/favorites_page.dart';
import 'package:fover/features/home/presentation/home_page.dart';
import 'package:fover/features/leagues/presentation/leagues_page.dart';
import 'package:fover/features/news/presentation/news_page.dart';
import 'package:fover/features/navigation/presentation/bottom_nav_page.dart';
import 'package:fover/features/navigation/presentation/more_page.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/',
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
    ],
  );
}
