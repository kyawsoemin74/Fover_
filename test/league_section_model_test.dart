import 'package:flutter_test/flutter_test.dart';
import 'package:fover/features/leagues/domain/models/league_section_model.dart';

void main() {
  test('derives section country_code from the first league when section metadata is missing', () {
    final section = LeagueSectionModel.fromJson({
      'type': 'country',
      'title': 'Argentina',
      'country': 'Argentina',
      'leagues': [
        {
          'league_id': 1,
          'name': 'Primera Division',
          'country': 'Argentina',
          'country_code': 'AR',
          'logo': 'https://example.com/logo.png',
          'season': '2024',
          'is_featured': false,
          'display_order': 1,
        },
      ],
    });

    expect(section.countryCode, 'AR');
    expect(section.country, 'Argentina');
    expect(section.leagues.first.countryCode, 'AR');
  });
}
