import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/routes/app_routes.dart';
import 'feature/presentation/manager/bloc/inventory_bloc.dart';
import 'feature/presentation/manager/bloc/inventory_event.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        // we create the bloc and trigger the initial load event
        BlocProvider<InventoryBloc>(
          create: (context) => InventoryBloc()..add(LoadInventoryEvent()),
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
      title: 'Shop Ops',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF1E5EFE),
        textTheme: GoogleFonts.manropeTextTheme(
          Theme.of(context).textTheme,
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: AppRoutes.initialRoute,
      routes: AppRoutes.getRoutes(),
    );
  }
}