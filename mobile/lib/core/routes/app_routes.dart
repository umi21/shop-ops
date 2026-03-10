import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/dashboard/presentation/pages/main_screen.dart';
import '../../features/inventory/presentation/pages/add_product_page.dart';

class AppRoutes {
  static const String initialRoute = '/';
  static const String mainRoute = '/main';
  static const String addProductRoute = '/add-product';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      initialRoute: (context) => const LoginScreen(),
      mainRoute: (context) => const MainScreen(),
      addProductRoute: (context) => const AddProductPage(),
    };
  }
}
