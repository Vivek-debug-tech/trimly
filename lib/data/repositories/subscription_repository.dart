import 'package:hive/hive.dart';

import '../../domain/models/subscription.dart';

class SubscriptionRepository {
	SubscriptionRepository(this._box);

	final Box<Subscription> _box;

	List<Subscription> getAllSubscriptions() =>
			_box.values.toList(growable: false);

	Subscription? getSubscriptionById(String id) => _box.get(id);

	Future<void> addSubscription(Subscription subscription) {
		return _box.put(subscription.id, subscription);
	}

	Future<void> updateSubscription(Subscription subscription) {
		return _box.put(subscription.id, subscription);
	}

	Future<void> deleteSubscription(String id) {
		return _box.delete(id);
	}

	Future<void> clearAllSubscriptions() {
		return _box.clear();
	}
}
