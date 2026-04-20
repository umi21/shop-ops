import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/expandable_fab.dart';
import '../../../../injection_container.dart' as di;
import '../manager/bloc/inventory_bloc.dart';
import '../manager/bloc/inventory_event.dart';
import '../manager/bloc/inventory_state.dart';
import '../widgets/product_card.dart';
import 'add_product_page.dart';
import 'product_details_page.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InventoryBloc(
        getProductsUseCase: di.sl(),
        addProductUseCase: di.sl(),
        updateProductUseCase: di.sl(),
        deleteProductUseCase: di.sl(),
        adjustStockUseCase: di.sl(),
      )..add(LoadInventoryEvent('default_business_id')),
      child: const _InventoryPageContent(),
    );
  }
}

class _InventoryPageContent extends StatefulWidget {
  const _InventoryPageContent();

  @override
  State<_InventoryPageContent> createState() => _InventoryPageContentState();
}

class _InventoryPageContentState extends State<_InventoryPageContent> {
  bool _avatarPressed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Inventory',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  GestureDetector(
                    onTapDown: (_) => setState(() => _avatarPressed = true),
                    onTapUp: (_) {
                      setState(() => _avatarPressed = false);
                      Navigator.pushNamed(context, AppRoutes.profileRoute);
                    },
                    onTapCancel: () => setState(() => _avatarPressed = false),
                    child: AnimatedScale(
                      scale: _avatarPressed ? 0.88 : 1.0,
                      duration: const Duration(milliseconds: 100),
                      child: CircleAvatar(
                        backgroundColor: const Color(0xFFE2E8F0),
                        child: const Icon(
                          Icons.person,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  onChanged: (query) {
                    context.read<InventoryBloc>().add(
                      SearchProductsEvent(query),
                    );
                  },
                  decoration: InputDecoration(
                    hintText: 'Search products, SKUs...',
                    hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF94A3B8),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Products list
              Expanded(
                child: BlocBuilder<InventoryBloc, InventoryState>(
                  builder: (context, state) {
                    if (state is InventoryLoadingState) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is InventoryLoadedState) {
                      if (state.filteredProducts.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                state.products.isEmpty
                                    ? 'No products yet'
                                    : 'No products found',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                              if (state.products.isEmpty) ...[
                                const SizedBox(height: 8),
                                const Text(
                                  'Tap the + button to add your first product',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ],
                          ),
                        );
                      }

                      return Column(
                        children: [
                          // List of categories (horizontal)
                          if (state.categories.length > 1)
                            SizedBox(
                              height: 40,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: state.categories.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(width: 8),
                                itemBuilder: (context, index) {
                                  final category = state.categories[index];
                                  final isSelected =
                                      category == state.selectedCategory;
                                  return GestureDetector(
                                    onTap: () {
                                      context.read<InventoryBloc>().add(
                                        ChangeCategoryEvent(category),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? const Color(0xFF1E5EFE)
                                            : const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        category,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: isSelected
                                              ? Colors.white
                                              : const Color(0xFF475569),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          if (state.categories.length > 1)
                            const SizedBox(height: 24),

                          // List of products (vertical)
                          Expanded(
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              itemCount: state.filteredProducts.length,
                              itemBuilder: (context, index) {
                                final currentProduct =
                                    state.filteredProducts[index];

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (navContext) =>
                                            BlocProvider.value(
                                              value: context
                                                  .read<InventoryBloc>(),
                                              child: ProductDetailsPage(
                                                product: currentProduct,
                                              ),
                                            ),
                                      ),
                                    );
                                  },
                                  child: ProductCard(product: currentProduct),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    }

                    if (state is InventoryErrorState) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error: ${state.message}',
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                context.read<InventoryBloc>().add(
                                  LoadInventoryEvent('default_business_id'),
                                );
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 20.0, bottom: 20.0),
        child: ExpandableFab(
          icon: const Icon(Icons.add, color: Colors.white),
          label: 'Add Item',
          backgroundColor: const Color(0xFF1E5EFE),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (navContext) => BlocProvider.value(
                  value: context.read<InventoryBloc>(),
                  child: const AddProductPage(),
                ),
              ),
            );
          },
          expandOnHover: true,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
