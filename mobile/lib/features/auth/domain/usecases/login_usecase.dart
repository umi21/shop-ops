import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/features/auth/domain/entities/user.dart';
import 'package:mobile/features/auth/domain/repository/user_repository.dart';

class LoginUsecase {
  final UserRepository userRepository;

  LoginUsecase(this.userRepository);

  Future<Either<Failure, User>> call(LoginParams params) async {
    //TODO: Auth steps
    
    return await userRepository.login(params.email, params.password);
  }
}


class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}