import 'package:fover/features/home/domain/models/match_model.dart';

class LeagueInfo {
  const LeagueInfo({
    required this.id,
    required this.countryCode,
    required this.leagueName,
    required this.matches,
  });

  final String id;
  final String countryCode;
  final String leagueName;
  final List<MatchInfo> matches;
}
