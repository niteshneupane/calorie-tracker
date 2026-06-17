import 'package:intl/intl.dart';

class AppFormatters {
  static final _compact = NumberFormat.decimalPattern();

  static String kcal(num value, {bool estimated = false}) {
    final prefix = estimated ? '~' : '';
    return '$prefix${_compact.format(value.round())} kcal';
  }

  static String grams(num value) => '${value.round()} g';
  static String mg(num value) => '${value.round()} mg';
}
