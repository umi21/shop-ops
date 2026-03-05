import 'package:flutter/material.dart';
import '../../features/inventory/presentation/pages/inventory_page.dart';
import '../../features/inventory/presentation/pages/add_product_page.dart'; 

class AppRoutes {
  static const String initialRoute = '/';
  static const String addProductRoute = '/add-product'; 

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      initialRoute: (context) => const InventoryPage(),
      addProductRoute: (context) => const AddProductPage(), 
    };
  }
}