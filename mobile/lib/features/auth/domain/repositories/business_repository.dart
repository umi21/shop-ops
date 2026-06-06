import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/features/auth/domain/entities/business.dart';

abstract class BusinessRepository {
  Future<Either<Failure, Business>> getBusiness(String userId);
  Future<Either<Failure, Business>> createBusiness(Business business);
  Future<Either<Failure, Business>> updateBusiness(Business business);
  Future<Either<Failure, void>> saveBusiness(Business business);
  Future<Either<Failure, Business?>> getLocalBusiness(String userId);
}
