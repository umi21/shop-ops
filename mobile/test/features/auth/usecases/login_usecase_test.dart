import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/features/auth/domain/entities/user.dart';
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile/features/auth/domain/usecases/login_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUseCase(mockRepository);
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  final tUser = User(
    id: '1',
    phone: '+1234567890',
    email: 'test@example.com',
    name: 'Test User',
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  group('LoginUseCase', () {
    test('should return user when login is successful', () async {
      when(
        () => mockRepository.login(tEmail, tPassword),
      ).thenAnswer((_) async => Right(tUser));

      final result = await useCase(
        const LoginParams(email: tEmail, password: tPassword),
      );

      expect(result, Right(tUser));
      verify(() => mockRepository.login(tEmail, tPassword)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when server error occurs', () async {
      const failure = ServerFailure('Invalid credentials', statusCode: 401);
      when(
        () => mockRepository.login(tEmail, tPassword),
      ).thenAnswer((_) async => const Left(failure));

      final result = await useCase(
        const LoginParams(email: tEmail, password: tPassword),
      );

      expect(result, const Left(failure));
      verify(() => mockRepository.login(tEmail, tPassword)).called(1);
    });

    test('should return NetworkFailure when no internet', () async {
      const failure = NetworkFailure('No internet connection');
      when(
        () => mockRepository.login(tEmail, tPassword),
      ).thenAnswer((_) async => const Left(failure));

      final result = await useCase(
        const LoginParams(email: tEmail, password: tPassword),
      );

      expect(result, const Left(failure));
    });
  });
}
