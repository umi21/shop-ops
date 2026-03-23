import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/exceptions.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:mobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:mobile/features/auth/data/models/mappers/user_mapper.dart';
import 'package:mobile/features/auth/domain/entities/user.dart';
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:uuid/uuid.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;
  final AuthRemoteDataSource remoteDataSource;
  final Uuid uuid;

  AuthRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.uuid,
  });

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final localUser = await localDataSource.getUser();

      if (localUser != null && localUser.email == email) {
        return Right(UserMapper.toEntity(localUser));
      }

      final response = await remoteDataSource.login(email, password);
      final userModel = UserMapper.fromJson(response['user']);
      await localDataSource.saveUser(userModel);
      return Right(UserMapper.toEntity(userModel));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      final response = await remoteDataSource.register(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );

      final userModel = UserMapper.fromJson(response['user']);
      await localDataSource.saveUser(userModel);
      return Right(UserMapper.toEntity(userModel));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      final now = DateTime.now();
      final tempId = uuid.v4();
      final tempUser = User(
        id: tempId,
        email: email,
        phone: phone,
        name: name,
        createdAt: now,
        updatedAt: now,
      );
      final userModel = UserMapper.toModel(tempUser, isSynced: false);
      await localDataSource.saveUser(userModel);
      return Right(tempUser);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> logout() async {
    try {
      final currentUser = await localDataSource.getUser();
      if (currentUser != null) {
        await localDataSource.deleteUser();
        return Right(UserMapper.toEntity(currentUser));
      }
      return const Left(CacheFailure('No user to logout'));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile({
    required String userId,
    String? name,
    String? phone,
    String? email,
  }) async {
    try {
      final localUser = await localDataSource.getUser();
      if (localUser == null) {
        return const Left(CacheFailure('User not found'));
      }

      final updatedUser = localUser
        ..name = name ?? localUser.name
        ..phone = phone ?? localUser.phone
        ..email = email ?? localUser.email
        ..updatedAt = DateTime.now()
        ..isSynced = false;

      await localDataSource.saveUser(updatedUser);

      try {
        final response = await remoteDataSource.updateProfile(
          userId: userId,
          name: name,
          phone: phone,
          email: email,
        );
        final syncedModel = UserMapper.fromJson(response['user']);
        await localDataSource.saveUser(syncedModel);
        return Right(UserMapper.toEntity(syncedModel));
      } on NetworkException {
        return Right(UserMapper.toEntity(updatedUser));
      }
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final user = await localDataSource.getUser();
      if (user != null) {
        return Right(UserMapper.toEntity(user));
      }
      return const Left(NotFoundFailure('No user logged in'));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveUser(User user) async {
    try {
      final model = UserMapper.toModel(user);
      await localDataSource.saveUser(model);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final hasUser = await localDataSource.hasUser();
      return Right(hasUser);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
