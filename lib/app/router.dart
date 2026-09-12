import 'package:flutter/material.dart';

class TrimlyRouter {
  const TrimlyRouter._();

  static const initialRoute = '/';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => const SizedBox.shrink(),
    );
  }
}
