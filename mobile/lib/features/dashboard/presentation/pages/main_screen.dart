import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import '../../../sales/presentation/sales_screen.dart';
import '../../../inventory/presentation/pages/inventory_page.dart';
import '../../../expense/presentation/pages/expense_page.dart';
import '../../../../core/widgets/custom_bottom_nav.dart';
// future: reports and settings imports

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    const DashboardScreen(),
    const InventoryPage(),
    const SalesScreen(),
    const ExpensePage(),
    const Center(child: Text('Settings Screen - Coming Soon')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
      ),
    );
  }
}
