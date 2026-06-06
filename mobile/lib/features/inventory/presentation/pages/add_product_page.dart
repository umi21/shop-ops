import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:mobile/injection_container.dart' as di;
import '../manager/bloc/add_product/add_product_bloc.dart';
import '../manager/bloc/add_product/add_product_event.dart' as add_product;
import '../manager/bloc/add_product/add_product_state.dart';
import '../manager/bloc/inventory_bloc.dart';
import '../manager/bloc/inventory_event.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({Key? key}) : super(key: key);

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _productNameController = TextEditingController();
  final _stockController = TextEditingController(text: '0');
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;

  @override
  void dispose() {
    _productNameController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AddProductBloc(
        addProductUseCase: di.sl(),
        onProductAdded: (product) {
          context.read<InventoryBloc>().add(AddProductEvent(product));
        },
      ),
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
            body: BlocListener<AddProductBloc, AddProductState>(
              listener: (context, state) {
                if (state.isSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Product saved successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                } else if (state.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${state.errorMessage}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: _selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.file(
                                  File(_selectedImage!.path),
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : DottedBorder(
                                color: const Color(0xFF135BEC),
                                strokeWidth: 2,
                                dashPattern: const [6, 4],
                                borderType: BorderType.RRect,
                                radius: const Radius.circular(16),
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_a_photo_outlined,
                                        color: Color(0xFF1E5EFE),
                                        size: 32,
                                      ),
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
                    ),
                    const SizedBox(height: 8),
                    if (_selectedImage != null)
                      Center(
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedImage = null;
                            });
                          },
                          child: const Text(
                            'Remove Photo',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),

                    _buildLabel('Product Name'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _productNameController,
                      decoration: InputDecoration(
                        hintText: 'e.g. Organic Coffee Beans',
                        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    _buildSectionTitle('INVENTORY MANAGEMENT'),
                    const SizedBox(height: 16),
                    _buildLabel('Initial Stock Level'),
                    const SizedBox(height: 8),

                    // Direct number input for stock
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _stockController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '0',
                          hintStyle: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        onChanged: (value) {
                          final stock = int.tryParse(value) ?? 0;
                          context.read<AddProductBloc>().add(
                            add_product.UpdateStockEvent(stock),
                          );
                        },
                      ),
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
                              _buildPriceField(
                                context,
                                hint: '0.00',
                                isCost: true,
                              ),
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
                              _buildPriceField(
                                context,
                                hint: '0.00',
                                isCost: false,
                              ),
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
                                child: const Icon(
                                  Icons.trending_up,
                                  color: Color(0xFF1E5EFE),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'ESTIMATED MARGIN',
                                      style: TextStyle(
                                        color: Color(0xFF1E5EFE),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          '\$${state.marginAmount.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '(${state.marginPercentage.toStringAsFixed(0)}%)',
                                          style: const TextStyle(
                                            color: Color(0xFF94A3B8),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.info_outline,
                                color: Color(0xFF94A3B8),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 40),

                    BlocBuilder<AddProductBloc, AddProductState>(
                      builder: (context, state) {
                        return SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: state.isLoading
                                ? null
                                : () {
                                    final name = _productNameController.text
                                        .trim();
                                    if (name.isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Please enter a product name',
                                          ),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                      return;
                                    }
                                    context.read<AddProductBloc>().add(
                                      add_product.SubmitProductEvent(
                                        name: name,
                                        stockQuantity: state.stock,
                                        sellingPrice: state.sellingPrice,
                                        imageUrl: _selectedImage?.path,
                                      ),
                                    );
                                  },
                            icon: state.isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                  ),
                            label: Text(
                              state.isLoading ? 'Saving...' : 'Save Product',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E5EFE),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF64748B),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF1E5EFE),
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildPriceField(
    BuildContext context, {
    required String hint,
    required bool isCost,
  }) {
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

          bloc.add(
            add_product.UpdatePricesEvent(
              costPrice: isCost ? parsedValue : currentState.costPrice,
              sellingPrice: !isCost ? parsedValue : currentState.sellingPrice,
            ),
          );
        },
        decoration: InputDecoration(
          prefixText: '\$ ',
          prefixStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 16),
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
