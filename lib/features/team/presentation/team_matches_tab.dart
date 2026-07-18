import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fover/features/home/domain/models/match_model.dart';
import 'package:fover/features/team/providers/team_provider.dart';
import 'package:fover/features/team/providers/team_state.dart';

class TeamMatchesTab extends ConsumerStatefulWidget {
  const TeamMatchesTab({super.key, required this.teamId});

  final int teamId;

  @override
  ConsumerState<TeamMatchesTab> createState() => _TeamMatchesTabState();
}

class _TeamMatchesTabState extends ConsumerState<TeamMatchesTab> {
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _matchKeys = <GlobalKey>[];
  bool _hasScrolledToTransition = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(teamProvider(widget.teamId).notifier).loadMatches(widget.teamId));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(teamProvider(widget.teamId));
    final matches = state.matches;

    if (state.matchesStatus == TeamMatchesStatus.loading || state.matchesStatus == TeamMatchesStatus.initial) {
      return _buildLoadingState();
    }

    if (state.matchesStatus == TeamMatchesStatus.error) {
      return _buildErrorState(state.matchesErrorMessage);
    }

    if (state.matchesStatus == TeamMatchesStatus.empty || matches.isEmpty) {
      return _buildEmptyState();
    }

    while (_matchKeys.length < matches.length) {
      _matchKeys.add(GlobalKey());
    }
    while (_matchKeys.length > matches.length) {
      _matchKeys.removeLast();
    }

    final transitionIndex = _findTransitionIndex(matches);
    if (!_hasScrolledToTransition && transitionIndex >= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _hasScrolledToTransition) {
          return;
        }
        _hasScrolledToTransition = true;
        final targetKey = _matchKeys[transitionIndex];
        if (targetKey.currentContext != null) {
          Scrollable.ensureVisible(targetKey.currentContext!, alignment: 0.0);
        }
      });
    }

    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: List.generate(matches.length, (index) {
          final match = matches[index];
          return _MatchCard(
            key: _matchKeys[index],
            match: match,
            selectedTeamId: widget.teamId,
          );
        }),
      ),
    );
  }

  int _findTransitionIndex(List<MatchInfo> matches) {
    for (var index = 0; index < matches.length; index++) {
      final status = matches[index].status.toUpperCase().trim();
      if (status != 'NS') {
        if (index > 0) {
          return index - 1;
        }
        return -1;
      }
    }
    return -1;
  }

  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1220),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1220),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(
        'No matches found for this team.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.white60,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildErrorState(String? message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1220),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Unable to load matches',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          if (message != null && message.trim().isNotEmpty)
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white60,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  const _MatchCard({super.key, required this.match, required this.selectedTeamId});

  final MatchInfo match;
  final int selectedTeamId;

  @override
  Widget build(BuildContext context) {
    final status = match.status.toUpperCase().trim();
    final dateLabel = _formatDate(match.kickOffTime);
    final homeScore = _shouldShowScores(status) ? _homeScore(match) : '';
    final awayScore = _shouldShowScores(status) ? _awayScore(match) : '';
    final badge = _resultBadgeForSelectedTeam(
      selectedTeamId,
      homeScore,
      awayScore,
      status,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1220),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 64,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateLabel,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  status.isEmpty ? 'NS' : status,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white60,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TeamRow(
                  logoUrl: match.teamALogoUrl,
                  name: match.teamA,
                  alignment: CrossAxisAlignment.start,
                ),
                const SizedBox(height: 10),
                _TeamRow(
                  logoUrl: match.teamBLogoUrl,
                  name: match.teamB,
                  alignment: CrossAxisAlignment.start,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 28,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  homeScore,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  awayScore,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 42,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 24,
                  child: badge == null
                      ? const SizedBox.shrink()
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: badge['color'] as Color,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            badge['label'] as String,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 10),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String raw) {
    if (raw.trim().isEmpty) {
      return 'TBD';
    }
    try {
      final parsed = DateTime.parse(raw).toLocal();
      return '${parsed.day} ${_monthShort(parsed.month)}';
    } catch (_) {
      return raw;
    }
  }

  String _monthShort(int month) {
    const months = <String>['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  String _homeScore(MatchInfo match) {
    final scoreText = match.score.trim();
    if (scoreText.isEmpty) {
      return '-';
    }
    final parts = scoreText.split(RegExp(r'[-:xX]'));
    if (parts.isEmpty) {
      return '-';
    }
    return parts.first.trim();
  }

  String _awayScore(MatchInfo match) {
    final scoreText = match.score.trim();
    if (scoreText.isEmpty) {
      return '-';
    }
    final parts = scoreText.split(RegExp(r'[-:xX]'));
    if (parts.length < 2) {
      return '-';
    }
    return parts[1].trim();
  }

  Map<String, dynamic>? _resultBadgeForSelectedTeam(
    int selectedTeamId,
    String homeScore,
    String awayScore,
    String status,
  ) {
    if (!_isFinishedStatus(status)) {
      return null;
    }

    final homeValue = int.tryParse(homeScore) ?? 0;
    final awayValue = int.tryParse(awayScore) ?? 0;
    if (selectedTeamId <= 0) {
      return null;
    }

    final isHomeTeam = match.homeTeamId == selectedTeamId;
    final isAwayTeam = match.awayTeamId == selectedTeamId;
    if (!isHomeTeam && !isAwayTeam) {
      return null;
    }

    if (isHomeTeam) {
      if (homeValue > awayValue) return {'label': 'W', 'color': const Color(0xFF2ECC71)};
      if (homeValue < awayValue) return {'label': 'L', 'color': const Color(0xFFF43F5E)};
      return {'label': 'D', 'color': const Color(0xFF8E8E93)};
    }

    if (awayValue > homeValue) return {'label': 'W', 'color': const Color(0xFF2ECC71)};
    if (awayValue < homeValue) return {'label': 'L', 'color': const Color(0xFFF43F5E)};
    return {'label': 'D', 'color': const Color(0xFF8E8E93)};
  }

  bool _isFinishedStatus(String status) {
    final normalized = status.toUpperCase().trim();
    return normalized == 'FT' || normalized == 'AET' || normalized == 'PEN';
  }

  bool _shouldShowScores(String status) {
    final normalized = status.toUpperCase().trim();
    return normalized.isNotEmpty &&
        normalized != 'NS' &&
        normalized != 'TBD' &&
        normalized != 'PST';
  }
}

class _TeamRow extends StatelessWidget {
  const _TeamRow({required this.logoUrl, required this.name, required this.alignment});

  final String? logoUrl;
  final String name;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipOval(
          child: Container(
            width: 24,
            height: 24,
            color: const Color(0xFF050B1A),
            child: logoUrl != null && logoUrl!.trim().isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: logoUrl!.trim(),
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white24),
                    ),
                    errorWidget: (context, url, error) => const Icon(Icons.shield_outlined, color: Colors.white70, size: 16),
                  )
                : const Icon(Icons.shield_outlined, color: Colors.white70, size: 16),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
