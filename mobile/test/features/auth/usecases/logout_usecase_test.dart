import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/auth/domain/entities/user.dart';
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile/features/auth/domain/usecases/logout_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LogoutUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LogoutUseCase(mockRepository);
  });

  final tUser = User(
    id: '1',
    phone: '+1234567890',
    email: 'test@example.com',
    name: 'Test User',
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  group('LogoutUseCase', () {
    test('should return user when logout is successful', () async {
      when(() => mockRepository.logout()).thenAnswer((_) async => Right(tUser));

      final result = await useCase(const NoParams());

      expect(result, Right(tUser));
      verify(() => mockRepository.logout()).called(1);
    });

    test('should return CacheFailure when no user to logout', () async {
      const failure = CacheFailure('No user to logout');
      when(
        () => mockRepository.logout(),
      ).thenAnswer((_) async => const Left(failure));

      final result = await useCase(const NoParams());

      expect(result, const Left(failure));
    });
  });
}
