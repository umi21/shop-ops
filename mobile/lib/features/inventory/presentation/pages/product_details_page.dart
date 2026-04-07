import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/inventory/domain/entities/product.dart';
import 'package:mobile/features/inventory/presentation/manager/bloc/inventory_bloc.dart';
import 'package:mobile/features/inventory/presentation/manager/bloc/inventory_event.dart';
import 'package:mobile/injection_container.dart' as di;
import 'package:mobile/features/inventory/domain/usecases/update_product_usecase.dart';

class ProductDetailsPage extends StatefulWidget {
  final Product product;

  const ProductDetailsPage({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  late Product _product;
  final _restockController = TextEditingController();
  bool _isEditing = false;

  final _nameController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _costPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _nameController.text = _product.name;
    _sellingPriceController.text = _product.defaultSellingPrice.toString();
    _costPriceController.text = _product.costPrice.toString();
  }

  @override
  void dispose() {
    _restockController.dispose();
    _nameController.dispose();
    _sellingPriceController.dispose();
    _costPriceController.dispose();
    super.dispose();
  }

  void _showRestockDialog() {
    _restockController.text = '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restock Product'),
        content: TextField(
          controller: _restockController,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Quantity to add',
            hintText: 'Enter number of units',
            prefixIcon: Icon(Icons.add_circle_outline),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final quantity = int.tryParse(_restockController.text);
              if (quantity != null && quantity > 0) {
                context.read<InventoryBloc>().add(
                  AdjustStockEvent(_product.id, quantity),
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added $quantity units to stock'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Add Stock'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog() {
    _nameController.text = _product.name;
    _sellingPriceController.text = _product.defaultSellingPrice.toString();
    _costPriceController.text = _product.costPrice.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  prefixIcon: Icon(Icons.inventory_2),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _sellingPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Selling Price',
                  prefixIcon: Icon(Icons.attach_money),
                  prefixText: '\$ ',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _costPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cost Price',
                  prefixIcon: Icon(Icons.money_off),
                  prefixText: '\$ ',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = _nameController.text.trim();
              final sellingPrice =
                  double.tryParse(_sellingPriceController.text) ??
                  _product.defaultSellingPrice;
              final costPrice =
                  double.tryParse(_costPriceController.text) ??
                  _product.costPrice;

              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Product name cannot be empty'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final updatedProduct = _product.copyWith(
                name: name,
                defaultSellingPrice: sellingPrice,
                costPrice: costPrice,
                updatedAt: DateTime.now(),
              );

              final updateUseCase = di.sl<UpdateProductUseCase>();
              final result = await updateUseCase(
                UpdateProductParams(product: updatedProduct),
              );

              if (!context.mounted) return;

              result.fold(
                (failure) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${failure.message}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
                (product) {
                  setState(() {
                    _product = product;
                  });
                  context.read<InventoryBloc>().add(
                    UpdateProductEvent(product),
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Product updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color statusBgColor;
    Color statusTextColor;
    String statusText;
    Color statusDotColor;

    if (_product.isOutOfStock) {
      statusBgColor = const Color(0xFFFFEBEB);
      statusTextColor = const Color(0xFFEF4444);
      statusDotColor = const Color(0xFFEF4444);
      statusText = 'OUT OF STOCK';
    } else if (_product.isLowStock) {
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
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF1E5EFE),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Product Details',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF1E5EFE)),
            onPressed: _showEditDialog,
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
                        _product.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ID: ${_product.id.substring(0, 8)}...',
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
                  ),
                  child: _product.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            _product.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.inventory_2,
                              color: Colors.orange,
                              size: 40,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.inventory_2,
                          color: Colors.orange,
                          size: 40,
                        ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            const Text(
              'Current Stock Level',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${_product.stockQuantity}',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E5EFE),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'units',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
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
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: statusTextColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'SELLING PRICE',
                    '\$${_product.defaultSellingPrice.toStringAsFixed(2)}',
                    '',
                    false,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    'COST PRICE',
                    '\$${_product.costPrice.toStringAsFixed(2)}',
                    '',
                    false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'LOW STOCK THRESHOLD',
                    '${_product.lowStockThreshold}',
                    '',
                    false,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    'PROFIT MARGIN',
                    '\$${(_product.defaultSellingPrice - _product.costPrice).toStringAsFixed(2)}',
                    '',
                    (_product.defaultSellingPrice - _product.costPrice) >= 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildChartSection(),
            const SizedBox(height: 24),

            _buildProductDetails(),
            const SizedBox(height: 40),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              offset: const Offset(0, -4),
              blurRadius: 10,
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _product.stockQuantity > 0
                      ? () {
                          context.read<InventoryBloc>().add(
                            AdjustStockEvent(_product.id, -1),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Removed 1 unit from stock'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      : null,
                  icon: const Icon(Icons.remove, color: Colors.white, size: 20),
                  label: const Text(
                    'REMOVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF0F172A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showRestockDialog();
                  },
                  icon: const Icon(Icons.add, color: Colors.white, size: 20),
                  label: const Text(
                    'RESTOCK',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF1E5EFE),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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

  Widget _buildSummaryCard(
    String title,
    String value,
    String subtitle,
    bool isPositive,
  ) {
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isPositive
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFEF4444),
                  ),
                ),
              ],
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
              const Text(
                'STOCK HISTORY',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748B),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Last 30 Days',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E5EFE),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(
                10,
                (index) => _buildBar(
                  30 + (index * 10).toDouble(),
                  index == 9
                      ? const Color(0xFF1E5EFE)
                      : const Color(0xFF93C5FD),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '01 NOV',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '15 NOV',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '30 NOV',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
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

  Widget _buildProductDetails() {
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
          const Text(
            'PRODUCT DETAILS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 20),
          _buildLogisticsRow('Product ID', _product.id.substring(0, 13)),
          const SizedBox(height: 16),
          _buildLogisticsRow(
            'Business ID',
            _product.businessId.substring(0, 13),
          ),
          const SizedBox(height: 16),
          _buildLogisticsRow(
            'Low Stock Threshold',
            '${_product.lowStockThreshold} units',
          ),
          const SizedBox(height: 16),
          _buildLogisticsRow('Created', _formatDate(_product.createdAt)),
          const SizedBox(height: 16),
          _buildLogisticsRow('Last Updated', _formatDate(_product.updatedAt)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildLogisticsRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
