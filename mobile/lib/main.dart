import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/routes/app_routes.dart';
import 'features/inventory/presentation/manager/bloc/inventory_bloc.dart';
import 'features/inventory/presentation/manager/bloc/inventory_event.dart';

import 'package:mobile/injection_container.dart' as di;
import 'package:mobile/shared/sync/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await di.init();

  final syncService = di.sl<SyncService>();
  syncService.startListening();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<InventoryBloc>(
          create: (context) => InventoryBloc(
            getProductsUseCase: di.sl(),
            addProductUseCase: di.sl(),
            updateProductUseCase: di.sl(),
            deleteProductUseCase: di.sl(),
            adjustStockUseCase: di.sl(),
          )..add(LoadInventoryEvent('default_business_id')),
        ),
      ],
      child: const ShopOpsApp(),
    ),
  );
}

class ShopOpsApp extends StatelessWidget {
  const ShopOpsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shop-Ops',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF1E5EFE),
        textTheme: GoogleFonts.manropeTextTheme(Theme.of(context).textTheme),
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: AppRoutes.initialRoute,
      routes: AppRoutes.getRoutes(),
    );
  }
}
