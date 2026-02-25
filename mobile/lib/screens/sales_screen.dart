import 'package:flutter/material.dart';

import '../models/sales.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  int _selectedTab = 0;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  static const primary = Color(0xFF1765FF);

  final List<SaleGroup> _allGroups = const [
    SaleGroup(
      label: 'TODAY, OCT 24',
      total: 245.50,
      sales: [
        Sale(
          icon: Icons.coffee,
          iconBg: Color(0xFFEEF3FF),
          iconColor: primary,
          title: 'Organic Coffee Bean',
          subtitle: '2 units • 09:45 AM',
          amount: 36.00,
          isReturn: false,
        ),
        Sale(
          icon: Icons.description_outlined,
          iconBg: Color(0xFFEEF3FF),
          iconColor: primary,
          title: 'Paper Filters (100pk)',
          subtitle: '5 units • 10:12 AM',
          amount: 15.50,
          isReturn: false,
        ),
        Sale(
          icon: Icons.restaurant,
          iconBg: Color(0xFFEEF3FF),
          iconColor: primary,
          title: 'Artisan Croissant',
          subtitle: '12 units • 11:30 AM',
          amount: 54.00,
          isReturn: false,
        ),
      ],
    ),
    SaleGroup(
      label: 'YESTERDAY, OCT 23',
      total: 890.00,
      sales: [
        Sale(
          icon: Icons.inventory_2_outlined,
          iconBg: Color(0xFFEEF3FF),
          iconColor: primary,
          title: 'Bulk Espresso Blend',
          subtitle: '10 units • 04:20 PM',
          amount: 140.00,
          isReturn: false,
        ),
        Sale(
          icon: Icons.replay,
          iconBg: Color(0xFFFFEEEE),
          iconColor: Colors.red,
          title: 'Return: Ceramic Mug',
          subtitle: '1 unit • 02:15 PM',
          amount: -12.00,
          isReturn: true,
        ),
      ],
    ),
  ];

  List<SaleGroup> get _filteredGroups {
    if (_searchQuery.isEmpty) return _allGroups;
    return _allGroups.map((g) {
      final filteredSales = g.sales.where((s) => s.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
      return SaleGroup(label: g.label, total: g.total, sales: filteredSales);
    }).where((g) => g.sales.isNotEmpty).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  const Text('Sales History', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                  _AddButton(
                    onTap: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const _QuickAddSaleSheet(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _SummaryCard(),
            ),

            const SizedBox(height: 18),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _TabRow(selected: _selectedTab, onTap: (i) => setState(() => _selectedTab = i)),
            ),

            const SizedBox(height: 14),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search product or ID...',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 20),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
                    borderSide: const BorderSide(color: primary, width: 1.5),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  for (final group in _filteredGroups) ...[
                    _GroupHeader(label: group.label, total: group.total),
                    const SizedBox(height: 8),
                    _GroupCard(sales: group.sales),
                    const SizedBox(height: 18),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  static const primary = Color(0xFF1765FF);

  const _SummaryCard();

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
          BoxShadow(color: primary.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(Icons.trending_up, size: 100, color: Colors.white.withOpacity(0.08)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Revenue', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
              const SizedBox(height: 6),
              const Text(r'$69,420.67', style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
              const SizedBox(height: 16),
              Row(
                children: [
                  _StatChip(label: 'TRANSACTIONS', value: '420'),
                  const SizedBox(width: 32),
                  _StatChip(label: 'AVERAGE SALE', value: r'$33.95'),
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
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 10, letterSpacing: 0.5)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
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
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey, letterSpacing: 0.4)),
        Text(
          '\$${total.toStringAsFixed(2)} Total',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1765FF)),
        ),
      ],
    );
  }
}

class _GroupCard extends StatelessWidget {
  final List<Sale> sales;

  const _GroupCard({required this.sales});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        children: List.generate(sales.length, (i) {
          final sale = sales[i];
          return Column(
            children: [
              _SaleTile(sale: sale),
              if (i < sales.length - 1)
                Divider(height: 1, indent: 68, endIndent: 16, color: Colors.grey.shade100),
            ],
          );
        }),
      ),
    );
  }
}

class _SaleTile extends StatelessWidget {
  final Sale sale;

  const _SaleTile({required this.sale});

  @override
  Widget build(BuildContext context) {
    final amountColor = sale.isReturn ? Colors.red : const Color(0xFF1765FF);
    final amountText = sale.isReturn
        ? '-\$${sale.amount.abs().toStringAsFixed(2)}'
        : '+\$${sale.amount.toStringAsFixed(2)}';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(color: sale.iconBg, borderRadius: BorderRadius.circular(12)),
        child: Icon(sale.icon, color: sale.iconColor, size: 22),
      ),
      title: Text(sale.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text(sale.subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
      trailing: Text(
        amountText,
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: amountColor),
      ),
    );
  }
}

class _AddButton extends StatefulWidget {
  final VoidCallback onTap;

  const _AddButton({required this.onTap});

  @override
  State<_AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<_AddButton> with SingleTickerProviderStateMixin {
  static const primary = Color(0xFF1765FF);
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: primary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: primary.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 22),
        ),
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
      if (key == '⌫') {
        _quantity = _quantity.length > 1 ? _quantity.substring(0, _quantity.length - 1) : '0';
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
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Quick Add Sale', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                      child: const Icon(Icons.close, size: 18, color: Colors.black54),
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
                  const Text('PRODUCT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey, letterSpacing: 0.8)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _productSearchController,
                    decoration: InputDecoration(
                      hintText: 'Search product or SKU...',
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 20),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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
                        borderSide: const BorderSide(color: primary, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _Chip(label: 'In Stock: 42 units', color: green),
                      const SizedBox(width: 8),
                      _Chip(label: 'SKU: CB-001', color: Colors.grey),
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
                        const Text('QUANTITY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey, letterSpacing: 0.8)),
                        const SizedBox(height: 8),
                        Container(
                          height: 64,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: green, width: 2),
                          ),
                          child: Text(_quantity, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('UNIT PRICE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey, letterSpacing: 0.8)),
                        const SizedBox(height: 8),
                        Container(
                          height: 64,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Text('\$${_unitPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
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
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FBF0),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: green.withOpacity(0.25)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('TOTAL AMOUNT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey, letterSpacing: 0.5)),
                        const SizedBox(height: 4),
                        Text('\$${_total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Switch(
                          value: _paymentReceived,
                          onChanged: (v) => setState(() => _paymentReceived = v),
                          activeColor: green,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                          : [BoxShadow(color: green.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 22),
                        SizedBox(width: 10),
                        Text('ADD SALE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1, color: Colors.white)),
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
      ['.', '0', '⌫'],
    ];

    return Column(
      children: keys.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: row.map((key) {
              final isBackspace = key == '⌫';
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
                            ? (isPressed ? Colors.grey.shade600 : Colors.grey.shade800)
                            : (isPressed ? Colors.grey.shade300 : Colors.grey.shade100),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: isBackspace
                          ? const Icon(Icons.backspace_outlined, color: Colors.white, size: 20)
                          : Text(key, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
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
  Widget build(BuildContext context){
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
    );
  }
}
