import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/features/auth/domain/entities/user.dart';
import 'package:mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile/features/auth/domain/usecases/update_profile_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late UpdateProfileUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = UpdateProfileUseCase(mockRepository);
  });

  const tUserId = '1';
  const tName = 'Updated Name';
  const tPhone = '+9876543210';
  final tUpdatedUser = User(
    id: '1',
    phone: '+9876543210',
    email: 'test@example.com',
    name: 'Updated Name',
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 2),
  );

  group('UpdateProfileUseCase', () {
    test(
      'should return updated user when profile update is successful',
      () async {
        when(
          () => mockRepository.updateProfile(
            userId: tUserId,
            name: tName,
            phone: tPhone,
            email: any(named: 'email'),
          ),
        ).thenAnswer((_) async => Right(tUpdatedUser));

        final result = await useCase(
          const UpdateProfileParams(
            userId: tUserId,
            name: tName,
            phone: tPhone,
          ),
        );

        expect(result, Right(tUpdatedUser));
        verify(
          () => mockRepository.updateProfile(
            userId: tUserId,
            name: tName,
            phone: tPhone,
            email: any(named: 'email'),
          ),
        ).called(1);
      },
    );

    test('should return CacheFailure when user not found', () async {
      const failure = CacheFailure('User not found');
      when(
        () => mockRepository.updateProfile(
          userId: tUserId,
          name: tName,
          phone: tPhone,
          email: any(named: 'email'),
        ),
      ).thenAnswer((_) async => const Left(failure));

      final result = await useCase(
        const UpdateProfileParams(userId: tUserId, name: tName, phone: tPhone),
      );

      expect(result, const Left(failure));
    });
  });
}
