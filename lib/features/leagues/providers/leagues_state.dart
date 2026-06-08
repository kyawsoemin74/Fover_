import 'package:fover/features/leagues/domain/models/league_section_model.dart';

enum LeaguesStatus { initial, loading, loaded, empty, error }

class LeaguesState {
  LeaguesState({
    this.status = LeaguesStatus.initial,
    this.sections = const [],
    this.errorMessage,
    this.expandedSectionIds = const {},
  });

  final LeaguesStatus status;
  final List<LeagueSectionModel> sections;
  final String? errorMessage;
  final Set<String> expandedSectionIds;

  bool get hasData => sections.isNotEmpty;

  LeaguesState copyWith({
    LeaguesStatus? status,
    List<LeagueSectionModel>? sections,
    String? errorMessage,
    Set<String>? expandedSectionIds,
  }) {
    return LeaguesState(
      status: status ?? this.status,
      sections: sections ?? this.sections,
      errorMessage: errorMessage ?? this.errorMessage,
      expandedSectionIds: expandedSectionIds ?? this.expandedSectionIds,
    );
  }
}
