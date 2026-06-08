import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fover/core/network/api_result.dart';
import 'package:fover/core/network/dio_client.dart';
import 'package:fover/features/leagues/data/league_repository_impl.dart';
import 'package:fover/features/leagues/domain/league_repository.dart';
import 'package:fover/features/leagues/domain/models/league_section_model.dart';
import 'package:fover/features/leagues/providers/leagues_state.dart';

final leagueRepositoryProvider = Provider<LeagueRepository>((ref) {
  return LeagueRepositoryImpl(dioClient: DioClient(dio: ref.watch(dioProvider)));
});

final leaguesProvider = StateNotifierProvider<LeaguesNotifier, LeaguesState>((ref) {
  final repository = ref.watch(leagueRepositoryProvider);
  return LeaguesNotifier(repository);
});

class LeaguesNotifier extends StateNotifier<LeaguesState> {
  LeaguesNotifier(this._repository) : super(LeaguesState(status: LeaguesStatus.initial));

  final LeagueRepository _repository;

  Future<void> loadGroupedLeagues() async {
    state = state.copyWith(status: LeaguesStatus.loading, errorMessage: null);

    final result = await _repository.fetchGroupedLeagues();
    _handleResult(result);
  }

  Future<void> retry() async {
    await loadGroupedLeagues();
  }

  void toggleSectionExpanded(String sectionId) {
    if (_isFeaturedSection(sectionId)) {
      state = state.copyWith(
        expandedSectionIds: {...state.expandedSectionIds, sectionId},
      );
      return;
    }

    final next = Set<String>.from(state.expandedSectionIds);
    if (next.contains(sectionId)) {
      next.remove(sectionId);
    } else {
      next.add(sectionId);
    }

    state = state.copyWith(expandedSectionIds: next);
  }

  void _handleResult(ApiResult<List<LeagueSectionModel>> result) {
    if (result.isSuccess) {
      final sections = result.data ?? const [];
      final featuredSectionIds = sections
          .where((section) => _isFeaturedSection(_sectionId(section)))
          .map(_sectionId)
          .toSet();

      state = state.copyWith(
        status: sections.isEmpty ? LeaguesStatus.empty : LeaguesStatus.loaded,
        sections: sections,
        errorMessage: null,
        expandedSectionIds: featuredSectionIds,
      );
      return;
    }

    state = state.copyWith(
      status: LeaguesStatus.error,
      errorMessage: result.error,
    );
  }

  bool _isFeaturedSection(String sectionId) {
    return sectionId.toLowerCase().contains('featured');
  }

  String _sectionId(LeagueSectionModel section) {
    final title = section.title.trim().toLowerCase();
    final country = (section.country ?? '').trim().toLowerCase();
    return country.isEmpty ? title : '$title::$country';
  }
}
