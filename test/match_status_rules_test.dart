import 'package:flutter_test/flutter_test.dart';
import 'package:fover/features/home/domain/models/match_model.dart';

void main() {
  group('MatchInfo status rules', () {
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
        expect(MatchInfo.isLiveStatus(status), isFalse, reason: '$status should not be live');
        expect(MatchInfo.isFinishedStatus(status), isTrue, reason: '$status should be finished');
      }
    });

    test('counts only live minute statuses as live', () {
      const liveStatuses = <String>['1H', 'HT', '2H', 'ET', 'BT', 'P'];

      for (final status in liveStatuses) {
        expect(MatchInfo.isLiveStatus(status), isTrue, reason: '$status should be live');
      }
    });

    test('formats finished labels and live elapsed minutes correctly', () {
      expect(MatchInfo.displayStatus('PEN', elapsed: 120), 'PEN');
      expect(MatchInfo.displayStatus('FT', elapsed: 120), 'FT');
      expect(MatchInfo.displayStatus('AET', elapsed: 120), 'FT');
      expect(MatchInfo.displayStatus('FT_PEN', elapsed: 120), 'PEN');
      expect(MatchInfo.displayStatus('CANC', elapsed: 0), 'Cancelled');
      expect(MatchInfo.displayStatus('PST', elapsed: 0), 'Postponed');
      expect(MatchInfo.displayStatus('ABD', elapsed: 70), 'Abandoned');
      expect(MatchInfo.displayStatus('SUSP', elapsed: 45), 'Suspended');
      expect(MatchInfo.displayStatus('INT', elapsed: 30), 'Interrupted');
      expect(MatchInfo.displayStatus('HT', elapsed: 0), 'HT');
      expect(MatchInfo.displayStatus('HT', elapsed: 45), '45\'');
    });
  });
}
