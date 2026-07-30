import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fover/features/home/domain/models/match_status_formatter.dart';

void main() {
  group('MatchStatusFormatter rules', () {
    test('treats finished statuses as non-live and non-live-counted', () {
      const finishedStatuses = <String>[
        'PEN',
        'FT',
        'AET',
        'FT_PEN',
        'CANC',
        'PST',
        'ABD',
        'SUSP',
        'INT',
        'AWD',
        'WO',
      ];

      for (final status in finishedStatuses) {
        expect(MatchStatusFormatter.isLive(status), isFalse, reason: '$status should not be live');
        expect(MatchStatusFormatter.isFinished(status), isTrue, reason: '$status should be finished');
      }
    });

    test('counts only live minute statuses as live', () {
      const liveStatuses = <String>['1H', 'HT', '2H', 'ET', 'BT', 'P'];

      for (final status in liveStatuses) {
        expect(MatchStatusFormatter.isLive(status), isTrue, reason: '$status should be live');
      }
    });

    testWidgets('classifies status colors by shared rules', (tester) async {
      late Color liveColor;
      late Color warningColor;
      late Color cancelledColor;
      late Color defaultColor;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                liveColor = MatchStatusFormatter.getStatusColor('1H', context: context);
                warningColor = MatchStatusFormatter.getStatusColor('PST', context: context);
                cancelledColor = MatchStatusFormatter.getStatusColor('CANC', context: context);
                defaultColor = MatchStatusFormatter.getStatusColor('FT', context: context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(liveColor, const Color(0xFF00C853));
      expect(warningColor, const Color(0xFFFF9800));
      expect(cancelledColor, const Color(0xFF9CA3AF));
      expect(defaultColor, isNot(equals(liveColor)));
    });

    test('formats finished labels and live elapsed minutes correctly', () {
      expect(MatchStatusFormatter.display('PEN', elapsed: 120), 'PEN');
      expect(MatchStatusFormatter.display('FT', elapsed: 120), 'FT');
      expect(MatchStatusFormatter.display('AET', elapsed: 120), 'FT');
      expect(MatchStatusFormatter.display('FT_PEN', elapsed: 120), 'PEN');
      expect(MatchStatusFormatter.display('CANC', elapsed: 0), 'Cancelled');
      expect(MatchStatusFormatter.display('PST', elapsed: 0), 'Postponed');
      expect(MatchStatusFormatter.display('ABD', elapsed: 70), 'Abandoned');
      expect(MatchStatusFormatter.display('SUSP', elapsed: 45), 'Suspended');
      expect(MatchStatusFormatter.display('INT', elapsed: 30), 'Interrupted');
      expect(MatchStatusFormatter.display('HT', elapsed: 0), 'HT');
      expect(MatchStatusFormatter.display('HT', elapsed: 45), '45\'');
    });
  });
}
