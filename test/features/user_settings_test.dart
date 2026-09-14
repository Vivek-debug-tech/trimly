import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:trimly/core/enums/country.dart';
import 'package:trimly/core/enums/currency.dart';
import 'package:trimly/core/utils/currency_formatter.dart';
import 'package:trimly/data/repositories/user_settings_repository.dart';
import 'package:trimly/domain/models/user_settings.dart';
import 'package:trimly/services/user_settings/user_settings_provider.dart';

void main() {
  group('UserSettings', () {
    test('can be created with one user-level currency', () {
      const settings = UserSettings(
        country: Country.unitedStates,
        currency: Currency.usd,
      );

      expect(settings.country, Country.unitedStates);
      expect(settings.currency, Currency.usd);
    });

    test('country defaults map deterministically', () {
      expect(Country.india.defaultCurrency, Currency.inr);
      expect(Country.unitedStates.defaultCurrency, Currency.usd);
      expect(Country.unitedKingdom.defaultCurrency, Currency.gbp);
      expect(Country.europeanUnion.defaultCurrency, Currency.eur);
      expect(Country.japan.defaultCurrency, Currency.jpy);
      expect(Country.canada.defaultCurrency, Currency.cad);
      expect(Country.australia.defaultCurrency, Currency.aud);
      expect(Country.singapore.defaultCurrency, Currency.sgd);
    });

    test('defaults are deterministic when settings are missing', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final settings = UserSettingsRepository(preferences).load();

      expect(settings.country, Country.india);
      expect(settings.currency, Currency.inr);
    });

    test('country and currency persist and load after repository recreation',
        () async {
      SharedPreferences.setMockInitialValues({});
      final firstPreferences = await SharedPreferences.getInstance();
      final firstRepository = UserSettingsRepository(firstPreferences);
      const saved = UserSettings(
        country: Country.japan,
        currency: Currency.jpy,
      );

      await firstRepository.save(saved);

      final secondPreferences = await SharedPreferences.getInstance();
      final loaded = UserSettingsRepository(secondPreferences).load();

      expect(loaded.country, Country.japan);
      expect(loaded.currency, Currency.jpy);
    });

    test('explicit currency remains a single user-level setting', () {
      const settings = UserSettings(
        country: Country.india,
        currency: Currency.usd,
      );

      expect(settings.currency, Currency.usd);
      expect(settings.country, Country.india);
    });
  });

  group('CurrencyFormatter', () {
    test('formats INR with locale-aware output', () {
      expect(CurrencyFormatter.format(1000, Currency.inr), contains('1,000'));
      expect(CurrencyFormatter.format(1000, Currency.inr), contains('₹'));
    });

    test('formats USD with locale-aware output', () {
      expect(CurrencyFormatter.format(1000, Currency.usd), contains(r'$'));
      expect(CurrencyFormatter.format(1000, Currency.usd), contains('1,000'));
    });

    test('formats GBP with locale-aware output', () {
      expect(CurrencyFormatter.format(1000, Currency.gbp), contains('£'));
    });

    test('formats EUR with locale-aware output', () {
      final formatted = CurrencyFormatter.format(1000, Currency.eur);

      expect(formatted, contains('1.000'));
      expect(formatted, contains('€'));
    });

    test('formats JPY without fractional digits', () {
      final formatted = CurrencyFormatter.format(1000, Currency.jpy);

      expect(formatted, contains('1,000'));
      expect(formatted, contains('¥'));
      expect(formatted, isNot(contains('.00')));
    });

    test('formatting does not convert the numeric amount', () {
      expect(CurrencyFormatter.format(100, Currency.usd), contains('100'));
      expect(CurrencyFormatter.format(100, Currency.inr), contains('100'));
    });
  });

  test('Riverpod exposes the authoritative UserSettings state', () async {
    SharedPreferences.setMockInitialValues({
      UserSettingsRepository.countryKey: Country.singapore.name,
      UserSettingsRepository.currencyKey: Currency.sgd.name,
    });
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final settings = await container.read(userSettingsProvider.future);

    expect(settings.country, Country.singapore);
    expect(settings.currency, Currency.sgd);
  });
}
