import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fover/features/auth/providers/auth_provider.dart';
import 'package:fover/features/home/presentation/widgets/home_date_selector.dart';
import 'package:fover/shared/widgets/profile_action_button.dart';

class HomeTopSection extends ConsumerWidget {
  const HomeTopSection({
    super.key,
    this.onNotifications,
    this.onSearch,
    this.onProfile,
  });

  final VoidCallback? onNotifications;
  final VoidCallback? onSearch;
  final VoidCallback? onProfile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final avatarUrl = authState.user?.avatarUrl;

    return Material(
      color: theme.colorScheme.surface,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withAlpha(18),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withAlpha(24),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.sports_soccer,
                    color: theme.colorScheme.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Fover',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.08,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                ProfileActionButton(
                  icon: Icons.notifications_none,
                  tooltip: 'Notifications',
                  onTap: onNotifications,
                ),
                const SizedBox(width: 4),
                ProfileActionButton(
                  icon: Icons.search,
                  tooltip: 'Search',
                  onTap: onSearch,
                ),
                const SizedBox(width: 4),
                ProfileActionButton(
                  icon: avatarUrl?.isNotEmpty == true
                      ? null
                      : Icons.person_outline,
                  tooltip: 'Profile',
                  onTap: onProfile,
                  child: avatarUrl?.isNotEmpty == true
                      ? CircleAvatar(
                          radius: 16,
                          backgroundImage: NetworkImage(avatarUrl!),
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                        )
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 4),
            const HomeDateSelector(),
          ],
        ),
      ),
    );
  }
}

class HomeTopHeaderDelegate extends SliverPersistentHeaderDelegate {
  const HomeTopHeaderDelegate({
    required this.child,
    required this.minExtent,
    required this.maxExtent,
  });

  final Widget child;
  @override
  final double minExtent;
  @override
  final double maxExtent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant HomeTopHeaderDelegate oldDelegate) {
    return oldDelegate.child != child ||
        oldDelegate.maxExtent != maxExtent ||
        oldDelegate.minExtent != minExtent;
  }
}
