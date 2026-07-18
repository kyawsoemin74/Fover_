import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fover/features/team/models/team_finished_match.dart';
import 'package:fover/features/team/models/team_model.dart';
import 'package:fover/features/team/providers/team_finished_matches_provider.dart';
import 'package:fover/features/team/providers/team_finished_matches_state.dart';

class TeamFactsTab extends ConsumerStatefulWidget {
  const TeamFactsTab({super.key, required this.team});

  final TeamModel team;

  @override
  ConsumerState<TeamFactsTab> createState() => _TeamFactsTabState();
}

class _TeamFactsTabState extends ConsumerState<TeamFactsTab> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      ref.read(teamFinishedMatchesProvider(widget.team.teamId).notifier).load();
    });
  }

  String _displayText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '-';
    }
    return value;
  }

  String _displayFounded(int? founded) {
    return founded?.toString() ?? '-';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teamFinishedMatchesProvider(widget.team.teamId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FinishedMatchesCard(
          state: state,
          teamId: widget.team.teamId,
          onRetry: () => ref.read(teamFinishedMatchesProvider(widget.team.teamId).notifier).retry(),
        ),
        const SizedBox(height: 16),
        _TeamFactsCard(
          country: _displayText(widget.team.country),
          founded: _displayFounded(widget.team.founded),
          stadium: _displayText(widget.team.stadium),
        ),
      ],
    );
  }
}

class _FinishedMatchesCard extends StatelessWidget {
  const _FinishedMatchesCard({
    required this.state,
    required this.teamId,
    required this.onRetry,
  });

  final TeamFinishedMatchesState state;
  final int teamId;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final renderedMatches = state.matches;
    final title = renderedMatches.isNotEmpty ? 'Last ${renderedMatches.length} Matches' : 'Recent Matches';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF090B13),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          _buildBody(context),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final renderedMatches = state.matches;

    switch (state.status) {
      case TeamFinishedMatchesStatus.loading:
      case TeamFinishedMatchesStatus.initial:
        return SizedBox(
          height: 88,
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
          ),
        );
      case TeamFinishedMatchesStatus.error:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Unable to load recent matches',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (state.errorMessage != null && state.errorMessage!.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                state.errorMessage!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white60,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white24),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: const Text('Retry'),
            ),
          ],
        );
      case TeamFinishedMatchesStatus.empty:
        return Text(
          'No recent matches found.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white60,
            fontWeight: FontWeight.w500,
          ),
        );
      case TeamFinishedMatchesStatus.loaded:
      case TeamFinishedMatchesStatus.refreshing:
        if (renderedMatches.isEmpty) {
          return Text(
            'No recent matches found.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white60,
              fontWeight: FontWeight.w500,
            ),
          );
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: renderedMatches.map((match) {
            final resultLabel = _resultForTeam(match, teamId);
            final color = _resultColor(resultLabel);
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  children: [
                    ClipOval(
                      child: Container(
                        width: 42,
                        height: 42,
                        color: const Color(0xFF0E1220),
                        child: _opponentLogo(match, teamId) != null
                            ? CachedNetworkImage(
                                imageUrl: _opponentLogo(match, teamId)!.trim(),
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white24),
                                ),
                                errorWidget: (context, url, error) => const Icon(
                                  Icons.shield_outlined,
                                  color: Colors.white70,
                                  size: 22,
                                ),
                              )
                            : const Icon(
                                Icons.shield_outlined,
                                color: Colors.white70,
                                size: 22,
                              ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _scoreLabel(match),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      resultLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
    }
  }

  String _scoreLabel(TeamFinishedMatch match) {
    final home = match.homeScore?.toString() ?? '-';
    final away = match.awayScore?.toString() ?? '-';
    return '$home–$away';
  }

  String _resultForTeam(TeamFinishedMatch match, int currentTeamId) {
    if (match.homeTeamId == currentTeamId) {
      if ((match.homeScore ?? 0) > (match.awayScore ?? 0)) return 'Win';
      if ((match.homeScore ?? 0) < (match.awayScore ?? 0)) return 'Loss';
      return 'Draw';
    }
    if (match.awayTeamId == currentTeamId) {
      if ((match.awayScore ?? 0) > (match.homeScore ?? 0)) return 'Win';
      if ((match.awayScore ?? 0) < (match.homeScore ?? 0)) return 'Loss';
      return 'Draw';
    }
    return '–';
  }

  String? _opponentLogo(TeamFinishedMatch match, int currentTeamId) {
    if (match.homeTeamId == currentTeamId) {
      return match.awayTeamLogo?.trim().isNotEmpty == true ? match.awayTeamLogo : null;
    }
    if (match.awayTeamId == currentTeamId) {
      return match.homeTeamLogo?.trim().isNotEmpty == true ? match.homeTeamLogo : null;
    }
    return null;
  }

  Color _resultColor(String resultLabel) {
    switch (resultLabel) {
      case 'Win':
        return const Color(0xFF32D583);
      case 'Draw':
        return Colors.white60;
      case 'Loss':
        return const Color(0xFFFF5D5D);
      default:
        return Colors.white60;
    }
  }
}

class _TeamFactsCard extends StatelessWidget {
  const _TeamFactsCard({
    required this.country,
    required this.founded,
    required this.stadium,
  });

  final String country;
  final String founded;
  final String stadium;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1220),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(label: 'Country', value: country),
          const SizedBox(height: 12),
          _InfoRow(label: 'Founded', value: founded),
          const SizedBox(height: 12),
          _InfoRow(label: 'Stadium', value: stadium),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 78,
          child: Text(
            '$label:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
