import 'package:intl/intl.dart';

import '../enums/currency.dart';

class CurrencyFormatter {
  const CurrencyFormatter._();

  static String format(double amount, Currency currency) {
    final formatter = NumberFormat.currency(
      locale: currency.locale,
      name: currency.code,
      symbol: currency.symbol,
      decimalDigits: currency.decimalDigits,
    );
    return formatter.format(amount);
  }
}
