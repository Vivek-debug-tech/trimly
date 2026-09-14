enum Currency {
  inr(
    code: 'INR',
    locale: 'en_IN',
    symbol: '\u20b9',
    decimalDigits: 2,
  ),
  usd(
    code: 'USD',
    locale: 'en_US',
    symbol: '\$',
    decimalDigits: 2,
  ),
  gbp(
    code: 'GBP',
    locale: 'en_GB',
    symbol: '\u00a3',
    decimalDigits: 2,
  ),
  eur(
    code: 'EUR',
    locale: 'de_DE',
    symbol: '\u20ac',
    decimalDigits: 2,
  ),
  jpy(
    code: 'JPY',
    locale: 'ja_JP',
    symbol: '\u00a5',
    decimalDigits: 0,
  ),
  cad(
    code: 'CAD',
    locale: 'en_CA',
    symbol: 'CA\$',
    decimalDigits: 2,
  ),
  aud(
    code: 'AUD',
    locale: 'en_AU',
    symbol: 'A\$',
    decimalDigits: 2,
  ),
  sgd(
    code: 'SGD',
    locale: 'en_SG',
    symbol: 'S\$',
    decimalDigits: 2,
  );

  const Currency({
    required this.code,
    required this.locale,
    required this.symbol,
    required this.decimalDigits,
  });

  final String code;
  final String locale;
  final String symbol;
  final int decimalDigits;
}
