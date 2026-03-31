import 'package:equatable/equatable.dart';
import 'package:mobile/core/enums/subscription_tier.dart';

class Business extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String currency;
  final String language;
  final SubscriptionTier tier;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Business({
    required this.id,
    required this.userId,
    required this.name,
    required this.currency,
    required this.language,
    required this.tier,
    required this.createdAt,
    required this.updatedAt,
  });

  Business copyWith({
    String? id,
    String? userId,
    String? name,
    String? currency,
    String? language,
    SubscriptionTier? tier,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Business(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      currency: currency ?? this.currency,
      language: language ?? this.language,
      tier: tier ?? this.tier,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    currency,
    language,
    tier,
    createdAt,
    updatedAt,
  ];
}
