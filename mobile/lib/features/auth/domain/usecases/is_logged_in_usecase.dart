import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';

class IsLoggedInUseCase implements UseCase<bool, NoParams> {
  final AuthRepository repository;

  IsLoggedInUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await repository.isLoggedIn();
  }
}
