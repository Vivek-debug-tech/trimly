import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'services/revenuecat/revenuecat_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RevenueCatService.instance.initialize();
  runApp(const ProviderScope(child: TrimlyApp()));
}
