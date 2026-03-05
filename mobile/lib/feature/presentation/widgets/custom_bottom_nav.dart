import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  const CustomBottomNav({Key? key}) : super(key: key);

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
              _buildNavItem(Icons.grid_view_rounded, 'Home', false),
              // L'icône la plus proche de la maquette pour Inventory
              _buildNavItem(Icons.inventory_rounded, 'Inventory', true),
              _buildNavItem(Icons.show_chart_rounded, 'Sales', false),
              _buildNavItem(Icons.receipt_long_rounded, 'Expenses', false),
              _buildNavItem(Icons.settings_outlined, 'Settings', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected) {
    final color = isSelected ? const Color(0xFF1E5EFE) : const Color(0xFF94A3B8);
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}