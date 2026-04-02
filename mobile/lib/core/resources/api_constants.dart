// this one is for adding api routes fot the futute

class ApiConstants {
  static const String baseUrl = 'https://shopops-backend-production.up.railway.app';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String profileEndpoint = '/auth/profile';
  static const String businessEndpoint = '/business';

  static const String productsEndpoint = '/inventory';
  static const String expensesEndpoint = '/expenses';
  static const String salesEndpoint = '/sales';
  static const String syncEndpoint = '/sync';
}
