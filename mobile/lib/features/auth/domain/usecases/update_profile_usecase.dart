import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/auth/domain/entities/user.dart';
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';

class UpdateProfileUseCase implements UseCase<User, UpdateProfileParams> {
  final AuthRepository repository;

  UpdateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(UpdateProfileParams params) async {
    return await repository.updateProfile(
      userId: params.userId,
      name: params.name,
      phone: params.phone,
      email: params.email,
    );
  }
}

class UpdateProfileParams extends Equatable {
  final String userId;
  final String? name;
  final String? phone;
  final String? email;

  const UpdateProfileParams({
    required this.userId,
    this.name,
    this.phone,
    this.email,
  });

  @override
  List<Object?> get props => [userId, name, phone, email];
}
