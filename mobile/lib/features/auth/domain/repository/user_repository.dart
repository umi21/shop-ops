import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/features/auth/domain/entities/user.dart';

abstract class UserRepository {
  Future<Either<Failure, User>> login(String email, String password);
}
