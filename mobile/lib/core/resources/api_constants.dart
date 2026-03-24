class ApiConstants {
  static const String baseUrl = 'https://api.shop-ops.com';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String profileEndpoint = '/auth/profile';
  static const String businessEndpoint = '/business';

  static const String productsEndpoint = '/products';
  static const String expensesEndpoint = '/expenses';
  static const String salesEndpoint = '/sales';
  static const String syncEndpoint = '/sync';
}
