import 'package:flutter/material.dart';
import 'package:fover/core/providers/navigation_provider.dart';

class HomeTopSection extends StatelessWidget {
  const HomeTopSection({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
    this.onNotifications,
    this.onCalendar,
    this.onSearch,
    this.onMenu,
  });

  final FoverDateTab selectedTab;
  final ValueChanged<FoverDateTab> onTabSelected;
  final VoidCallback? onNotifications;
  final VoidCallback? onCalendar;
  final VoidCallback? onSearch;
  final VoidCallback? onMenu;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.07),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.sports_soccer,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Fover',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.08,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                _IconAction(
                  icon: Icons.notifications_none,
                  onTap: onNotifications,
                  tooltip: 'Notifications',
                ),
                const SizedBox(width: 4),
                _IconAction(
                  icon: Icons.calendar_today_outlined,
                  onTap: onCalendar,
                  tooltip: 'Calendar',
                ),
                const SizedBox(width: 4),
                _IconAction(
                  icon: Icons.search,
                  onTap: onSearch,
                  tooltip: 'Search',
                ),
                const SizedBox(width: 4),
                _IconAction(
                  icon: Icons.more_vert,
                  onTap: onMenu,
                  tooltip: 'More',
                ),
              ],
            ),
            const SizedBox(height: 8),
            HomeDateTabs(
              selectedTab: selectedTab,
              onTabSelected: onTabSelected,
            ),
          ],
        ),
        ),
      ),
    );
  }
}

class HomeDateTabs extends StatelessWidget {
  const HomeDateTabs({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  final FoverDateTab selectedTab;
  final ValueChanged<FoverDateTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: FoverDateTab.values.map((tab) {
          return Expanded(
            child: _DateTabItem(
              tab: tab,
              isSelected: selectedTab == tab,
              onTap: () => onTabSelected(tab),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _DateTabItem extends StatelessWidget {
  const _DateTabItem({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  final FoverDateTab tab;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF22C55E) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tab.title.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  color: isSelected
                      ? Colors.white
                      : theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                tab.label(now),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.88)
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                height: 4,
                width: isSelected ? 40 : 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isSelected
                      ? Colors.white
                      : theme.colorScheme.surface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    this.onTap,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.onSurface.withValues(alpha: 0.03),
      shape: const CircleBorder(),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        tooltip: tooltip,
        splashRadius: 20,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 36, height: 36),
        color: theme.colorScheme.onSurface,
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant HomeTopHeaderDelegate oldDelegate) {
    return oldDelegate.child != child || oldDelegate.maxExtent != maxExtent || oldDelegate.minExtent != minExtent;
  }
}
