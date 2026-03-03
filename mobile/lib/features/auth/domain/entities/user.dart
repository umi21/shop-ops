import 'package:equatable/equatable.dart';

class User extends Equatable{
  final String? id;
  final String? phone;
  final String? email;
  final String? passwordHash;
  final String? name;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    this.id,
    this.phone,
    this.email,
    this.passwordHash,
    this.name,
    this.createdAt,
    this.updatedAt
  });
  
  @override
  List<Object?> get props {
    return [
      id,
      phone,
      email,
      passwordHash,
      name,
      createdAt,
      updatedAt
    ];
  }

}