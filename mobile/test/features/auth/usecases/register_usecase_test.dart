import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/features/auth/domain/entities/user.dart';
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile/features/auth/domain/usecases/register_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late RegisterUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = RegisterUseCase(mockRepository);
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tName = 'Test User';
  const tPhone = '+1234567890';
  final tUser = User(
    id: '1',
    phone: '+1234567890',
    email: 'test@example.com',
    name: 'Test User',
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  group('RegisterUseCase', () {
    test('should return user when registration is successful', () async {
      when(
        () => mockRepository.register(
          email: tEmail,
          password: tPassword,
          name: tName,
          phone: tPhone,
        ),
      ).thenAnswer((_) async => Right(tUser));

      final result = await useCase(
        const RegisterParams(
          email: tEmail,
          password: tPassword,
          name: tName,
          phone: tPhone,
        ),
      );

      expect(result, Right(tUser));
      verify(
        () => mockRepository.register(
          email: tEmail,
          password: tPassword,
          name: tName,
          phone: tPhone,
        ),
      ).called(1);
    });

    test('should return ServerFailure when server error occurs', () async {
      const failure = ServerFailure('Email already exists', statusCode: 400);
      when(
        () => mockRepository.register(
          email: tEmail,
          password: tPassword,
          name: tName,
          phone: tPhone,
        ),
      ).thenAnswer((_) async => const Left(failure));

      final result = await useCase(
        const RegisterParams(
          email: tEmail,
          password: tPassword,
          name: tName,
          phone: tPhone,
        ),
      );

      expect(result, const Left(failure));
    });
  });
}
