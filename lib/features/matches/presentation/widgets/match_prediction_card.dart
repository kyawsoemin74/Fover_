import 'package:flutter/material.dart';

class MatchPredictionCard extends StatelessWidget {
  const MatchPredictionCard({
    super.key,
    required this.homeTeamName,
    required this.awayTeamName,
    this.totalVotes = 0,
    this.homeVotes = 0,
    this.drawVotes = 0,
    this.awayVotes = 0,
  });

  final String homeTeamName;
  final String awayTeamName;
  final int totalVotes;
  final int homeVotes;
  final int drawVotes;
  final int awayVotes;

  @override
  Widget build(BuildContext context) {
    final options = <_PredictionOption>[
      _PredictionOption(
        label: homeTeamName.isNotEmpty ? homeTeamName : 'Home Team',
        subtitle: 'Home',
      ),
      _PredictionOption(
        label: 'Draw',
        subtitle: 'Draw',
      ),
      _PredictionOption(
        label: awayTeamName.isNotEmpty ? awayTeamName : 'Away Team',
        subtitle: 'Away',
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1220),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  'Who Will Win?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                'Total votes: $totalVotes',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white60,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = (constraints.maxWidth - 16) / 3;
              return Row(
                children: options.map((option) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _OptionButton(option: option, width: itemWidth),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PredictionOption {
  const _PredictionOption({
    required this.label,
    required this.subtitle,
  });

  final String label;
  final String subtitle;
}

class _OptionButton extends StatelessWidget {
  const _OptionButton({
    required this.option,
    required this.width,
  });

  final _PredictionOption option;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Material(
        color: const Color(0xFF121A2D),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: null,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF22304A)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  option.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  option.subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white60,
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
