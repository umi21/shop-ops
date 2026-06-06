import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/sales/domain/entities/sale.dart';
import 'package:mobile/features/sales/domain/repositories/sales_repository.dart';

class AddSaleUseCase implements UseCase<Sale, AddSaleParams> {
  final SalesRepository repository;

  AddSaleUseCase(this.repository);

  @override
  Future<Either<Failure, Sale>> call(AddSaleParams params) async {
    return await repository.addSale(params.sale);
  }
}

class AddSaleParams extends Equatable {
  final Sale sale;

  const AddSaleParams({required this.sale});

  @override
  List<Object?> get props => [sale];
}
