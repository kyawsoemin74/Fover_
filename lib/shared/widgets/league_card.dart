import 'package:flutter/material.dart';

class LeagueCard extends StatelessWidget {
  const LeagueCard({
    super.key,
    required this.countryCode,
    required this.leagueName,
    required this.matchCount,
    required this.expanded,
    required this.onToggle,
    required this.matches,
  });

  final String countryCode;
  final String leagueName;
  final int matchCount;
  final bool expanded;
  final VoidCallback onToggle;
  final List<Widget> matches;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        child: Column(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(46),
                      child: Text(
                        countryCode,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            leagueName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$matchCount matches',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onSurface.withAlpha(20),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        matchCount.toString(),
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      expanded ? Icons.expand_less : Icons.expand_more,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ],
                ),
              ),
            ),
            if (expanded)
              Padding(
                padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
                child: Column(children: matches),
              ),
          ],
        ),
      ),
    );
  }
}
