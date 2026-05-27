import 'package:cached_network_image/cached_network_image.dart';
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
    this.countryFlagUrl,
  });

  final String countryCode;
  final String leagueName;
  final int matchCount;
  final bool expanded;
  final VoidCallback onToggle;
  final List<Widget> matches;
  final String? countryFlagUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        child: Column(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: onToggle,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.22),
                        child: countryFlagUrl != null && countryFlagUrl!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: countryFlagUrl!,
                                fit: BoxFit.cover,
                                width: 30,
                                height: 30,
                                errorWidget: (context, url, error) => Text(
                                  countryCode,
                                  style: theme.textTheme.labelLarge?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                              )
                            : Text(
                                countryCode,
                                style: theme.textTheme.labelLarge?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w800,
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
                              style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$matchCount matches',
                              style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          matchCount.toString(),
                          style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        expanded ? Icons.expand_less : Icons.expand_more,
                        color: theme.colorScheme.onSurface,
                      ),
                    ],
                  ),
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
