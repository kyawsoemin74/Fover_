import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Manages the currently selected date in the horizontal picker.
final selectedDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

/// Generates a list of dates relative to today (7 days prior to 7 days after).
final dateRangeProvider = Provider<List<DateTime>>((ref) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  
  return List.generate(15, (index) {
    return today.add(Duration(days: index - 7));
  });
});