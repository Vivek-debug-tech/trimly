import 'currency.dart';

enum Country {
  india(
    code: 'IN',
    displayName: 'India',
    defaultCurrency: Currency.inr,
  ),
  unitedStates(
    code: 'US',
    displayName: 'United States',
    defaultCurrency: Currency.usd,
  ),
  unitedKingdom(
    code: 'GB',
    displayName: 'United Kingdom',
    defaultCurrency: Currency.gbp,
  ),
  europeanUnion(
    code: 'EU',
    displayName: 'European Union',
    defaultCurrency: Currency.eur,
  ),
  japan(
    code: 'JP',
    displayName: 'Japan',
    defaultCurrency: Currency.jpy,
  ),
  canada(
    code: 'CA',
    displayName: 'Canada',
    defaultCurrency: Currency.cad,
  ),
  australia(
    code: 'AU',
    displayName: 'Australia',
    defaultCurrency: Currency.aud,
  ),
  singapore(
    code: 'SG',
    displayName: 'Singapore',
    defaultCurrency: Currency.sgd,
  );

  const Country({
    required this.code,
    required this.displayName,
    required this.defaultCurrency,
  });

  final String code;
  final String displayName;
  final Currency defaultCurrency;
}
