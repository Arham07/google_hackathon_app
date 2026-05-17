import 'package:intl/intl.dart';

/// Relative incident timestamps for listing cards.
abstract final class IncidentTimeFormat {
  static String relativeAge(DateTime scan, DateTime now) {
    if (scan.isAfter(now)) {
      return DateFormat('dd MMM yyyy, HH:mm').format(scan);
    }
    final Duration diff = now.difference(scan);
    if (diff < const Duration(minutes: 1)) {
      return 'Just now';
    }
    if (diff < const Duration(hours: 1)) {
      final int m = diff.inMinutes;
      return m <= 1 ? '1 min ago' : '$m min ago';
    }
    if (diff < const Duration(hours: 24)) {
      final int h = diff.inHours;
      return h == 1 ? '1 hour ago' : '$h hours ago';
    }
    if (diff < const Duration(days: 7)) {
      final int d = diff.inDays;
      return '${d}d ago';
    }
    return DateFormat('dd MMM yyyy, HH:mm').format(scan);
  }

  static bool isWithinLast24Hours(DateTime scan, DateTime now) {
    if (scan.isAfter(now)) {
      return false;
    }
    return now.difference(scan) <= const Duration(hours: 24);
  }
}
