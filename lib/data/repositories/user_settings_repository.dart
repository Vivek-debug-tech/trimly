import 'package:shared_preferences/shared_preferences.dart';

import '../../core/enums/country.dart';
import '../../core/enums/currency.dart';
import '../../domain/models/user_settings.dart';

class UserSettingsRepository {
  const UserSettingsRepository(this._preferences);

  static const countryKey = 'user_settings.country';
  static const currencyKey = 'user_settings.currency';

  final SharedPreferences _preferences;

  UserSettings load() {
    final country = _countryFromName(_preferences.getString(countryKey));
    final currency = _currencyFromName(_preferences.getString(currencyKey));

    return UserSettings(
      country: country ?? UserSettings.defaults.country,
      currency: currency ??
          (country?.defaultCurrency ?? UserSettings.defaults.currency),
    );
  }

  Future<bool> save(UserSettings settings) async {
    final countrySaved = await _preferences.setString(
      countryKey,
      settings.country.name,
    );
    final currencySaved = await _preferences.setString(
      currencyKey,
      settings.currency.name,
    );
    return countrySaved && currencySaved;
  }

  Country? _countryFromName(String? name) {
    for (final country in Country.values) {
      if (country.name == name) {
        return country;
      }
    }
    return null;
  }

  Currency? _currencyFromName(String? name) {
    for (final currency in Currency.values) {
      if (currency.name == name) {
        return currency;
      }
    }
    return null;
  }
}
