import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String phone;
  final String email;
  final String? passwordHash;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.phone,
    required this.email,
    this.passwordHash,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  User copyWith({
    String? id,
    String? phone,
    String? email,
    String? passwordHash,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    phone,
    email,
    passwordHash,
    name,
    createdAt,
    updatedAt,
  ];
}
