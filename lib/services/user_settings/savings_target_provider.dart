import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final savingsTargetProvider = AsyncNotifierProvider<SavingsTargetController, double>(
  SavingsTargetController.new,
);

class SavingsTargetController extends AsyncNotifier<double> {
  static const _key = 'savings_target';
  static const _defaultTarget = 2500.0;

  @override
  Future<double> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_key) ?? _defaultTarget;
  }

  Future<void> setTarget(double value) async {
    if (value <= 0 || value.isNaN) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_key, value);
      return value;
    });
  }
}
