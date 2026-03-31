import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/auth/domain/entities/business.dart';
import 'package:mobile/features/auth/domain/repositories/business_repository.dart';

class GetBusinessUseCase implements UseCase<Business, String> {
  final BusinessRepository repository;

  GetBusinessUseCase(this.repository);

  @override
  Future<Either<Failure, Business>> call(String userId) async {
    return await repository.getBusiness(userId);
  }
}
