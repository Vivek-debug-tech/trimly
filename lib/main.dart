import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:trimly/data/storage/hive_adapters.dart';
import 'package:trimly/data/storage/hive_boxes.dart';
import 'package:trimly/domain/models/subscription.dart';

import 'app/app.dart';
import 'services/revenuecat/revenuecat_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  HiveAdapters.register();
  await Hive.openBox<Subscription>(HiveBoxes.subscriptions);

  await RevenueCatService.instance.initialize();
  runApp(const ProviderScope(child: TrimlyApp()));
}
