import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fover/core/network/dio_client.dart';
import 'package:fover/features/standings/data/standing_repository_impl.dart';
import 'package:fover/features/standings/domain/models/standing_model.dart';
import 'package:fover/features/standings/domain/standing_repository.dart';

class StandingRequest {
  const StandingRequest({
    required this.leagueId,
    required this.season,
  });

  final int leagueId;
  final String season;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StandingRequest &&
          runtimeType == other.runtimeType &&
          leagueId == other.leagueId &&
          season == other.season;

  @override
  int get hashCode => Object.hash(leagueId, season);
}

final standingRepositoryProvider = Provider<StandingRepository>((ref) {
  return StandingRepositoryImpl(dioClient: DioClient(dio: ref.watch(dioProvider)));
});

final standingsProvider = FutureProvider.family<List<StandingInfo>, StandingRequest>(
  (ref, request) async {
    final repository = ref.watch(standingRepositoryProvider);
    final result = await repository.fetchStandings(request.leagueId, request.season);

    if (!result.isSuccess) {
      throw Exception(result.error ?? 'Unable to load standings');
    }

    return result.data ?? const [];
  },
);
