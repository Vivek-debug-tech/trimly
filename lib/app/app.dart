import 'package:flutter/material.dart';

import 'router.dart';
import 'theme/app_theme.dart';

class TrimlyApp extends StatelessWidget {
  const TrimlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trimly',
      theme: AppTheme.light,
      initialRoute: TrimlyRouter.initialRoute,
      onGenerateRoute: TrimlyRouter.onGenerateRoute,
    );
  }
}
