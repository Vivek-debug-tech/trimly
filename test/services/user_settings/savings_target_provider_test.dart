import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trimly/services/user_settings/savings_target_provider.dart';

void main() {
  group('SavingsTargetController Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('exposes default 2500.0 target initially', () async {
      final container = ProviderContainer();
      final target = await container.read(savingsTargetProvider.future);
      expect(target, 2500.0);
    });

    test('persistence/reload updates state', () async {
      SharedPreferences.setMockInitialValues({'savings_target': 3000.0});
      final container = ProviderContainer();
      final target = await container.read(savingsTargetProvider.future);
      expect(target, 3000.0);
    });

    test('setTarget updates target and persists safely', () async {
      final container = ProviderContainer();
      final controller = container.read(savingsTargetProvider.notifier);
      await controller.setTarget(4000.0);
      final value = await container.read(savingsTargetProvider.future);
      expect(value, 4000.0);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getDouble('savings_target'), 4000.0);
    });

    test('invalid target input (zero/negative/NaN) does not corrupt state', () async {
      final container = ProviderContainer();
      final controller = container.read(savingsTargetProvider.notifier);
      await controller.setTarget(1000.0);

      await controller.setTarget(-50.0);
      expect(await container.read(savingsTargetProvider.future), 1000.0);

      await controller.setTarget(0);
      expect(await container.read(savingsTargetProvider.future), 1000.0);

      await controller.setTarget(double.nan);
      expect(await container.read(savingsTargetProvider.future), 1000.0);
    });
  });
}
