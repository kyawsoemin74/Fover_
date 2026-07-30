import 'package:flutter/material.dart';

class MatchStatusFormatter {
  const MatchStatusFormatter._();

  static const Set<String> _finishedStatuses = {
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
  };

  static const Map<String, String> _statusLabels = {
    'AET': 'AET',
    'FT_PEN': 'PEN',
    'CANC': 'Cancelled',
    'PST': 'Postponed',
    'ABD': 'Abandoned',
    'SUSP': 'Suspended',
    'INT': 'Interrupted',
  };

  static bool isFinished(String status) {
    return _finishedStatuses.contains(status.toUpperCase().trim());
  }

  static Color getStatusColor(String status, {required BuildContext context}) {
    final normalizedStatus = status.toUpperCase().trim();

    if (normalizedStatus == '1H' ||
        normalizedStatus == 'HT' ||
        normalizedStatus == '2H' ||
        normalizedStatus == 'ET' ||
        normalizedStatus == 'PEN') {
      return const Color(0xFF00C853);
    }

    if (normalizedStatus == 'PST' || normalizedStatus == 'INT' || normalizedStatus == 'SUSP') {
      return const Color(0xFFFF9800);
    }

    if (normalizedStatus == 'CANC' || normalizedStatus == 'ABD') {
      return const Color(0xFF9CA3AF);
    }

    if (normalizedStatus == 'NS' ||
        normalizedStatus == 'UPCOMING' ||
        normalizedStatus == 'SCHEDULED' ||
        normalizedStatus == 'FT' ||
        normalizedStatus == 'AET' ||
        normalizedStatus == 'FT_PEN' ||
        normalizedStatus == 'WO') {
      return Theme.of(context).colorScheme.onSurfaceVariant;
    }

    if (isLive(normalizedStatus)) {
      return const Color(0xFF00C853);
    }

    return Theme.of(context).colorScheme.onSurfaceVariant;
  }

  static bool isLive(String status) {
    final normalizedStatus = status.toUpperCase().trim();

    if (normalizedStatus.isEmpty || isFinished(normalizedStatus)) {
      return false;
    }

    return normalizedStatus.startsWith('1H') ||
        normalizedStatus.startsWith('HT') ||
        normalizedStatus.startsWith('2H') ||
        normalizedStatus.startsWith('ET') ||
        normalizedStatus.startsWith('BT') ||
        normalizedStatus == 'P';
  }

  static bool shouldShowElapsed(String status) {
    final normalizedStatus = status.toUpperCase().trim();
    return normalizedStatus == '1H' || normalizedStatus == '2H';
  }

  static String display(String status, {int elapsed = 0}) {
    final normalizedStatus = status.toUpperCase().trim();

    if (isFinished(normalizedStatus)) {
      return _statusLabels[normalizedStatus] ?? normalizedStatus;
    }

    if (normalizedStatus == 'NS' || normalizedStatus == 'UPCOMING' || normalizedStatus == 'SCHEDULED') {
      return '';
    }

    if (normalizedStatus == 'HT' || normalizedStatus == 'ET' || normalizedStatus == 'AET' || normalizedStatus == 'PEN' || normalizedStatus == 'FT') {
      return normalizedStatus;
    }

    if (shouldShowElapsed(normalizedStatus)) {
      return elapsed > 0 ? '$elapsed\'' : normalizedStatus;
    }

    if (isLive(normalizedStatus)) {
      return normalizedStatus;
    }

    return '';
  }
}
