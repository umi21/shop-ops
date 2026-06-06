import 'package:flutter/material.dart';
import 'package:mobile/core/routes/app_routes.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/injection_container.dart' as di;
import 'package:mobile/features/auth/domain/usecases/is_logged_in_usecase.dart';
import 'dashboard_screen.dart';
import '../../../sales/presentation/Pages/sales_screen.dart';
import '../../../inventory/presentation/pages/inventory_page.dart';
import '../../../expenses/presentation/pages/expense_page.dart';
import '../../../../core/widgets/custom_bottom_nav.dart';
import '../../../settings/presentation/settings.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _isCheckingAuth = true;
  bool _isLoggedIn = false;

  static const List<Widget> _pages = <Widget>[
    DashboardScreen(),
    InventoryPage(),
    SalesScreen(),
    ExpensePage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final isLoggedIn = di.sl<IsLoggedInUseCase>();
    final result = await isLoggedIn(const NoParams());

    if (mounted) {
      setState(() {
        _isLoggedIn = result.fold((_) => false, (isLoggedIn) => isLoggedIn);
        _isCheckingAuth = false;
      });

      if (!_isLoggedIn) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.loginRoute,
            (route) => false,
          );
        });
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAuth) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_isLoggedIn) {
      return const Scaffold(
        body: Center(child: Text('Redirecting to login...')),
      );
    }

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
      ),
    );
  }
}
