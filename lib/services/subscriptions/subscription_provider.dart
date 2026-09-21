import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:trimly/data/repositories/subscription_repository.dart';
import 'package:trimly/data/storage/hive_boxes.dart';
import 'package:trimly/domain/models/subscription.dart';

final subscriptionProvider = NotifierProvider<SubscriptionController, List<Subscription>>(
  SubscriptionController.new,
);

class SubscriptionController extends Notifier<List<Subscription>> {
  late final SubscriptionRepository _repository;

  @override
  List<Subscription> build() {
    final box = Hive.box<Subscription>(HiveBoxes.subscriptions);
    _repository = SubscriptionRepository(box);
    return _repository.getAllSubscriptions();
  }

  void refresh() {
    state = _repository.getAllSubscriptions();
  }
}
