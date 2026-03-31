import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mobile/core/network/network_info.dart';
import 'package:mobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:mobile/features/auth/data/datasources/business_remote_datasource.dart';
import 'package:mobile/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:mobile/features/auth/data/datasources/business_local_datasource.dart';
import 'package:mobile/features/auth/data/models/mappers/user_mapper.dart';
import 'package:mobile/features/auth/data/models/mappers/business_mapper.dart';
import 'package:mobile/features/inventory/data/datasources/inventory_remote_datasource.dart';
import 'package:mobile/features/inventory/data/datasources/inventory_local_datasource.dart';
import 'package:mobile/features/inventory/data/models/mappers/product_mapper.dart';
import 'package:mobile/features/expenses/data/datasources/expense_remote_datasource.dart';
import 'package:mobile/features/expenses/data/datasources/expense_local_datasource.dart';
import 'package:mobile/features/expenses/data/models/mappers/expense_mapper.dart';
import 'package:mobile/features/sales/data/datasources/sales_remote_datasource.dart';
import 'package:mobile/features/sales/data/datasources/sales_local_datasource.dart';
import 'package:mobile/features/sales/data/models/mappers/sale_mapper.dart';

class SyncService {
  final NetworkInfo networkInfo;
  final AuthRemoteDataSource authRemoteDataSource;
  final BusinessRemoteDataSource businessRemoteDataSource;
  final InventoryRemoteDataSource inventoryRemoteDataSource;
  final ExpenseRemoteDataSource expenseRemoteDataSource;
  final SalesRemoteDataSource salesRemoteDataSource;
  final AuthLocalDataSource authLocalDataSource;
  final BusinessLocalDataSource businessLocalDataSource;
  final InventoryLocalDataSource inventoryLocalDataSource;
  final ExpenseLocalDataSource expenseLocalDataSource;
  final SalesLocalDataSource salesLocalDataSource;

  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  SyncService({
    required this.networkInfo,
    required this.authRemoteDataSource,
    required this.businessRemoteDataSource,
    required this.inventoryRemoteDataSource,
    required this.expenseRemoteDataSource,
    required this.salesRemoteDataSource,
    required this.authLocalDataSource,
    required this.businessLocalDataSource,
    required this.inventoryLocalDataSource,
    required this.expenseLocalDataSource,
    required this.salesLocalDataSource,
  });

  void startListening() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      result,
    ) async {
      if (result != ConnectivityResult.none) {
        await syncAll();
      }
    });
  }

  void stopListening() {
    _connectivitySubscription?.cancel();
  }

  Future<void> syncAll() async {
    if (!await networkInfo.isConnected) return;

    await Future.wait([
      syncUsers(),
      syncBusinesses(),
      syncProducts(),
      syncExpenses(),
      syncSales(),
    ]);
  }

  Future<void> syncUsers() async {
    try {
      final localUser = await authLocalDataSource.getUser();
      if (localUser != null && !localUser.isSynced) {
        final userData = UserMapper.toJson(localUser);
        await authRemoteDataSource.syncUser(userData);
        localUser.isSynced = true;
        localUser.syncedAt = DateTime.now();
        await authLocalDataSource.saveUser(localUser);
      }
    } catch (e) {
      // Handle sync error silently
    }
  }

  Future<void> syncBusinesses() async {
    try {
      final unsyncedBusinesses = await businessLocalDataSource
          .getUnsyncedBusinesses();
      if (unsyncedBusinesses.isNotEmpty) {
        final businessDataList = unsyncedBusinesses
            .map((b) => BusinessMapper.toJson(b))
            .toList();
        await businessRemoteDataSource.syncBusinesses(businessDataList);

        for (final business in unsyncedBusinesses) {
          business.isSynced = true;
          business.syncedAt = DateTime.now();
          await businessLocalDataSource.saveBusiness(business);
        }
      }
    } catch (e) {
      // Handle sync error silently
    }
  }

  Future<void> syncProducts() async {
    try {
      final unsyncedProducts = await inventoryLocalDataSource
          .getUnsyncedProducts();
      if (unsyncedProducts.isNotEmpty) {
        final productDataList = unsyncedProducts
            .map((p) => ProductMapper.toJson(p))
            .toList();
        final syncedProducts = await inventoryRemoteDataSource.syncProducts(
          productDataList,
        );

        for (final productData in syncedProducts) {
          final syncedModel = ProductMapper.fromJson(productData);
          await inventoryLocalDataSource.saveProduct(syncedModel);
        }
      }
    } catch (e) {
      // Handle sync error silently
    }
  }

  Future<void> syncExpenses() async {
    try {
      final unsyncedExpenses = await expenseLocalDataSource
          .getUnsyncedExpenses();
      if (unsyncedExpenses.isNotEmpty) {
        final expenseDataList = unsyncedExpenses
            .map((e) => ExpenseMapper.toJson(e))
            .toList();
        final syncedExpenses = await expenseRemoteDataSource.syncExpenses(
          expenseDataList,
        );

        for (final expenseData in syncedExpenses) {
          final syncedModel = ExpenseMapper.fromJson(expenseData);
          await expenseLocalDataSource.saveExpense(syncedModel);
        }
      }
    } catch (e) {
      // Handle sync error silently
    }
  }

  Future<void> syncSales() async {
    try {
      final unsyncedSales = await salesLocalDataSource.getUnsyncedSales();
      if (unsyncedSales.isNotEmpty) {
        final saleDataList = unsyncedSales
            .map((s) => SaleMapper.toJson(s))
            .toList();
        final syncedSales = await salesRemoteDataSource.syncSales(saleDataList);

        for (final saleData in syncedSales) {
          final syncedModel = SaleMapper.fromJson(saleData);
          await salesLocalDataSource.saveSale(syncedModel);
        }
      }
    } catch (e) {
      // Handle sync error silently
    }
  }

  Future<void> triggerSync() async {
    await syncAll();
  }
}
