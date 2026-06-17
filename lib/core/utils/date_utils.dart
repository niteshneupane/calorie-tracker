import 'package:intl/intl.dart';

class AppDateUtils {
  static final _apiDate = DateFormat('yyyy-MM-dd');
  static final _displayDate = DateFormat('EEE, MMM d');

  static String apiDate(DateTime date) => _apiDate.format(date);

  static String displayDate(DateTime date) => _displayDate.format(date);
}
