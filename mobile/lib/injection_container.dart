import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/network/network_info.dart';
import 'package:mobile/shared/database/database_init.dart';

import 'package:mobile/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:mobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:mobile/features/auth/data/datasources/business_local_datasource.dart';
import 'package:mobile/features/auth/data/datasources/business_remote_datasource.dart';
import 'package:mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mobile/features/auth/data/repositories/business_repository_impl.dart';
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile/features/auth/domain/repositories/business_repository.dart';
import 'package:mobile/features/auth/domain/usecases/login_usecase.dart';
import 'package:mobile/features/auth/domain/usecases/logout_usecase.dart';
import 'package:mobile/features/auth/domain/usecases/register_usecase.dart';
import 'package:mobile/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:mobile/features/auth/domain/usecases/update_business_usecase.dart';
import 'package:mobile/features/auth/domain/usecases/get_business_usecase.dart';
import 'package:mobile/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:mobile/features/auth/domain/usecases/create_business_usecase.dart';
import 'package:mobile/features/auth/domain/usecases/is_logged_in_usecase.dart';

import 'package:mobile/features/inventory/data/datasources/inventory_local_datasource.dart';
import 'package:mobile/features/inventory/data/datasources/inventory_remote_datasource.dart';
import 'package:mobile/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:mobile/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:mobile/features/inventory/domain/usecases/add_product_usecase.dart';
import 'package:mobile/features/inventory/domain/usecases/update_product_usecase.dart';
import 'package:mobile/features/inventory/domain/usecases/delete_product_usecase.dart';
import 'package:mobile/features/inventory/domain/usecases/get_products_usecase.dart';
import 'package:mobile/features/inventory/domain/usecases/get_product_detail_usecase.dart';
import 'package:mobile/features/inventory/domain/usecases/get_low_stock_alerts_usecase.dart';
import 'package:mobile/features/inventory/domain/usecases/get_out_of_stock_alerts_usecase.dart';
import 'package:mobile/features/inventory/domain/usecases/adjust_stock_usecase.dart';

import 'package:mobile/features/expenses/data/datasources/expense_local_datasource.dart';
import 'package:mobile/features/expenses/data/datasources/expense_remote_datasource.dart';
import 'package:mobile/features/expenses/data/repositories/expense_repository_impl.dart';
import 'package:mobile/features/expenses/domain/repositories/expense_repository.dart';
import 'package:mobile/features/expenses/domain/usecases/add_expense_usecase.dart';
import 'package:mobile/features/expenses/domain/usecases/get_expenses_usecase.dart';
import 'package:mobile/features/expenses/domain/usecases/get_expense_report_usecase.dart';
import 'package:mobile/features/expenses/domain/usecases/update_expense_usecase.dart';
import 'package:mobile/features/expenses/domain/usecases/delete_expense_usecase.dart';

import 'package:mobile/features/sales/data/datasources/sales_local_datasource.dart';
import 'package:mobile/features/sales/data/datasources/sales_remote_datasource.dart';
import 'package:mobile/features/sales/data/repositories/sales_repository_impl.dart';
import 'package:mobile/features/sales/domain/repositories/sales_repository.dart';
import 'package:mobile/features/sales/domain/usecases/add_sale_usecase.dart';
import 'package:mobile/features/sales/domain/usecases/get_sales_usecase.dart';
import 'package:mobile/features/sales/domain/usecases/get_sales_report_usecase.dart';
import 'package:mobile/features/sales/domain/usecases/calculate_profit_usecase.dart';
import 'package:mobile/features/sales/domain/usecases/void_sale_usecase.dart';

import 'package:mobile/shared/sync/sync_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  final isar = await DatabaseInit.init();

  sl.registerLazySingleton<Isar>(() => isar);
  sl.registerLazySingleton<ApiClient>(() => ApiClient());
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<Uuid>(() => const Uuid());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // Auth
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<BusinessLocalDataSource>(
    () => BusinessLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<BusinessRemoteDataSource>(
    () => BusinessRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      uuid: sl(),
    ),
  );
  sl.registerLazySingleton<BusinessRepository>(
    () => BusinessRepositoryImpl(localDataSource: sl(), remoteDataSource: sl()),
  );

  // Auth Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateBusinessUseCase(sl()));
  sl.registerLazySingleton(() => GetBusinessUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => CreateBusinessUseCase(sl()));
  sl.registerLazySingleton(() => IsLoggedInUseCase(sl()));

  // Inventory
  sl.registerLazySingleton<InventoryLocalDataSource>(
    () => InventoryLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<InventoryRemoteDataSource>(
    () => InventoryRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<InventoryRepository>(
    () =>
        InventoryRepositoryImpl(localDataSource: sl(), remoteDataSource: sl()),
  );

  // Inventory Use Cases
  sl.registerLazySingleton(() => AddProductUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProductUseCase(sl()));
  sl.registerLazySingleton(() => DeleteProductUseCase(sl()));
  sl.registerLazySingleton(() => GetProductsUseCase(sl()));
  sl.registerLazySingleton(() => GetProductDetailUseCase(sl()));
  sl.registerLazySingleton(() => GetLowStockAlertsUseCase(sl()));
  sl.registerLazySingleton(() => GetOutOfStockAlertsUseCase(sl()));
  sl.registerLazySingleton(() => AdjustStockUseCase(sl()));

  // Expenses
  sl.registerLazySingleton<ExpenseLocalDataSource>(
    () => ExpenseLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ExpenseRemoteDataSource>(
    () => ExpenseRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ExpenseRepository>(
    () => ExpenseRepositoryImpl(localDataSource: sl(), remoteDataSource: sl()),
  );

  // Expense Use Cases
  sl.registerLazySingleton(() => AddExpenseUseCase(sl()));
  sl.registerLazySingleton(() => GetExpensesUseCase(sl()));
  sl.registerLazySingleton(() => GetExpenseReportUseCase(sl()));
  sl.registerLazySingleton(() => UpdateExpenseUseCase(sl()));
  sl.registerLazySingleton(() => DeleteExpenseUseCase(sl()));

  // Sales
  sl.registerLazySingleton<SalesLocalDataSource>(
    () => SalesLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<SalesRemoteDataSource>(
    () => SalesRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<SalesRepository>(
    () => SalesRepositoryImpl(
      salesLocalDataSource: sl(),
      salesRemoteDataSource: sl(),
      expenseLocalDataSource: sl(),
    ),
  );

  // Sales Use Cases
  sl.registerLazySingleton(() => AddSaleUseCase(sl()));
  sl.registerLazySingleton(() => GetSalesUseCase(sl()));
  sl.registerLazySingleton(() => GetSalesReportUseCase(sl()));
  sl.registerLazySingleton(() => CalculateProfitUseCase(sl()));
  sl.registerLazySingleton(() => VoidSaleUseCase(sl()));

  // Sync Service
  sl.registerLazySingleton(
    () => SyncService(
      networkInfo: sl(),
      authRemoteDataSource: sl(),
      businessRemoteDataSource: sl(),
      inventoryRemoteDataSource: sl(),
      expenseRemoteDataSource: sl(),
      salesRemoteDataSource: sl(),
      authLocalDataSource: sl(),
      businessLocalDataSource: sl(),
      inventoryLocalDataSource: sl(),
      expenseLocalDataSource: sl(),
      salesLocalDataSource: sl(),
    ),
  );
}
