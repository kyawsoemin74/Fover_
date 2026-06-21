import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fover/features/home/providers/date_selection_provider.dart';
import 'package:fover/features/home/providers/home_provider.dart';

class HomeDateSelector extends ConsumerStatefulWidget {
  const HomeDateSelector({super.key});

  @override
  ConsumerState<HomeDateSelector> createState() => _HomeDateSelectorState();
}

class _HomeDateSelectorState extends ConsumerState<HomeDateSelector> {
  static const double _itemWidth = 72;
  static const double _itemGap = 8;
  static const double _itemHeight = 60;

  final ScrollController _scrollController = ScrollController();
  int? _lastCenteredIndex;
  int? _pendingCenterIndex;
  double? _lastViewportWidth;
  double? _pendingViewportWidth;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dates = ref.watch(dateRangeProvider);
    final selectedDate = ref.watch(homeProvider.select((state) => state.selectedDate));
    final homeNotifier = ref.read(homeProvider.notifier);

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportWidth = constraints.maxWidth;
        final selectedIndex = dates.indexWhere(
          (date) => DateUtils.isSameDay(date, selectedDate),
        );

        if (selectedIndex != -1 &&
            (selectedIndex != _lastCenteredIndex ||
                _lastViewportWidth != viewportWidth)) {
          _pendingCenterIndex = selectedIndex;
          _pendingViewportWidth = viewportWidth;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _tryCenterPendingIndex(dates.length);
          });
        }

        return SizedBox(
          height: _itemHeight + 8,
          child: ListView.separated(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: dates.length,
            separatorBuilder: (context, index) => const SizedBox(width: _itemGap),
            itemBuilder: (context, index) {
              final date = dates[index];
              final isSelected = DateUtils.isSameDay(date, selectedDate);

              return _DateTile(
                width: _itemWidth,
                height: _itemHeight,
                date: date,
                isSelected: isSelected,
                onTap: () {
                  homeNotifier.selectDate(date);
                },
              );
            },
          ),
        );
      },
    );
  }

  void _tryCenterPendingIndex(int itemCount) {
    final pendingIndex = _pendingCenterIndex;
    final pendingViewportWidth = _pendingViewportWidth;
    if (pendingIndex == null) return;
    if (pendingViewportWidth == null) return;

    if (!_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _tryCenterPendingIndex(itemCount);
      });
      return;
    }

    _centerIndex(pendingIndex, itemCount, pendingViewportWidth);
    _lastCenteredIndex = pendingIndex;
    _lastViewportWidth = pendingViewportWidth;
    _pendingCenterIndex = null;
    _pendingViewportWidth = null;
  }

  void _centerIndex(int selectedIndex, int itemCount, double viewportWidth) {
    final itemExtent = _itemWidth + _itemGap;
    final contentWidth =
      (itemCount * _itemWidth) + (math.max(0, itemCount - 1) * _itemGap);
    final targetOffset =
      (selectedIndex * itemExtent) + (_itemWidth / 2) - (viewportWidth / 2);
    final maxOffset = math.max(0.0, contentWidth - viewportWidth);
    final clamped = targetOffset.clamp(0.0, maxOffset);

    _scrollController.animateTo(
      clamped,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.width,
    required this.height,
    required this.date,
    required this.isSelected,
    required this.onTap,
  });

  final double width;
  final double height;
  final DateTime date;
  final bool isSelected;
  final VoidCallback onTap;

  String _weekdayLabel(DateTime d) {
    final today = DateUtils.dateOnly(DateTime.now());
    final normalized = DateUtils.dateOnly(d);

    if (DateUtils.isSameDay(normalized, today.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    }

    if (DateUtils.isSameDay(normalized, today)) {
      return 'Today';
    }

    if (DateUtils.isSameDay(normalized, today.add(const Duration(days: 1)))) {
      return 'Tomorrow';
    }

    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return labels[normalized.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: theme.colorScheme.primary.withAlpha(24),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary.withAlpha(184)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withAlpha(24),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _weekdayLabel(date),
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurfaceVariant,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${date.day}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
