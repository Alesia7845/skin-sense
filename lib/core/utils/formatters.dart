import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static String rupiah(num value) =>
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
          .format(value);

  static String dateTime(DateTime value) =>
      DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(value);

  static String percent(double fraction) => '${(fraction * 100).round()}%';
}
