import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:trimly/data/storage/hive_adapters.dart';
import 'package:trimly/data/storage/hive_boxes.dart';
import 'package:trimly/domain/models/subscription.dart';
import 'package:trimly/core/enums/billing_cycle.dart';
import 'package:trimly/core/enums/decision_status.dart';
import 'package:trimly/services/subscriptions/subscription_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

void main() {
  group('Subscription Provider and Hive Initialization', () {
    setUp(() async {
      final dir = await Directory.systemTemp.createTemp('hive_test');
      Hive.init(dir.path);
      if (!Hive.isAdapterRegistered(10)) HiveAdapters.register();
      await Hive.openBox<Subscription>(HiveBoxes.subscriptions);
      await Hive.box<Subscription>(HiveBoxes.subscriptions).clear();
    });

    tearDown(() async {
      await Hive.deleteFromDisk();
    });

    test('Hive application initialization assumptions are valid', () {
      expect(Hive.isBoxOpen(HiveBoxes.subscriptions), isTrue);
      expect(Hive.isAdapterRegistered(10), isTrue);
    });

    test('Subscription provider exposes persisted subscriptions', () async {
      final box = Hive.box<Subscription>(HiveBoxes.subscriptions);
      final sub = Subscription(
        id: '1',
        name: 'Netflix',
        category: 'Entertainment',
        price: 15.0,
        currency: 'USD',
        billingCycle: BillingCycle.monthly,
        nextRenewalDate: DateTime.now(),
        decisionStatus: DecisionStatus.keep,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await box.put(sub.id, sub);

      final container = ProviderContainer();
      final subscriptions = container.read(subscriptionProvider);

      expect(subscriptions.length, 1);
      expect(subscriptions.first.name, 'Netflix');
    });
  });
}
