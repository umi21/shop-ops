import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String phone, String password);
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String name,
    required String phone,
  });
  Future<Either<Failure, User>> logout();
  Future<Either<Failure, User>> updateProfile({
    required String userId,
    String? name,
    String? phone,
    String? email,
  });
  Future<Either<Failure, User>> getCurrentUser();
  Future<Either<Failure, void>> saveUser(User user);
  Future<Either<Failure, bool>> isLoggedIn();
}
