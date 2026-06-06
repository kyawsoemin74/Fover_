import 'package:flutter_test/flutter_test.dart';
import 'package:fover/features/standings/domain/league_standing_rules.dart';

void main() {
  group('LeagueStandingRules.resolve', () {
    test('returns Premier League qualification bands for leagueId 39', () {
      expect(LeagueStandingRules.resolve(39, 1)?.label, 'Champions League');
      expect(LeagueStandingRules.resolve(39, 4)?.label, 'Champions League');
      expect(LeagueStandingRules.resolve(39, 5)?.label, 'Europa League');
      expect(LeagueStandingRules.resolve(39, 6)?.label, 'Conference League');
      expect(LeagueStandingRules.resolve(39, 18)?.label, 'Relegation');
    });

    test('returns La Liga and Brazilian league rules for the configured IDs', () {
      expect(LeagueStandingRules.resolve(140, 1)?.label, 'Champions League');
      expect(LeagueStandingRules.resolve(78, 1)?.label, 'Champions League');
      expect(LeagueStandingRules.resolve(135, 1)?.label, 'Champions League');
      expect(LeagueStandingRules.resolve(71, 1)?.label, 'Libertadores');
      expect(LeagueStandingRules.resolve(72, 17)?.label, 'Relegation');
    });
  });
}
