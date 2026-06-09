import 'package:intl/intl.dart';

class Fmt {
  const Fmt._();

  static final _currency = NumberFormat.currency(locale: 'it_IT', symbol: '€');
  static final _compact = NumberFormat.compactCurrency(
    locale: 'en_US',
    symbol: '\$',
  );

  static String money(num? v) => v == null ? '—' : _currency.format(v);

  static String compactMoney(num? v) => v == null ? '—' : _compact.format(v);

  static String pct(num? v, {int decimals = 1}) =>
      v == null ? '—' : '${v.toStringAsFixed(decimals)}%';

  /// Percentuale a partire da una frazione 0..1 (es. ROE 0.15 -> 15.0%).
  static String pctFromFraction(num? v, {int decimals = 1}) =>
      v == null ? '—' : '${(v * 100).toStringAsFixed(decimals)}%';

  static String ratio(num? v, {int decimals = 2}) =>
      v == null ? '—' : v.toStringAsFixed(decimals);

  static final _time = DateFormat.Hm('it_IT');
  static String time(DateTime d) => _time.format(d);

  static String signed(num v) => v >= 0 ? '+${money(v)}' : money(v);
  static String signedPct(num v, {int decimals = 1}) =>
      v >= 0 ? '+${v.toStringAsFixed(decimals)}%' : '${v.toStringAsFixed(decimals)}%';
}
