import 'package:intl/intl.dart';

class DateTimeUtils {
  DateTimeUtils._();

  static String formatDate(
    DateTime dateTime, {
    String format = 'MMM dd, yyyy',
  }) {
    return DateFormat(format).format(dateTime);
  }

  static String formatTime(DateTime dateTime, {String format = 'hh:mm a'}) {
    return DateFormat(format).format(dateTime);
  }

  static String formatDateTime(
    DateTime dateTime, {
    String format = 'MMM dd, yyyy hh:mm a',
  }) {
    return DateFormat(format).format(dateTime);
  }

  static String timeAgo(DateTime dateTime) {
    final Duration difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static DateTime startOfDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  static DateTime endOfDay(DateTime dateTime) {
    return DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      23,
      59,
      59,
      999,
    );
  }

  static DateTime startOfWeek(DateTime dateTime) {
    final int daysToSubtract = dateTime.weekday - 1;
    return startOfDay(dateTime.subtract(Duration(days: daysToSubtract)));
  }

  static DateTime endOfWeek(DateTime dateTime) {
    final int daysToAdd = 7 - dateTime.weekday;
    return endOfDay(dateTime.add(Duration(days: daysToAdd)));
  }

  static DateTime startOfMonth(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, 1);
  }

  static DateTime endOfMonth(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month + 1, 0, 23, 59, 59, 999);
  }

  static List<DateTime> getDaysInWeek(DateTime dateTime) {
    final DateTime start = startOfWeek(dateTime);
    return List.generate(7, (index) => start.add(Duration(days: index)));
  }

  static List<DateTime> getDaysInMonth(DateTime dateTime) {
    final DateTime start = startOfMonth(dateTime);
    final DateTime end = endOfMonth(dateTime);
    final int days = end.day;
    return List.generate(days, (index) => start.add(Duration(days: index)));
  }
}
