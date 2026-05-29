import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fover/features/home/providers/date_selection_provider.dart';
import 'package:fover/features/home/providers/home_provider.dart';

class HomeTopSection extends ConsumerWidget {
  const HomeTopSection({
    super.key,
    this.onNotifications,
    this.onCalendar,
    this.onSearch,
    this.onMenu,
  });

  final VoidCallback? onNotifications;
  final VoidCallback? onCalendar;
  final VoidCallback? onSearch;
  final VoidCallback? onMenu;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

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
                      fontSize: 16,
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
            const SizedBox(height: 4),
            const HomeDateTabs(),
          ],
        ),
      ),
    );
  }
}

class HomeDateTabs extends ConsumerStatefulWidget {
  const HomeDateTabs({super.key});

  @override
  ConsumerState<HomeDateTabs> createState() => _HomeDateTabsState();
}

class _HomeDateTabsState extends ConsumerState<HomeDateTabs> {
  static const double _itemWidth = 68.0;
  static const double _barHeight = 64.0;
  static const double _itemSpacing = 4.0;
  static const double _horizontalPadding = 1.5;

  List<DateTime> _visibleDates(List<DateTime> dates, int selectedIndex) {
    if (dates.length <= 5) return dates;

    var start = selectedIndex - 2;
    var end = selectedIndex + 2;

    if (start < 0) {
      end += -start;
      start = 0;
    }

    if (end >= dates.length) {
      final overflow = end - (dates.length - 1);
      start -= overflow;
      end = dates.length - 1;
      if (start < 0) start = 0;
    }

    return dates.sublist(start, end + 1);
  }

  @override
  Widget build(BuildContext context) {
    final dates = ref.watch(dateRangeProvider);
    final selectedDate = ref.watch(homeProvider.select((state) => state.selectedDate));
    final homeNotifier = ref.read(homeProvider.notifier);

    final selectedIndex = dates.indexWhere((d) => DateUtils.isSameDay(d, selectedDate));
    final visibleDates = selectedIndex != -1 ? _visibleDates(dates, selectedIndex) : dates;

    return SizedBox(
      height: _barHeight,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < visibleDates.length; i++) ...[
                SizedBox(
                  width: _itemWidth,
                  child: _DateTabItem(
                    date: visibleDates[i],
                    isSelected: DateUtils.isSameDay(visibleDates[i], selectedDate),
                    onTap: () => homeNotifier.selectDate(visibleDates[i]),
                  ),
                ),
                if (i < visibleDates.length - 1)
                  const SizedBox(width: _itemSpacing),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DateTabItem extends StatelessWidget {
  const _DateTabItem({
    required this.date,
    required this.isSelected,
    required this.onTap,
  });

  final DateTime date;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String getDayName(DateTime d) {
      if (DateUtils.isSameDay(d, DateTime.now())) return 'TODAY';
      const weekdays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
      return weekdays[d.weekday - 1];
    }

    String getMonthName(DateTime d) {
      const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
      return months[d.month - 1];
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: theme.colorScheme.primary.withAlpha(24),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 6),
            decoration: BoxDecoration(
              color: isSelected ? theme.colorScheme.primary.withAlpha(180) : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withAlpha(18),
                width: 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  getDayName(date),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                    letterSpacing: 0.15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${date.day} ${getMonthName(date)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? theme.colorScheme.onPrimary.withAlpha(230)
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  height: 3,
                  width: isSelected ? 28 : 16,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.surface,
                  ),
                ),
              ],
            ),
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
      color: theme.colorScheme.onSurface.withAlpha(10),
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
