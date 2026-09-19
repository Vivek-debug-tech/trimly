import 'package:flutter/material.dart';

import '../features/app_shell.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/optimizer/optimizer_screen.dart';
import '../features/profile/profile_screen.dart';
import '../domain/models/subscription.dart';
import '../features/renewal_radar/renewal_details_screen.dart';
import '../features/renewal_radar/renewal_radar_screen.dart';
import '../features/savings_mission/savings_mission_screen.dart';
import '../features/trials/trials_screen.dart';
import '../features/value_check/value_check_details_screen.dart';
import '../features/value_check/value_check_screen.dart';

class TrimlyRouter {
  const TrimlyRouter._();

  static const initialRoute = '/onboarding';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/onboarding':
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const OnboardingScreen(),
        );
      case '/home':
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const TrimlyAppShell(),
        );
      case '/value-check':
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ValueCheckScreen(),
        );
      case '/value-check-details':
        final subscription = settings.arguments as Subscription?;
        if (subscription == null) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => const ValueCheckScreen(),
          );
        }
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => ValueCheckDetailsScreen(subscription: subscription),
        );
      case '/savings-mission':
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const SavingsMissionScreen(),
        );
      case '/optimizer':
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const OptimizerScreen(),
        );
      case '/renewal-radar':
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const RenewalRadarScreen(),
        );
      case '/renewal-details':
        final subscription = settings.arguments as Subscription?;
        if (subscription == null) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => const RenewalRadarScreen(),
          );
        }
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => RenewalDetailsScreen(subscription: subscription),
        );
      case '/trials':
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const TrialsScreen(),
        );
      case '/profile':
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ProfileScreen(),
        );
      default:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const OnboardingScreen(),
        );
    }
  }
}
