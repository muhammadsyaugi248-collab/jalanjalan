import 'package:intl/intl.dart';

class DateUtil {
  static String getTodayDate() {
    final now = DateTime.now();
    return DateFormat('EEEE, dd MMMM yyyy').format(now);
  }

  static String getCurrentTime() {
    final now = DateTime.now();
    return DateFormat('HH:mm').format(now);
  }
}
