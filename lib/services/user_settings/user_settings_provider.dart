import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/repositories/user_settings_repository.dart';
import '../../domain/models/user_settings.dart';

final userSettingsProvider =
    AsyncNotifierProvider<UserSettingsController, UserSettings>(
  UserSettingsController.new,
);

class UserSettingsController extends AsyncNotifier<UserSettings> {
  @override
  Future<UserSettings> build() async {
    final preferences = await SharedPreferences.getInstance();
    return UserSettingsRepository(preferences).load();
  }

  Future<void> setSettings(UserSettings settings) async {
    final preferences = await SharedPreferences.getInstance();
    final repository = UserSettingsRepository(preferences);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repository.save(settings);
      return settings;
    });
  }
}
