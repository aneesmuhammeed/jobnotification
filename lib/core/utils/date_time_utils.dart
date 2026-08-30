import 'package:intl/intl.dart';

/// Date and time formatting utilities.
class DateTimeUtils {
  DateTimeUtils._();

  /// Format: "30 Aug 2026"
  static String formatDate(DateTime date) {
    return DateFormat('d MMM yyyy').format(date);
  }

  /// Format: "30 Aug 2026, 7:42 PM"
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('d MMM yyyy, h:mm a').format(dateTime);
  }

  /// Format: "10 September 2026"
  static String formatDateLong(DateTime date) {
    return DateFormat('d MMMM yyyy').format(date);
  }

  /// Format: "Apply before: 10 Sep"
  static String formatDeadlineShort(DateTime date) {
    return DateFormat('d MMM').format(date);
  }

  /// Check if a date is today or in the future.
  static bool isNotExpired(DateTime lastDate) {
    final today = DateTime.now();
    final todayDateOnly = DateTime(today.year, today.month, today.day);
    final lastDateOnly = DateTime(lastDate.year, lastDate.month, lastDate.day);
    return !lastDateOnly.isBefore(todayDateOnly);
  }

  /// Check if a date is in the past.
  static bool isExpired(DateTime lastDate) {
    return !isNotExpired(lastDate);
  }

  /// Get a greeting based on the current time.
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}
