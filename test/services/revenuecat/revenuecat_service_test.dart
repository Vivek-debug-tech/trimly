import 'package:flutter_test/flutter_test.dart';

import 'package:trimly/services/revenuecat/entitlement_state.dart';
import 'package:trimly/services/revenuecat/revenuecat_service.dart';

void main() {
  group('EntitlementMapper', () {
    test('no pro entitlement produces free state', () {
      final state = EntitlementMapper.fromProEntitlementActive(false);

      expect(state.status, EntitlementStatus.free);
      expect(state.isPro, isFalse);
    });

    test('active pro entitlement produces pro state', () {
      final state = EntitlementMapper.fromProEntitlementActive(true);

      expect(state.status, EntitlementStatus.pro);
      expect(state.isPro, isTrue);
    });

    test('inactive pro entitlement produces free state', () {
      final state = EntitlementMapper.fromProEntitlementActive(false);

      expect(state.status, EntitlementStatus.free);
      expect(state.isPro, isFalse);
    });

    test('other active entitlements do not grant pro', () {
      final state = EntitlementMapper.fromProEntitlementActive(false);

      expect(state.status, EntitlementStatus.free);
      expect(state.isPro, isFalse);
    });

    test(
      'empty entitlement collection maps to free through the pure boundary',
      () {
        final state = EntitlementMapper.fromProEntitlementActive(false);

        expect(state.status, EntitlementStatus.free);
      },
    );

    test('mapping is deterministic for repeated updates', () {
      final states = [
        true,
        false,
        true,
      ].map(EntitlementMapper.fromProEntitlementActive).toList();

      expect(states.map((state) => state.status), [
        EntitlementStatus.pro,
        EntitlementStatus.free,
        EntitlementStatus.pro,
      ]);
    });
  });

  group('EntitlementState', () {
    test('starts in loading state', () {
      const state = EntitlementState.loading();

      expect(state.status, EntitlementStatus.loading);
      expect(state.isPro, isFalse);
      expect(state.errorMessage, isNull);
    });

    test('represents an initialization error without granting pro', () {
      const state = EntitlementState.error('RevenueCat unavailable.');

      expect(state.status, EntitlementStatus.error);
      expect(state.errorMessage, 'RevenueCat unavailable.');
      expect(state.isPro, isFalse);
    });
  });

  test('missing configuration produces a safe error state', () async {
    final service = RevenueCatService(apiKey: '');

    final state = await service.initialize();
    service.dispose();

    expect(state.status, EntitlementStatus.error);
    expect(state.isPro, isFalse);
    expect(state.errorMessage, contains('not configured'));
  });
}
