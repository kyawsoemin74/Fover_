import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.onNotifications,
    this.onCalendar,
    this.onSearch,
    this.onMenu,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onNotifications;
  final VoidCallback? onCalendar;
  final VoidCallback? onSearch;
  final VoidCallback? onMenu;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: primary.withValues(alpha: 0.18),
            ),
            child: Icon(
              Icons.sports_soccer,
              color: primary,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onNotifications,
            icon: const Icon(Icons.notifications_none),
            tooltip: 'Notifications',
            color: color,
            splashRadius: 22,
          ),
          IconButton(
            onPressed: onCalendar,
            icon: const Icon(Icons.calendar_today_outlined),
            tooltip: 'Calendar',
            color: color,
            splashRadius: 22,
          ),
          IconButton(
            onPressed: onSearch,
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            color: color,
            splashRadius: 22,
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
