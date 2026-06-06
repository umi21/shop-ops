import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/auth/domain/entities/business.dart';
import 'package:mobile/features/auth/domain/repositories/business_repository.dart';

class UpdateBusinessUseCase implements UseCase<Business, Business> {
  final BusinessRepository repository;

  UpdateBusinessUseCase(this.repository);

  @override
  Future<Either<Failure, Business>> call(Business params) async {
    return await repository.updateBusiness(params);
  }
}
