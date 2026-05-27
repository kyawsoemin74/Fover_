import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

enum FoverDateTab { yesterday, today, tomorrow }

extension FoverDateTabX on FoverDateTab {
  String get title {
    switch (this) {
      case FoverDateTab.yesterday:
        return 'Yesterday';
      case FoverDateTab.today:
        return 'Today';
      case FoverDateTab.tomorrow:
        return 'Tomorrow';
    }
  }

  DateTime dateFor(DateTime now) {
    switch (this) {
      case FoverDateTab.yesterday:
        return now.subtract(const Duration(days: 1));
      case FoverDateTab.today:
        return now;
      case FoverDateTab.tomorrow:
        return now.add(const Duration(days: 1));
    }
  }

  String label(DateTime now) {
    final date = dateFor(now);
    return DateFormat('EEE, MMM d').format(date);
  }
}

final selectedDateTabProvider = StateProvider<FoverDateTab>(
  (ref) => FoverDateTab.today,
);

final showFollowingProvider = StateProvider<bool>(
  (ref) => true,
);

final expandedLeagueIdsProvider = StateProvider<Set<String>>(
  (ref) => <String>{'premier-league'},
);
