import 'package:mobile/features/auth/data/models/user_model.dart';
import 'package:mobile/features/auth/domain/entities/user.dart';

class UserMapper {
  static User toEntity(UserModel model) {
    return User(
      id: model.id,
      phone: model.phone,
      email: model.email,
      passwordHash: model.passwordHash,
      name: model.name,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  static UserModel toModel(
    User entity, {
    DateTime? syncedAt,
    bool isSynced = false,
  }) {
    return UserModel()
      ..id = entity.id
      ..phone = entity.phone
      ..email = entity.email
      ..passwordHash = entity.passwordHash
      ..name = entity.name
      ..createdAt = entity.createdAt
      ..updatedAt = entity.updatedAt
      ..syncedAt = syncedAt ?? DateTime.now()
      ..isSynced = isSynced;
  }

  static Map<String, dynamic> toJson(UserModel model) {
    return {
      'id': model.id,
      'phone': model.phone,
      'email': model.email,
      'name': model.name,
      'createdAt': model.createdAt.toIso8601String(),
      'updatedAt': model.updatedAt.toIso8601String(),
    };
  }

  static UserModel fromJson(Map<String, dynamic> json) {
    return UserModel()
      ..id = json['id']
      ..phone = json['phone']
      ..email = json['email']
      ..name = json['name']
      ..createdAt = DateTime.parse(json['createdAt'])
      ..updatedAt = DateTime.parse(json['updatedAt'])
      ..syncedAt = DateTime.now()
      ..isSynced = true;
  }
}
