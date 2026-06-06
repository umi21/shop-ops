import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/dashboard/presentation/pages/main_screen.dart';
import '../../features/inventory/presentation/pages/add_product_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_screen.dart';
import '../../features/auth/presentation/pages/signup_screen.dart';
import '../../features/settings/presentation/settings.dart';
import '../../features/auth/presentation/pages/profile_screen.dart';

class AppRoutes {
  static const String initialRoute = '/onboarding';
  static const String onboardingRoute = '/onboarding';
  static const String loginRoute = '/login';
  static const String signupRoute = '/signup';
  static const String mainRoute = '/main';
  static const String addProductRoute = '/add-product';
  static const String settingsRoute = '/settings';
  static const String profileRoute = '/profile';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      initialRoute: (context) => const OnboardingScreen(),
      loginRoute: (context) => const LoginScreen(),
      mainRoute: (context) => const MainScreen(),
      addProductRoute: (context) => const AddProductPage(),
      signupRoute: (context) => const SignupScreen(),
      settingsRoute: (context) => const SettingsPage(),
      profileRoute: (context) => const ProfileScreen(),
    };
  }
}
