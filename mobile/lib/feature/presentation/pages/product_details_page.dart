import 'package:flutter/material.dart';
import '../manager/bloc/inventory_bloc.dart'; 

class ProductDetailsPage extends StatelessWidget {
  final ProductEntity product;

  const ProductDetailsPage({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color statusBgColor;
    Color statusTextColor;
    String statusText;
    Color statusDotColor;

    if (product.quantity == 0) {
      statusBgColor = const Color(0xFFFFEBEB);
      statusTextColor = const Color(0xFFEF4444);
      statusDotColor = const Color(0xFFEF4444);
      statusText = 'OUT OF STOCK';
    } else if (product.quantity <= 5) {
      statusBgColor = const Color(0xFFFFF3E0);
      statusTextColor = const Color(0xFFF97316);
      statusDotColor = const Color(0xFFF97316);
      statusText = 'LOW STOCK';
    } else {
      statusBgColor = const Color(0xFFDCFCE7);
      statusTextColor = const Color(0xFF16A34A);
      statusDotColor = const Color(0xFF16A34A);
      statusText = 'HEALTHY STOCK'; 
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E5EFE), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Inventory',
          style: TextStyle(color: Color(0xFF1E293B), fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share, color: Color(0xFF1E5EFE)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF1E5EFE)),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.category.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B),
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: NetworkImage(product.imageUrl), 
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: product.imageUrl.isEmpty || product.imageUrl == 'url' 
                      ? const Icon(Icons.headphones, color: Colors.orange, size: 40) 
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 24),

            const Text(
              'Current Stock Level',
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${product.quantity}',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E5EFE),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'units',
                  style: TextStyle(fontSize: 18, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusBgColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(radius: 3, backgroundColor: statusDotColor),
                  const SizedBox(width: 6),
                  Text(
                    statusText,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusTextColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(child: _buildSummaryCard('MONTHLY SALES', '48', '+12%', true)),
                const SizedBox(width: 16),
                Expanded(child: _buildSummaryCard('STOCK VALUE', '\$49,558', '', false)),
              ],
            ),
            const SizedBox(height: 24),

            _buildChartSection(),
            const SizedBox(height: 24),

            _buildPricingHistory(),
            const SizedBox(height: 24),

            _buildLogisticsDetails(),
            const SizedBox(height: 40), 
          ],
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), offset: const Offset(0, -4), blurRadius: 10),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.remove, color: Colors.white, size: 20),
                  label: const Text('REMOVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF0F172A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, color: Colors.white, size: 20),
                  label: const Text('ADD STOCK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF1E5EFE),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Internal Widgets ---

  Widget _buildSummaryCard(String title, String value, String subtitle, bool isPositive) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(subtitle, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isPositive ? const Color(0xFF16A34A) : const Color(0xFFEF4444))),
              ]
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('SALES TRENDS (30D)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(6)),
                child: const Text('Last 30 Days', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1E5EFE))),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBar(40, const Color(0xFFF1F5F9)),
                _buildBar(60, const Color(0xFFF1F5F9)),
                _buildBar(50, const Color(0xFFF1F5F9)),
                _buildBar(80, const Color(0xFF93C5FD)),
                _buildBar(120, const Color(0xFF1E5EFE)), // Max
                _buildBar(75, const Color(0xFF93C5FD)),
                _buildBar(55, const Color(0xFFF1F5F9)),
                _buildBar(90, const Color(0xFFF1F5F9)),
                _buildBar(115, const Color(0xFF1E5EFE)),
                _buildBar(65, const Color(0xFFBFDBFE)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('01 NOV', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
              Text('15 NOV', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
              Text('30 NOV', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBar(double height, Color color) {
    return Container(
      width: 22,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildPricingHistory() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('PRICING HISTORY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
          const SizedBox(height: 16),
          _buildPriceRow('\$349.00', 'Set by Admin', 'Today, 09:12 AM', isRecent: true),
          const Divider(height: 30, color: Color(0xFFE2E8F0)),
          _buildPriceRow('\$329.00', 'Initial Price', 'Nov 24, 2023', isRecent: false),
          const Divider(height: 30, color: Color(0xFFE2E8F0)),
          _buildPriceRow('\$349.00', 'Initial Price', 'Aug 12, 2023', isRecent: false),
          const Divider(height: 20, color: Color(0xFFE2E8F0)),
          Center(
            child: TextButton(
              onPressed: () {},
              child: const Text('VIEW FULL LOGS', style: TextStyle(color: Color(0xFF1E5EFE), fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String price, String subtitle, String date, {required bool isRecent}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(price, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isRecent ? const Color(0xFF1E293B) : const Color(0xFF0F172A))),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
          ],
        ),
        Text(date, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
      ],
    );
  }

  Widget _buildLogisticsDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('LOGISTICS & DETAILS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
          const SizedBox(height: 20),
          _buildLogisticsRow('SKU Number', product.sku),
          const SizedBox(height: 16),
          _buildLogisticsRow('Supplier', 'Sony Electronics Distribution'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Reorder Point', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
              Row(
                children: const [
                  Text('25 units', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  SizedBox(width: 4),
                  Icon(Icons.notifications_active, color: Color(0xFF1E5EFE), size: 16),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildLogisticsRow('Last Restocked', 'Oct 15, 2023'),
        ],
      ),
    );
  }

  Widget _buildLogisticsRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 14, color: Color(0xFF64748B))),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
      ],
    );
  }
}