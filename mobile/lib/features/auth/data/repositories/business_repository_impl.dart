import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/exceptions.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/features/auth/data/datasources/business_local_datasource.dart';
import 'package:mobile/features/auth/data/datasources/business_remote_datasource.dart';
import 'package:mobile/features/auth/data/models/mappers/business_mapper.dart';
import 'package:mobile/features/auth/domain/entities/business.dart';
import 'package:mobile/features/auth/domain/repositories/business_repository.dart';

class BusinessRepositoryImpl implements BusinessRepository {
  final BusinessLocalDataSource localDataSource;
  final BusinessRemoteDataSource remoteDataSource;

  BusinessRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, Business>> getBusiness(String userId) async {
    try {
      final localBusiness = await localDataSource.getBusiness(userId);
      if (localBusiness != null) {
        return Right(BusinessMapper.toEntity(localBusiness));
      }

      try {
        final response = await remoteDataSource.getBusiness(userId);
        final businessModel = BusinessMapper.fromJson(response);
        await localDataSource.saveBusiness(businessModel);
        return Right(BusinessMapper.toEntity(businessModel));
      } on NotFoundException {
        return const Left(NotFoundFailure('Business not found'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Business>> createBusiness(Business business) async {
    try {
      final businessData = BusinessMapper.toJson(
        BusinessMapper.toModel(business),
      );
      final response = await remoteDataSource.createBusiness(businessData);
      final businessModel = BusinessMapper.fromJson(response);
      await localDataSource.saveBusiness(businessModel);
      return Right(BusinessMapper.toEntity(businessModel));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      final model = BusinessMapper.toModel(business, isSynced: false);
      await localDataSource.saveBusiness(model);
      return Right(business);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Business>> updateBusiness(Business business) async {
    try {
      final updatedBusiness = business.copyWith(updatedAt: DateTime.now());
      final model = BusinessMapper.toModel(updatedBusiness, isSynced: false);
      await localDataSource.saveBusiness(model);

      try {
        final businessData = BusinessMapper.toJson(
          BusinessMapper.toModel(updatedBusiness),
        );
        final response = await remoteDataSource.updateBusiness(businessData);
        final syncedModel = BusinessMapper.fromJson(response);
        await localDataSource.saveBusiness(syncedModel);
        return Right(BusinessMapper.toEntity(syncedModel));
      } on NetworkException {
        return Right(updatedBusiness);
      }
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveBusiness(Business business) async {
    try {
      final model = BusinessMapper.toModel(business);
      await localDataSource.saveBusiness(model);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Business?>> getLocalBusiness(String userId) async {
    try {
      final business = await localDataSource.getBusiness(userId);
      if (business != null) {
        return Right(BusinessMapper.toEntity(business));
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
