import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fover/features/ads/widgets/ad_slot.dart';
import 'package:fover/core/utils/country_flag_helper.dart';
import 'package:fover/features/leagues/domain/models/league_section_model.dart';
import 'package:fover/features/leagues/providers/leagues_provider.dart';
import 'package:fover/features/leagues/providers/leagues_state.dart';
import 'package:fover/shared/widgets/custom_appbar.dart';
import 'package:fover/shared/widgets/empty_state.dart';
import 'package:fover/shared/widgets/home_loading_skeleton.dart';

class LeaguesPage extends ConsumerStatefulWidget {
  const LeaguesPage({super.key});

  @override
  ConsumerState<LeaguesPage> createState() => _LeaguesPageState();
}

class _LeaguesPageState extends ConsumerState<LeaguesPage> {
  bool _featuredExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(leaguesProvider.notifier).loadGroupedLeagues();
    });
  }

  @override
  Widget build(BuildContext context) {
    final leaguesState = ref.watch(leaguesProvider);
    final leaguesNotifier = ref.read(leaguesProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomAppBar(title: 'Leagues'),
          const SizedBox(height: 14),
          Text(
            'Browse competitions and grouped league sections.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          const BannerAdSlot(placement: BannerPlacement.leagueDetail),
          const SizedBox(height: 12),
          Expanded(child: _buildBody(context, leaguesState, leaguesNotifier)),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    LeaguesState state,
    LeaguesNotifier notifier,
  ) {
    if (state.status == LeaguesStatus.loading ||
        state.status == LeaguesStatus.initial) {
      return const HomeLoadingSkeleton();
    }

    if (state.status == LeaguesStatus.error) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: EmptyState(
          title: 'Unable to load leagues',
          message:
              state.errorMessage ??
              'Please check your connection and try again.',
          actionLabel: 'Retry',
          onAction: notifier.retry,
        ),
      );
    }

    if (state.status == LeaguesStatus.empty || !state.hasData) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: EmptyState(
          title: 'No leagues found',
          message: 'There are currently no grouped leagues to display.',
          actionLabel: 'Refresh',
          onAction: notifier.retry,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: notifier.loadGroupedLeagues,
      color: Theme.of(context).colorScheme.primary,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 32),
        itemCount: state.sections.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final section = state.sections[index];
          return Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => _handleSectionTap(section, notifier),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (section.country != null &&
                              section.country!.isNotEmpty) ...[
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CountryFlagHelper.buildCountryFlagFromCode(
                                section.countryCode,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                section.country!,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w800),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ] else
                            Expanded(
                              child: Text(
                                section.title.isNotEmpty
                                    ? section.title
                                    : 'Leagues',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w800),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          if (section.type != 'featured')
                            Icon(
                              state.expandedSectionIds.contains(
                                    _sectionId(section),
                                  )
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            )
                          else
                            Icon(
                              _featuredExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (section.type == 'featured' || state.expandedSectionIds.contains(
                    _sectionId(section),
                  )) ...[
                    const SizedBox(height: 4),
                    ..._visibleLeagues(section).map(
                      (league) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              padding: const EdgeInsets.all(6),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  width: 1,
                                ),
                              ),
                              child: CachedNetworkImage(
                                imageUrl: league.logo,
                                fit: BoxFit.contain,
                                placeholder: (_, _) => const Center(
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                                errorWidget: (_, _, _) => Icon(
                                  Icons.emoji_events_rounded,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    league.name,
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    league.country.isNotEmpty
                                        ? league.country
                                        : 'Unknown country',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            if (section.type != 'featured')
                              Text(
                                league.season.isNotEmpty ? league.season : 'N/A',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (section.type == 'featured' &&
                        section.leagues.length > 6)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => setState(() {
                            _featuredExpanded = !_featuredExpanded;
                          }),
                          child: Text(
                            _featuredExpanded ? 'Show Less' : 'Show More',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleSectionTap(
    LeagueSectionModel section,
    LeaguesNotifier notifier,
  ) {
    if (section.type == 'featured') {
      setState(() {
        _featuredExpanded = !_featuredExpanded;
      });
      return;
    }

    notifier.toggleSectionExpanded(_sectionId(section));
  }

  List<dynamic> _visibleLeagues(LeagueSectionModel section) {
    if (section.type != 'featured') {
      return section.leagues;
    }

    final sortedLeagues = [...section.leagues]
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    return _featuredExpanded ? sortedLeagues : sortedLeagues.take(6).toList();
  }

  String _sectionId(LeagueSectionModel section) {
    final title = section.title.trim().toLowerCase();
    final country = (section.country ?? '').trim().toLowerCase();
    return country.isEmpty ? title : '$title::$country';
  }
}
