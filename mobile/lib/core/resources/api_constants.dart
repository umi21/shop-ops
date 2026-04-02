// Placeholder API endpoints 

class ApiConstants {
  static const String baseUrl = 'https://shopops-backend-production.up.railway.app';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Auth endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String profileEndpoint = '/auth/profile';

  // Business endpoints
  static const String businessEndpoint = '/business';

  // Inventory endpoints
  static const String productsEndpoint = '/inventory/products';

  // Expenses endpoints
  static const String expensesEndpoint = '/expenses';

  // Sales endpoints
  static const String salesEndpoint = '/sales';

  // Sync endpoint
  static const String syncEndpoint = '/sync';
}
