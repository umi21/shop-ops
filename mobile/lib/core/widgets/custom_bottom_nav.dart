import 'package:flutter/material.dart';

import '../../features/dashboard/presentation/pages/dashboard_screen.dart';
import '../../features/sales/presentation/Pages/sales_screen.dart';
import '../../features/inventory/presentation/pages/inventory_page.dart';
import '../../features/expense/presentation/pages/expense_page.dart';
import '../../features/settings/presentation/settings.dart';

class CustomBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int)? onItemSelected;

  const CustomBottomNav({Key? key, this.selectedIndex = 1, this.onItemSelected})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomAppBar(
        color: Colors.white,
        elevation: 0,
        child: SizedBox(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, 0, Icons.grid_view_rounded, 'Home'),
              _buildNavItem(context, 1, Icons.inventory_rounded, 'Inventory'),
              _buildNavItem(context, 2, Icons.show_chart_rounded, 'Sales'),
              _buildNavItem(context, 3, Icons.receipt_long_rounded, 'Expenses'),
              _buildNavItem(context, 4, Icons.settings_outlined, 'Settings'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    IconData icon,
    String label,
  ) {
    final isSelected = index == selectedIndex;
    final color = isSelected
        ? const Color(0xFF1E5EFE)
        : const Color(0xFF94A3B8);

    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          // If callback provided, only notify (let parent handle navigation)
          // Otherwise, handle navigation internally
          if (onItemSelected != null) {
            onItemSelected!(index);
          } else {
            _navigateTo(context, index);
          }
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const InventoryPage()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SalesScreen()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ExpensePage()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SettingsPage()),
        );
        break;
    }
  }
}
