import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mobile/features/inventory/domain/entities/product.dart';
import 'package:mobile/features/inventory/presentation/manager/bloc/inventory_bloc.dart';
import 'package:mobile/features/inventory/presentation/manager/bloc/inventory_event.dart';
import 'package:mobile/features/inventory/presentation/manager/bloc/inventory_state.dart';
import 'package:mobile/injection_container.dart' as di;
import 'package:mobile/features/inventory/domain/usecases/update_product_usecase.dart';
import 'package:mobile/features/inventory/domain/usecases/get_product_detail_usecase.dart';

class ProductDetailsPage extends StatefulWidget {
  final Product product;

  const ProductDetailsPage({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage>
    with WidgetsBindingObserver {
  late Product _product;
  final _restockController = TextEditingController();

  final _nameController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _costPriceController = TextEditingController();

  List<StockChange> _stockHistory = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _product = widget.product;
    _nameController.text = _product.name;
    _sellingPriceController.text = _product.defaultSellingPrice.toString();
    _costPriceController.text = _product.costPrice.toString();
    _generateStockHistory();
    _loadLatestProduct();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _restockController.dispose();
    _nameController.dispose();
    _sellingPriceController.dispose();
    _costPriceController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadLatestProduct();
    }
  }

  Future<void> _loadLatestProduct() async {
    try {
      final getProductDetail = di.sl<GetProductDetailUseCase>();
      final result = await getProductDetail(_product.id);

      result.fold(
        (failure) {
          debugPrint('Error loading product: ${failure.message}');
        },
        (product) {
          if (mounted && product.stockQuantity != _product.stockQuantity) {
            setState(() {
              _product = product;
              _generateStockHistory();
            });
          }
        },
      );
    } catch (e) {
      debugPrint('Exception loading product: $e');
    }
  }

  void _generateStockHistory() {
    _stockHistory = [];
    final now = DateTime.now();
    int currentStock = _product.stockQuantity;

    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final change = (i % 3 == 0) ? (i ~/ 3 + 1) : 0;
      final stockAtDay = currentStock + change;
      _stockHistory.add(
        StockChange(date: date, stockQuantity: stockAtDay, change: change),
      );
    }
    _stockHistory.last = StockChange(
      date: now,
      stockQuantity: _product.stockQuantity,
      change: 0,
    );
  }

  void _showRestockDialog() {
    _restockController.text = '';
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final quantity = int.tryParse(_restockController.text);
              if (quantity != null && quantity > 0) {
                context.read<InventoryBloc>().add(
                  AdjustStockEvent(_product.id, quantity),
                );
                Navigator.pop(dialogContext);
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
      builder: (dialogContext) => AlertDialog(
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
            onPressed: () => Navigator.pop(dialogContext),
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
                  Navigator.pop(dialogContext);
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
                  Navigator.pop(dialogContext);
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

  void _removeStock() {
    if (_product.stockQuantity <= 0) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove Stock'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('How many units to remove?'),
            const SizedBox(height: 16),
            TextField(
              controller: _restockController,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Quantity to remove',
                hintText: 'Max: ${_product.stockQuantity}',
                prefixIcon: const Icon(Icons.remove_circle_outline),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final quantity = int.tryParse(_restockController.text) ?? 0;
              if (quantity > 0 && quantity <= _product.stockQuantity) {
                context.read<InventoryBloc>().add(
                  AdjustStockEvent(_product.id, -quantity),
                );
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Removed $quantity units from stock'),
                    backgroundColor: Colors.orange,
                  ),
                );
              } else if (quantity > _product.stockQuantity) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cannot remove more than available stock'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<InventoryBloc, InventoryState>(
      listener: (context, state) {
        if (state is InventoryLoadedState) {
          final updatedProduct = state.products.firstWhere(
            (p) => p.id == _product.id,
            orElse: () => _product,
          );
          if (updatedProduct.stockQuantity != _product.stockQuantity) {
            setState(() {
              _product = updatedProduct;
              _generateStockHistory();
            });
          }
        }
      },
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
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
                      if (_product.isLowStock || _product.isOutOfStock)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusBgColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 3,
                                backgroundColor: statusDotColor,
                              ),
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
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _buildProductImage(),
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
                  onPressed: _product.stockQuantity > 0 ? _removeStock : null,
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
                  onPressed: _showRestockDialog,
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

  Widget _buildProductImage() {
    if (_product.imageUrl != null && _product.imageUrl!.isNotEmpty) {
      return Image.file(
        File(_product.imageUrl!),
        fit: BoxFit.cover,
        width: 80,
        height: 80,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.inventory_2, color: Colors.orange, size: 40);
        },
      );
    }
    return const Icon(Icons.inventory_2, color: Colors.orange, size: 40);
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
    if (_stockHistory.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Center(
          child: Text(
            'No stock history available',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final maxStock = _stockHistory
        .map((e) => e.stockQuantity)
        .reduce((a, b) => a > b ? a : b);
    final minStock = _stockHistory
        .map((e) => e.stockQuantity)
        .reduce((a, b) => a < b ? a : b);
    final range = maxStock - minStock;

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
              children: _stockHistory.asMap().entries.map((entry) {
                final index = entry.key;
                final data = entry.value;
                final height = range > 0
                    ? ((data.stockQuantity - minStock) / range * 100) + 20
                    : 60.0;
                final isLast = index == _stockHistory.length - 1;
                return _buildBar(
                  height,
                  isLast ? const Color(0xFF1E5EFE) : const Color(0xFF93C5FD),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('dd MMM').format(_stockHistory.first.date),
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                DateFormat(
                  'dd MMM',
                ).format(_stockHistory[_stockHistory.length ~/ 2].date),
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                DateFormat('dd MMM').format(_stockHistory.last.date),
                style: const TextStyle(
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
      width: 8,
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
    return DateFormat('dd MMM yyyy').format(date);
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

class StockChange {
  final DateTime date;
  final int stockQuantity;
  final int change;

  StockChange({
    required this.date,
    required this.stockQuantity,
    required this.change,
  });
}
