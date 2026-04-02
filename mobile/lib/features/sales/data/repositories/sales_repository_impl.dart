import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/exceptions.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/value_objects/date_range.dart';
import 'package:mobile/core/value_objects/profit_summary.dart';
import 'package:mobile/features/expenses/data/datasources/expense_local_datasource.dart';
import 'package:mobile/features/sales/data/datasources/sales_local_datasource.dart';
import 'package:mobile/features/sales/data/datasources/sales_remote_datasource.dart';
import 'package:mobile/features/sales/data/models/mappers/sale_mapper.dart';
import 'package:mobile/features/sales/domain/entities/sale.dart';
import 'package:mobile/features/sales/domain/repositories/sales_repository.dart';

class SalesRepositoryImpl implements SalesRepository {
  final SalesLocalDataSource salesLocalDataSource;
  final SalesRemoteDataSource salesRemoteDataSource;
  final ExpenseLocalDataSource expenseLocalDataSource;

  SalesRepositoryImpl({
    required this.salesLocalDataSource,
    required this.salesRemoteDataSource,
    required this.expenseLocalDataSource,
  });

  @override
  Future<Either<Failure, List<Sale>>> getSales(String businessId) async {
    try {
      final sales = await salesLocalDataSource.getSales(businessId);
      return Right(sales.map((m) => SaleMapper.toEntity(m)).toList());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Sale>> addSale(Sale sale) async {
    try {
      final model = SaleMapper.toModel(sale, isSynced: false);
      await salesLocalDataSource.saveSale(model);

      try {
        final saleData = SaleMapper.toJson(model);
        final response = await salesRemoteDataSource.createSale(saleData);
        final syncedModel = SaleMapper.fromJson(response);
        await salesLocalDataSource.saveSale(syncedModel);
        return Right(SaleMapper.toEntity(syncedModel));
      } on NetworkException {
        return Right(sale);
      }
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Sale>> updateSale(Sale sale) async {
    try {
      final model = SaleMapper.toModel(sale, isSynced: false);
      await salesLocalDataSource.saveSale(model);

      try {
        final saleData = SaleMapper.toJson(model);
        final response = await salesRemoteDataSource.updateSale(saleData);
        final syncedModel = SaleMapper.fromJson(response);
        await salesLocalDataSource.saveSale(syncedModel);
        return Right(SaleMapper.toEntity(syncedModel));
      } on NetworkException {
        return Right(sale);
      }
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSale(String saleId) async {
    try {
      await salesLocalDataSource.deleteSale(saleId);

      try {
        await salesRemoteDataSource.deleteSale(saleId);
      } on NetworkException {
        // Already deleted locally
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> voidSale(String saleId) async {
    try {
      final sale = await salesLocalDataSource.getSale(saleId);
      if (sale == null) {
        return const Left(NotFoundFailure('Sale not found'));
      }

      final voidedSale = sale
        ..isVoided = true
        ..isSynced = false;

      await salesLocalDataSource.saveSale(voidedSale);

      try {
        final saleData = SaleMapper.toJson(voidedSale);
        final response = await salesRemoteDataSource.updateSale(saleData);
        final syncedModel = SaleMapper.fromJson(response);
        await salesLocalDataSource.saveSale(syncedModel);
      } on NetworkException {
        // Already voided locally
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Sale>>> getSalesByDateRange(
    String businessId,
    DateRange dateRange,
  ) async {
    try {
      final sales = await salesLocalDataSource.getSalesByDateRange(
        businessId,
        dateRange.from,
        dateRange.to,
      );
      return Right(sales.map((m) => SaleMapper.toEntity(m)).toList());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getTotalSalesByDateRange(
    String businessId,
    DateRange dateRange,
  ) async {
    final result = await getSalesByDateRange(businessId, dateRange);
    return result.fold(
      (failure) => Left(failure),
      (sales) => Right(sales.fold(0.0, (sum, sale) => sum + sale.total)),
    );
  }

  @override
  Future<Either<Failure, ProfitSummary>> getProfitSummary(
    String businessId,
    DateRange dateRange,
  ) async {
    final salesResult = await getTotalSalesByDateRange(businessId, dateRange);
    final expensesResult = await _getTotalExpensesByDateRange(
      businessId,
      dateRange,
    );

    return salesResult.fold(
      (failure) => Left(failure),
      (totalSales) =>
          expensesResult.fold((failure) => Left(failure), (totalExpenses) {
            final profit = totalSales - totalExpenses;
            return Right(
              ProfitSummary(
                totalSales: totalSales,
                totalExpenses: totalExpenses,
                profit: profit,
                startDate: dateRange.from,
                endDate: dateRange.to,
              ),
            );
          }),
    );
  }

  Future<Either<Failure, double>> _getTotalExpensesByDateRange(
    String businessId,
    DateRange dateRange,
  ) async {
    try {
      final expenses = await expenseLocalDataSource.getExpensesByDateRange(
        businessId,
        dateRange.from,
        dateRange.to,
      );
      final total = expenses.fold(0.0, (sum, expense) => sum + expense.amount);
      return Right(total);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
