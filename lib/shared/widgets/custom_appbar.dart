import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.onNotifications,
    this.onCalendar,
    this.onSearch,
    this.onMenu,
  });

  final String title;
  final VoidCallback? onNotifications;
  final VoidCallback? onCalendar;
  final VoidCallback? onSearch;
  final VoidCallback? onMenu;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(context).colorScheme.primary.withAlpha(46),
            ),
            child: const Center(
              child: Icon(
                Icons.sports_soccer,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fover',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onNotifications,
            icon: const Icon(Icons.notifications_none),
            tooltip: 'Notifications',
            color: color,
          ),
          IconButton(
            onPressed: onCalendar,
            icon: const Icon(Icons.calendar_today_outlined),
            tooltip: 'Calendar',
            color: color,
          ),
          IconButton(
            onPressed: onSearch,
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            color: color,
          ),
          PopupMenuButton<String>(
            color: Theme.of(context).colorScheme.surface,
            icon: Icon(
              Icons.more_vert,
              color: color,
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'refresh', child: Text('Refresh')),
              const PopupMenuItem(value: 'settings', child: Text('Settings')),
            ],
            onSelected: (value) {
              if (value == 'settings') {
                onMenu?.call();
              }
            },
          ),
        ],
      ),
    );
  }
}
