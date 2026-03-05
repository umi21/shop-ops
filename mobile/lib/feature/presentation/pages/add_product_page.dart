import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dotted_border/dotted_border.dart'; 
import '../manager/bloc/add_product/add_product_bloc.dart';
import '../manager/bloc/add_product/add_product_event.dart';
import '../manager/bloc/add_product/add_product_state.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({Key? key}) : super(key: key);

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  String? _selectedCategory;
  
  final List<String> _categories = ['Beverages', 'Dairy', 'Bakery', 'Fruit', 'Meat'];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddProductBloc(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leadingWidth: 80,
              leading: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Color(0xFF1E5EFE), fontSize: 16),
                ),
              ),
              centerTitle: true,
              title: const Text(
                'Add Product',
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: DottedBorder(
                      color: const Color(0xFF135BEC), 
                      strokeWidth: 2, 
                      dashPattern: const [6, 4], 
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(16),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9), 
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.add_a_photo_outlined, color: Color(0xFF1E5EFE), size: 32),
                            SizedBox(height: 8),
                            Text(
                              'ADD PHOTO',
                              style: TextStyle(
                                color: Color(0xFF1E5EFE),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  _buildLabel('Product Name'),
                  const SizedBox(height: 8),
                  _buildTextField(hint: 'e.g. Organic Coffee Beans'),
                  const SizedBox(height: 20),

                  _buildLabel('Category'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedCategory,
                        hint: const Text('Select Category', style: TextStyle(color: Color(0xFF0F172A))),
                        icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
                        items: _categories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category, style: const TextStyle(color: Color(0xFF1E293B))),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCategory = newValue;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  _buildSectionTitle('INVENTORY MANAGEMENT'),
                  const SizedBox(height: 16),
                  _buildLabel('Initial Stock Level'),
                  const SizedBox(height: 8),
                  
                  BlocBuilder<AddProductBloc, AddProductState>(
                    builder: (context, state) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF1E5EFE)),
                              onPressed: () => context.read<AddProductBloc>().add(UpdateStockEvent(state.stock - 1)),
                            ),
                            Text(
                              '${state.stock}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, color: Color(0xFF1E5EFE)),
                              onPressed: () => context.read<AddProductBloc>().add(UpdateStockEvent(state.stock + 1)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),

                  _buildSectionTitle('PRICING & MARGINS'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Cost Price'),
                            const SizedBox(height: 8),
                            _buildPriceField(context, hint: '0.00', isCost: true),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Selling Price'),
                            const SizedBox(height: 8),
                            _buildPriceField(context, hint: '0.00', isCost: false),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  BlocBuilder<AddProductBloc, AddProductState>(
                    builder: (context, state) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFFE0E7FF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.trending_up, color: Color(0xFF1E5EFE), size: 20),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'ESTIMATED MARGIN',
                                    style: TextStyle(color: Color(0xFF1E5EFE), fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        '\$${state.marginAmount.toStringAsFixed(2)}',
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '(${state.marginPercentage.toStringAsFixed(0)}%)',
                                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.info_outline, color: Color(0xFF94A3B8)),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Product saved successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );

                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.check_circle, color: Colors.white),
                      label: const Text(
                        'Save Product',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E5EFE),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(color: Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.w500),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(color: Color(0xFF1E5EFE), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
    );
  }

  Widget _buildTextField({required String hint}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildPriceField(BuildContext context, {required String hint, required bool isCost}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (value) {
          final bloc = context.read<AddProductBloc>();
          final currentState = bloc.state;
          final double parsedValue = double.tryParse(value) ?? 0.0;
          
          bloc.add(UpdatePricesEvent(
            costPrice: isCost ? parsedValue : currentState.costPrice,
            sellingPrice: !isCost ? parsedValue : currentState.sellingPrice,
          ));
        },
        decoration: InputDecoration(
          prefixText: '\$ ',
          prefixStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 16),
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}