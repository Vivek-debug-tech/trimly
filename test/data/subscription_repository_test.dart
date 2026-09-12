import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:trimly/core/enums/billing_cycle.dart';
import 'package:trimly/core/enums/decision_status.dart';
import 'package:trimly/core/enums/importance.dart';
import 'package:trimly/core/enums/savings_action.dart';
import 'package:trimly/core/enums/usage_frequency.dart';
import 'package:trimly/data/storage/hive_adapters.dart';
import 'package:trimly/data/storage/hive_boxes.dart';
import 'package:trimly/domain/models/subscription.dart';
import 'package:trimly/data/repositories/subscription_repository.dart';

void main() {
  late Directory hiveDirectory;
  late Box<Subscription> box;
  late SubscriptionRepository repository;

  setUpAll(() async {
    hiveDirectory = await Directory.systemTemp.createTemp('trimly_hive_test_');
    Hive.init(hiveDirectory.path);
    HiveAdapters.register();
  });

  setUp(() async {
    box = await Hive.openBox<Subscription>(HiveBoxes.subscriptions);
    await box.clear();
    repository = SubscriptionRepository(box);
  });

  tearDown(() async {
    await box.close();
  });

  tearDownAll(() async {
    await Hive.close();
    await hiveDirectory.delete(recursive: true);
  });

  test('Subscription can be created', () {
    final subscription = makeSubscription();

    expect(subscription.id, 'streaming');
    expect(subscription.price, 12.99);
    expect(subscription.billingCycle, BillingCycle.monthly);
  });

  test('nullable Subscription fields work', () {
    final subscription = makeSubscription();

    expect(subscription.trialEndDate, isNull);
    expect(subscription.postTrialPrice, isNull);
    expect(subscription.usageFrequency, isNull);
    expect(subscription.importance, isNull);
    expect(subscription.impactScore, isNull);
  });

  test('enum values persist correctly', () async {
    final subscription = makeSubscription(
      usageFrequency: UsageFrequency.severalPerWeek,
      importance: Importance.high,
      decisionStatus: DecisionStatus.review,
    );

    await box.put(subscription.id, subscription);
    final restored = box.get(subscription.id)!;

    expect(restored.billingCycle, BillingCycle.monthly);
    expect(restored.usageFrequency, UsageFrequency.severalPerWeek);
    expect(restored.importance, Importance.high);
    expect(restored.decisionStatus, DecisionStatus.review);

    final enumBox = await Hive.openBox<dynamic>('enum_values');
    await enumBox.put('savingsAction', SavingsAction.cancelled);
    expect(enumBox.get('savingsAction'), SavingsAction.cancelled);
    await enumBox.deleteFromDisk();
  });

  test('Subscription can be written to Hive and read back', () async {
    final subscription = makeSubscription(
      trialEndDate: DateTime.utc(2026, 10, 1),
      postTrialPrice: 19.99,
      impactScore: 0.75,
    );

    await box.put(subscription.id, subscription);
    final restored = box.get(subscription.id)!;

    expect(restored.id, subscription.id);
    expect(restored.name, subscription.name);
    expect(restored.nextRenewalDate, subscription.nextRenewalDate);
    expect(restored.trialEndDate, subscription.trialEndDate);
    expect(restored.postTrialPrice, subscription.postTrialPrice);
    expect(restored.impactScore, subscription.impactScore);
  });

  test('repository CRUD works', () async {
    final subscription = makeSubscription();

    await repository.addSubscription(subscription);
    expect(repository.getSubscriptionById(subscription.id)?.name, 'Streamly');

    final updated = makeSubscription(name: 'Streamly Plus');
    await repository.updateSubscription(updated);

    expect(repository.getAllSubscriptions(), hasLength(1));
    expect(repository.getSubscriptionById(subscription.id)?.name, 'Streamly Plus');
  });

  test('repository delete works', () async {
    final subscription = makeSubscription();
    await repository.addSubscription(subscription);

    await repository.deleteSubscription(subscription.id);

    expect(repository.getSubscriptionById(subscription.id), isNull);
    expect(repository.getAllSubscriptions(), isEmpty);
  });

  test('repository clear-all works', () async {
    await repository.addSubscription(makeSubscription());
    await repository.addSubscription(makeSubscription(id: 'music'));

    await repository.clearAllSubscriptions();

    expect(repository.getAllSubscriptions(), isEmpty);
  });
}

Subscription makeSubscription({
  String id = 'streaming',
  String name = 'Streamly',
  DateTime? trialEndDate,
  double? postTrialPrice,
  UsageFrequency? usageFrequency,
  Importance? importance,
  double? impactScore,
  DecisionStatus decisionStatus = DecisionStatus.keep,
}) {
  final now = DateTime.utc(2026, 9, 12);
  return Subscription(
    id: id,
    name: name,
    category: 'Entertainment',
    price: 12.99,
    currency: 'USD',
    billingCycle: BillingCycle.monthly,
    nextRenewalDate: DateTime.utc(2026, 10, 12),
    trialEndDate: trialEndDate,
    postTrialPrice: postTrialPrice,
    usageFrequency: usageFrequency,
    importance: importance,
    impactScore: impactScore,
    decisionStatus: decisionStatus,
    createdAt: now,
    updatedAt: now,
  );
}
