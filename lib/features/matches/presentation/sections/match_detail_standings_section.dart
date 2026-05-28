import 'package:flutter/material.dart';
import 'package:fover/features/matches/domain/models/match_detail_model.dart';

class MatchDetailStandingsSection extends StatelessWidget {
  const MatchDetailStandingsSection({super.key, required this.detail});

  final MatchDetailInfo detail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'League Standings',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white12),
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Row(
                children: const [
                  Expanded(
                    child: Text(
                      'Team',
                      style: TextStyle(
                        color: Colors.white54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 38,
                    child: Text(
                      'P',
                      style: TextStyle(
                        color: Colors.white54,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  SizedBox(width: 14),
                  SizedBox(
                    width: 38,
                    child: Text(
                      'GD',
                      style: TextStyle(
                        color: Colors.white54,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  SizedBox(width: 14),
                  SizedBox(
                    width: 38,
                    child: Text(
                      'Pts',
                      style: TextStyle(
                        color: Colors.white54,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _StandingsRow(
                rank: 1,
                team: detail.homeTeam,
                points: 43,
                goalDifference: 24,
                highlight: true,
                badge: 'W',
              ),
              const SizedBox(height: 10),
              _StandingsRow(
                rank: 2,
                team: detail.awayTeam,
                points: 40,
                goalDifference: 18,
                badge: 'S',
              ),
              const SizedBox(height: 10),
              _StandingsRow(
                rank: 3,
                team: 'Rival FC',
                points: 37,
                goalDifference: 12,
                badge: 'P',
              ),
              const SizedBox(height: 10),
              _StandingsRow(
                rank: 4,
                team: 'Challenger United',
                points: 36,
                goalDifference: 10,
                badge: 'R',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StandingsRow extends StatelessWidget {
  const _StandingsRow({
    required this.rank,
    required this.team,
    required this.points,
    required this.goalDifference,
    this.highlight = false,
    this.badge,
  });

  final int rank;
  final String team;
  final int points;
  final int goalDifference;
  final bool highlight;
  final String? badge;

  Color get _rowColor {
    if (highlight) return const Color(0xFF111B30);
    return const Color(0xFF0A1120);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _rowColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '$rank',
              style: TextStyle(
                color: highlight ? Colors.white : Colors.white70,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                if (badge != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: badge == 'W'
                          ? const Color(0xFF059669)
                          : badge == 'R'
                              ? const Color(0xFFDC2626)
                              : const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badge!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Text(
                    team,
                    style: TextStyle(
                      color: highlight ? Colors.white : Colors.white70,
                      fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 38,
            child: Text(
              '$goalDifference',
              style: TextStyle(
                color: highlight ? Colors.white : Colors.white54,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 14),
          SizedBox(
            width: 38,
            child: Text(
              '$points',
              style: TextStyle(
                color: highlight ? Colors.white : Colors.white70,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
