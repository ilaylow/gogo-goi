import 'package:intl/intl.dart';

String formatPrettyDate(DateTime date) {
  final localDate = date.toLocal();

  // Get day with ordinal suffix
  String getDayWithSuffix(int day) {
    if (day >= 11 && day <= 13) return '${day}th';
    switch (day % 10) {
      case 1: return '${day}st';
      case 2: return '${day}nd';
      case 3: return '${day}rd';
      default: return '${day}th';
    }
  }

  final day = getDayWithSuffix(localDate.day);
  final month = DateFormat.MMMM().format(localDate);
  final year = localDate.year;
  final time = DateFormat('h:mma').format(localDate);

  return '$day $month $year, $time';
}