import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int)? onItemSelected; 

  const CustomBottomNav({
    Key? key, 
    this.selectedIndex = 1,
    this.onItemSelected, 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
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
              _buildNavItem(0, Icons.grid_view_rounded, 'Home'),
              _buildNavItem(1, Icons.inventory_rounded, 'Inventory'),
              _buildNavItem(2, Icons.show_chart_rounded, 'Sales'), 
              _buildNavItem(3, Icons.receipt_long_rounded, 'Expenses'),
              _buildNavItem(4, Icons.settings_outlined, 'Settings'),
            ],
          ),
        ),
      ),
    );
  }

  // NOUVEAU : La fonction prend maintenant l'index de l'élément
  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = index == selectedIndex;
    final color = isSelected ? const Color(0xFF1E5EFE) : const Color(0xFF94A3B8);
    
    // NOUVEAU : On rend l'élément cliquable
    return GestureDetector(
      onTap: () {
        if (onItemSelected != null && !isSelected) {
          onItemSelected!(index);
        }
      },
      behavior: HitTestBehavior.opaque, // Rend toute la zone cliquable
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
}