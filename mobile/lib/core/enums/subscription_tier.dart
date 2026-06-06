enum SubscriptionTier {
  free,
  basic,
  premium;

  String get displayName {
    switch (this) {
      case SubscriptionTier.free:
        return 'Free';
      case SubscriptionTier.basic:
        return 'Basic';
      case SubscriptionTier.premium:
        return 'Premium';
    }
  }

  static SubscriptionTier fromString(String value) {
    return SubscriptionTier.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => SubscriptionTier.free,
    );
  }
}
