import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mobile/injection_container.dart' as di;
import '../manager/bloc/dashboard_bloc.dart';
import '../manager/bloc/dashboard_event.dart';
import '../manager/bloc/dashboard_state.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DashboardBloc(
        calculateProfitUseCase: di.sl(),
        getSalesReportUseCase: di.sl(),
        getExpenseReportUseCase: di.sl(),
        getLowStockAlertsUseCase: di.sl(),
        getOutOfStockAlertsUseCase: di.sl(),
      )..add(LoadDashboardDataEvent('default_business_id')),
      child: const _DashboardContent(),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  static const primary = Color(0xFF1765FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              int alertCount = 0;
              if (state is DashboardLoadedState) {
                alertCount =
                    state.lowStockProducts.length +
                    state.outOfStockProducts.length;
              }
              return IconButton(
                icon: Badge(
                  label: Text('$alertCount'),
                  isLabelVisible: alertCount > 0,
                  child: const Icon(Icons.notifications_outlined),
                ),
                onPressed: () {
                  if (state is DashboardLoadedState) {
                    _showLowStockPopup(context, state);
                  }
                },
              );
            },
          ),
        ],
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DashboardLoadedState) {
            return _DashboardBody(state: state);
          }

          if (state is DashboardErrorState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<DashboardBloc>().add(
                        LoadDashboardDataEvent('default_business_id'),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('Loading...'));
        },
      ),
    );
  }

  void _showLowStockPopup(BuildContext context, DashboardLoadedState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Stock Alerts',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(26),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${state.lowStockProducts.length + state.outOfStockProducts.length} alerts',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  if (state.outOfStockProducts.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.only(top: 16, bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'OUT OF STOCK',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...state.outOfStockProducts.map(
                      (product) => _buildAlertItem(
                        context,
                        icon: Icons.warning_amber_rounded,
                        iconColor: Colors.red,
                        iconBgColor: Colors.red.withAlpha(26),
                        title: product.name,
                        subtitle: 'Tap to restock',
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                  if (state.lowStockProducts.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.only(top: 16, bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            color: Colors.orange,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'LOW STOCK',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...state.lowStockProducts.map(
                      (product) => _buildAlertItem(
                        context,
                        icon: Icons.inventory_2_outlined,
                        iconColor: Colors.orange,
                        iconBgColor: Colors.orange.withAlpha(26),
                        title: product.name,
                        subtitle: 'Only ${product.stockQuantity} left',
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                  if (state.outOfStockProducts.isEmpty &&
                      state.lowStockProducts.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: Colors.green,
                            size: 64,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'All products are well stocked!',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  final DashboardLoadedState state;

  const _DashboardBody({required this.state});

  static const primary = Color(0xFF1765FF);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<DashboardBloc>().add(
          RefreshDashboardEvent('default_business_id'),
        );
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TotalSalesCard(
              totalSales: state.profitSummary.totalSales,
              salesChange: state.salesChange,
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'Expenses',
                    value: state.profitSummary.totalExpenses,
                    subtitle: '${state.selectedPeriod} total',
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _MetricCard(
                    title: 'Net Profit',
                    value: state.profitSummary.profit,
                    subtitle: state.profitSummary.isProfit
                        ? 'Healthy margin'
                        : 'Loss',
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            _InventoryAlertsCard(
              lowStockProducts: state.lowStockProducts,
              outOfStockProducts: state.outOfStockProducts,
            ),

            const SizedBox(height: 24),

            _RecentActivityCard(activities: state.recentActivity),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _TotalSalesCard extends StatelessWidget {
  final double totalSales;
  final double salesChange;

  const _TotalSalesCard({required this.totalSales, required this.salesChange});

  static const primary = Color(0xFF1765FF);

  @override
  Widget build(BuildContext context) {
    final isPositive = salesChange >= 0;
    final changeText = isPositive
        ? '+${salesChange.toStringAsFixed(0)}%'
        : '${salesChange.toStringAsFixed(0)}%';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Sales',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: (isPositive ? Colors.green : Colors.red).withAlpha(26),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? Icons.trending_up : Icons.trending_down,
                      size: 14,
                      color: isPositive ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      changeText,
                      style: TextStyle(
                        color: isPositive ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '\$${totalSales.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              value: 0.65,
              backgroundColor: Color(0xFFE2E8F0),
              color: primary,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final double value;
  final String subtitle;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(
            '\$${value.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }
}

class _InventoryAlertsCard extends StatelessWidget {
  final List<dynamic> lowStockProducts;
  final List<dynamic> outOfStockProducts;

  const _InventoryAlertsCard({
    required this.lowStockProducts,
    required this.outOfStockProducts,
  });

  @override
  Widget build(BuildContext context) {
    final totalAlerts = lowStockProducts.length + outOfStockProducts.length;

    if (totalAlerts == 0) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Inventory Alerts',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha(26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'All Good!',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 20),
                SizedBox(width: 8),
                Text(
                  'All products are well stocked',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Inventory Alerts',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$totalAlerts Alert${totalAlerts > 1 ? 's' : ''}',
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (outOfStockProducts.isNotEmpty) ...[
            for (final product in outOfStockProducts.take(3))
              _AlertTile(
                icon: Icons.warning_amber_rounded,
                iconColor: Colors.red,
                iconBgColor: Colors.red.withAlpha(26),
                title: product.name,
                subtitle: 'Out of stock',
              ),
          ],
          if (lowStockProducts.isNotEmpty) ...[
            for (final product in lowStockProducts.take(3))
              _AlertTile(
                icon: Icons.inventory_2_outlined,
                iconColor: Colors.orange,
                iconBgColor: Colors.orange.withAlpha(26),
                title: product.name,
                subtitle: 'Low stock: ${product.stockQuantity} left',
              ),
          ],
        ],
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;

  const _AlertTile({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}

class _RecentActivityCard extends StatelessWidget {
  final List<ActivityItem> activities;

  const _RecentActivityCard({required this.activities});

  static const primary = Color(0xFF1765FF);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Activity',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'See All',
                  style: TextStyle(color: Color(0xFF1765FF)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (activities.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No recent activity',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...activities.map((activity) {
              IconData icon;
              Color color;
              switch (activity.type) {
                case ActivityType.sale:
                  icon = Icons.shopping_cart;
                  color = Colors.green;
                  break;
                case ActivityType.expense:
                  icon = Icons.receipt_long;
                  color = Colors.red;
                  break;
                case ActivityType.inventory:
                  icon = Icons.inventory;
                  color = primary;
                  break;
              }
              return Column(
                children: [
                  _ActivityTile(
                    icon: icon,
                    color: color,
                    title: activity.title,
                    time: _formatTime(activity.timestamp),
                    amount: activity.isPositive
                        ? '+\$${activity.amount.toStringAsFixed(2)}'
                        : '-\$${activity.amount.toStringAsFixed(2)}',
                    isPositive: activity.isPositive,
                  ),
                  if (activities.last != activity) const Divider(),
                ],
              );
            }),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 60) {
      return 'Today, ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays < 1) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM d').format(dt);
    }
  }
}

class _ActivityTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String time;
  final String amount;
  final bool isPositive;

  const _ActivityTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.time,
    required this.amount,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  time,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isPositive ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
