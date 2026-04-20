import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Date formatting helpers for absolute and relative timestamps.
final class DateFormatter {
  DateFormatter._();

  /// Formats a date into a compact relative string.
  static String relative(DateTime dateTime) {
    return timeago.format(dateTime);
  }

  /// Formats a date into a readable absolute string.
  static String absolute(
    DateTime dateTime, {
    String pattern = 'MMM d, y • h:mm a',
  }) {
    return DateFormat(pattern).format(dateTime);
  }
}
