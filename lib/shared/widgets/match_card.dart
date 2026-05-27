import 'package:flutter/material.dart';

class MatchCard extends StatelessWidget {
  const MatchCard({
    super.key,
    required this.teamA,
    required this.teamB,
    required this.score,
    required this.matchTime,
    required this.status,
    required this.redCardsA,
    required this.redCardsB,
  });

  final String teamA;
  final String teamB;
  final String score;
  final String matchTime;
  final String status;
  final int redCardsA;
  final int redCardsB;

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(context).colorScheme.onSurfaceVariant;
    final cardColor = Theme.of(context).colorScheme.surface;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TeamLabel(name: teamA, redCards: redCardsA),
                const SizedBox(height: 10),
                _TeamLabel(name: teamB, redCards: redCardsB),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                score,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: status == 'LIVE' ? Colors.red.shade600 : Colors.white10,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  status,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: status == 'LIVE' ? Colors.white : Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                matchTime,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: secondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TeamLabel extends StatelessWidget {
  const _TeamLabel({
    required this.name,
    required this.redCards,
  });

  final String name;
  final int redCards;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            name,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        if (redCards > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.shade800,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '+$redCards',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
      ],
    );
  }
}
