import '../../core/enums/country.dart';
import '../../core/enums/currency.dart';

class UserSettings {
  const UserSettings({
    required this.country,
    required this.currency,
  });

  static const defaults = UserSettings(
    country: Country.india,
    currency: Currency.inr,
  );

  final Country country;
  final Currency currency;

  UserSettings copyWith({
    Country? country,
    Currency? currency,
  }) {
    return UserSettings(
      country: country ?? this.country,
      currency: currency ?? this.currency,
    );
  }
}
