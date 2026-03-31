import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/injection_container.dart' as di;
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/expandable_fab.dart';
import '../../domain/entities/sale.dart';
import '../manager/bloc/sales_bloc.dart';
import '../manager/bloc/sales_event.dart';
import '../manager/bloc/sales_state.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  bool _avatarPressed = false;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  static const primary = Color(0xFF1765FF);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SalesBloc(
        getSalesUseCase: di.sl(),
        addSaleUseCase: di.sl(),
        voidSaleUseCase: di.sl(),
      )..add(LoadSalesEvent('default_business_id')),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: Colors.grey[50],
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Sales History',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTapDown: (_) =>
                                  setState(() => _avatarPressed = true),
                              onTapUp: (_) {
                                setState(() => _avatarPressed = false);
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.profileRoute,
                                );
                              },
                              onTapCancel: () =>
                                  setState(() => _avatarPressed = false),
                              child: AnimatedScale(
                                scale: _avatarPressed ? 0.88 : 1.0,
                                duration: const Duration(milliseconds: 100),
                                child: const CircleAvatar(
                                  backgroundColor: Color(0xFFE2E8F0),
                                  child: Icon(
                                    Icons.person,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: BlocBuilder<SalesBloc, SalesState>(
                      builder: (context, state) {
                        if (state is SalesLoadedState) {
                          return _SummaryCard(
                            totalRevenue: state.totalRevenue,
                            transactionCount: state.transactionCount,
                            averageSale: state.averageSale,
                          );
                        }
                        return const _SummaryCard(
                          totalRevenue: 0,
                          transactionCount: 0,
                          averageSale: 0,
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 18),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: BlocBuilder<SalesBloc, SalesState>(
                      builder: (context, state) {
                        int selectedIndex = 0;
                        if (state is SalesLoadedState) {
                          switch (state.selectedPeriod) {
                            case 'Weekly':
                              selectedIndex = 1;
                              break;
                            case 'Monthly':
                              selectedIndex = 2;
                              break;
                            default:
                              selectedIndex = 0;
                          }
                        }
                        return _TabRow(
                          selected: selectedIndex,
                          onTap: (i) {
                            final period = ['Daily', 'Weekly', 'Monthly'][i];
                            context.read<SalesBloc>().add(
                              ChangeSalesPeriodEvent(period),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 14),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) {
                        setState(() => _searchQuery = v);
                        context.read<SalesBloc>().add(SearchSalesEvent(v));
                      },
                      decoration: InputDecoration(
                        hintText: 'Search product or ID...',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey[400],
                          size: 20,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Expanded(
                    child: BlocBuilder<SalesBloc, SalesState>(
                      builder: (context, state) {
                        if (state is SalesLoadingState) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (state is SalesLoadedState) {
                          if (state.groupedSales.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.receipt_long_outlined,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No sales for this period',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            children: [
                              for (final entry
                                  in state.groupedSales.entries) ...[
                                _GroupHeader(
                                  label: entry.key.toUpperCase(),
                                  total: entry.value.fold(
                                    0.0,
                                    (sum, s) => sum + s.total,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _GroupCard(
                                  sales: entry.value,
                                  onVoid: (saleId) {
                                    context.read<SalesBloc>().add(
                                      VoidSaleEvent(saleId),
                                    );
                                  },
                                ),
                                const SizedBox(height: 18),
                              ],
                            ],
                          );
                        }

                        if (state is SalesErrorState) {
                          return Center(
                            child: Text(
                              'Error: ${state.message}',
                              style: const TextStyle(color: Colors.red),
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
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(right: 20.0, bottom: 20.0),
              child: ExpandableFab(
                icon: const Icon(Icons.add, color: Colors.white),
                label: 'Add Sale',
                backgroundColor: primary,
                onTap: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const _QuickAddSaleSheet(),
                ),
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final double totalRevenue;
  final int transactionCount;
  final double averageSale;

  const _SummaryCard({
    required this.totalRevenue,
    required this.transactionCount,
    required this.averageSale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1765FF), Color(0xFF2979FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1765FF).withAlpha(89),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              Icons.trending_up,
              size: 100,
              color: Colors.white.withAlpha(20),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Revenue',
                style: TextStyle(
                  color: Colors.white.withAlpha(217),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '\$${totalRevenue.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _StatChip(label: 'TRANSACTIONS', value: '$transactionCount'),
                  const SizedBox(width: 32),
                  _StatChip(
                    label: 'AVERAGE SALE',
                    value: '\$${averageSale.toStringAsFixed(2)}',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;

  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withAlpha(166),
            fontSize: 10,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _TabRow extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onTap;
  static const primary = Color(0xFF1765FF);

  const _TabRow({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const labels = ['Daily', 'Weekly', 'Monthly'];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: List.generate(labels.length, (i) {
          final active = i == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: active ? primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: active ? Colors.white : Colors.grey[600],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  final String label;
  final double total;

  const _GroupHeader({required this.label, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.grey,
            letterSpacing: 0.4,
          ),
        ),
        Text(
          '\$${total.toStringAsFixed(2)} Total',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1765FF),
          ),
        ),
      ],
    );
  }
}

class _GroupCard extends StatelessWidget {
  final List<Sale> sales;
  final Function(String) onVoid;

  const _GroupCard({required this.sales, required this.onVoid});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: List.generate(sales.length, (i) {
          final sale = sales[i];
          return Column(
            children: [
              _SaleTile(sale: sale, onVoid: () => onVoid(sale.id)),
              if (i < sales.length - 1)
                Divider(
                  height: 1,
                  indent: 68,
                  endIndent: 16,
                  color: Colors.grey.shade100,
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _SaleTile extends StatelessWidget {
  final Sale sale;
  final VoidCallback onVoid;

  const _SaleTile({required this.sale, required this.onVoid});

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    final amountColor = sale.isVoided ? Colors.red : const Color(0xFF1765FF);
    final amountText = sale.isVoided
        ? '-\$${sale.total.abs().toStringAsFixed(2)}'
        : '+\$${sale.total.toStringAsFixed(2)}';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: sale.isVoided
              ? const Color(0xFFFFEEEE)
              : const Color(0xFFEEF3FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          sale.isVoided ? Icons.replay : Icons.shopping_cart,
          color: sale.isVoided ? Colors.red : const Color(0xFF1765FF),
          size: 22,
        ),
      ),
      title: Text(
        sale.isVoided ? 'Voided Sale' : 'Product ${sale.productId}',
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${sale.quantity} units \u2022 ${_formatTime(sale.createdAt)}',
        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            amountText,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: amountColor,
            ),
          ),
          if (sale.isVoided)
            const Text(
              'VOIDED',
              style: TextStyle(
                fontSize: 10,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}

class _QuickAddSaleSheet extends StatefulWidget {
  const _QuickAddSaleSheet();

  @override
  State<_QuickAddSaleSheet> createState() => _QuickAddSaleSheetState();
}

class _QuickAddSaleSheetState extends State<_QuickAddSaleSheet> {
  static const green = Color(0xFF2ECC40);
  static const primary = Color(0xFF1765FF);

  String _quantity = '2';
  final double _unitPrice = 18.50;
  bool _paymentReceived = true;
  bool _addPressed = false;

  final _productSearchController = TextEditingController();

  @override
  void dispose() {
    _productSearchController.dispose();
    super.dispose();
  }

  double get _total => (double.tryParse(_quantity) ?? 0) * _unitPrice;

  void _keyTap(String key) {
    setState(() {
      if (key == '\u232b') {
        _quantity = _quantity.length > 1
            ? _quantity.substring(0, _quantity.length - 1)
            : '0';
      } else if (key == '.') {
        if (!_quantity.contains('.')) _quantity += '.';
      } else {
        _quantity = _quantity == '0' ? key : _quantity + key;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints: BoxConstraints(maxHeight: screenHeight * 0.92),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Quick Add Sale',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PRODUCT',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _productSearchController,
                    decoration: InputDecoration(
                      hintText: 'Search product or SKU...',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _Chip(label: 'In Stock: -- units', color: green),
                      const SizedBox(width: 8),
                      _Chip(
                        label: 'Price: \$${_unitPrice.toStringAsFixed(2)}',
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'QUANTITY',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 64,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: green, width: 2),
                          ),
                          child: Text(
                            _quantity,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'UNIT PRICE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 64,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Text(
                            '\$${_unitPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FBF0),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: green.withAlpha(64)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TOTAL AMOUNT',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${_total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Switch(
                          value: _paymentReceived,
                          onChanged: (v) =>
                              setState(() => _paymentReceived = v),
                          activeColor: green,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                        Text(
                          'PAYMENT RECEIVED',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _paymentReceived ? green : Colors.grey,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _Numpad(onKey: _keyTap),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: GestureDetector(
                onTapDown: (_) => setState(() => _addPressed = true),
                onTapUp: (_) {
                  setState(() => _addPressed = false);
                  Navigator.pop(context);
                },
                onTapCancel: () => setState(() => _addPressed = false),
                child: AnimatedScale(
                  scale: _addPressed ? 0.96 : 1.0,
                  duration: const Duration(milliseconds: 80),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 80),
                    height: 56,
                    decoration: BoxDecoration(
                      color: _addPressed ? const Color(0xFF25A835) : green,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: _addPressed
                          ? []
                          : [
                              BoxShadow(
                                color: green.withAlpha(102),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 22),
                        SizedBox(width: 10),
                        Text(
                          'ADD SALE',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Numpad extends StatefulWidget {
  final ValueChanged<String> onKey;

  const _Numpad({required this.onKey});

  @override
  State<_Numpad> createState() => _NumpadState();
}

class _NumpadState extends State<_Numpad> {
  String? _pressedKey;

  @override
  Widget build(BuildContext context) {
    const keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['.', '0', '\u232b'],
    ];

    return Column(
      children: keys.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: row.map((key) {
              final isBackspace = key == '\u232b';
              final isPressed = _pressedKey == key;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTapDown: (_) => setState(() => _pressedKey = key),
                    onTapUp: (_) {
                      setState(() => _pressedKey = null);
                      widget.onKey(key);
                    },
                    onTapCancel: () => setState(() => _pressedKey = null),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 70),
                      height: 52,
                      decoration: BoxDecoration(
                        color: isBackspace
                            ? (isPressed
                                  ? Colors.grey.shade600
                                  : Colors.grey.shade800)
                            : (isPressed
                                  ? Colors.grey.shade300
                                  : Colors.grey.shade100),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: isBackspace
                          ? const Icon(
                              Icons.backspace_outlined,
                              color: Colors.white,
                              size: 20,
                            )
                          : Text(
                              key,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
