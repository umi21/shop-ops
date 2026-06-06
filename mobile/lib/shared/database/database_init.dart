import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mobile/features/auth/data/models/user_model.dart';
import 'package:mobile/features/auth/data/models/business_model.dart';
import 'package:mobile/features/inventory/data/models/product_model.dart';
import 'package:mobile/features/expenses/data/models/expense_model.dart';
import 'package:mobile/features/sales/data/models/sale_model.dart';

class DatabaseInit {
  static Future<Isar> init() async {
    final dir = await getApplicationDocumentsDirectory();
    return await Isar.open([
      UserModelSchema,
      BusinessModelSchema,
      ProductModelSchema,
      ExpenseModelSchema,
      SaleModelSchema,
    ], directory: dir.path);
  }
}
