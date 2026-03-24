# Shop-Ops Use Case Documentation

Documentation for UI developers on how to use the domain layer use cases.

## Table of Contents
- [Auth Feature](#auth-feature)
- [Inventory Feature](#inventory-feature)
- [Expenses Feature](#expenses-feature)
- [Sales Feature](#sales-feature)
- [Value Objects](#value-objects)

---

## Auth Feature

### Login Use Case

**Description:** Authenticates a user with phone number and password.

**Parameters:**
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `phone` | `String` | Yes | User's phone number |
| `password` | `String` | Yes | User's password |

**Returns:** `Either<Failure, User>`
- `Right(user)`: On successful login
- `Left(ServerFailure)`: Server error (invalid credentials, etc.)
- `Left(NetworkFailure)`: No internet connection
- `Left(CacheFailure)`: Local storage error

**Usage Example:**
```dart
final result = await loginUseCase(const LoginParams(
  phone: '+1234567890',
  password: 'password123',
));

result.fold(
  (failure) => print('Error: ${failure.message}'),
  (user) => print('Welcome, ${user.name}!'),
);
```

---

### Register Use Case

**Description:** Registers a new user account.

**Parameters:**
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `email` | `String` | Yes | User's email address |
| `password` | `String` | Yes | User's password |
| `name` | `String` | Yes | User's full name |
| `phone` | `String` | Yes | User's phone number |

**Returns:** `Either<Failure, User>`
- `Right(user)`: On successful registration
- `Left(ServerFailure)`: Server error (email exists, etc.)
- `Left(NetworkFailure)`: No internet (user saved locally)
- `Left(ValidationFailure)`: Invalid input

**Usage Example:**
```dart
final result = await registerUseCase(const RegisterParams(
  email: 'user@example.com',
  password: 'password123',
  name: 'John Doe',
  phone: '+1234567890',
));

result.fold(
  (failure) => print('Error: ${failure.message}'),
  (user) => print('Account created: ${user.email}'),
);
```

---

### Logout Use Case

**Description:** Logs out the current user.

**Parameters:** None (uses `NoParams`)

**Returns:** `Either<Failure, User>`
- `Right(user)`: On successful logout (returns the logged out user)
- `Left(CacheFailure)`: No user to logout

**Usage Example:**
```dart
final result = await logoutUseCase(const NoParams());

result.fold(
  (failure) => print('Error: ${failure.message}'),
  (user) => print('Logged out: ${user.name}'),
);
```

---

### Update Profile Use Case

**Description:** Updates the current user's profile information.

**Parameters:**
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `userId` | `String` | Yes | User's ID |
| `name` | `String?` | No | New name |
| `phone` | `String?` | No | New phone number |
| `email` | `String?` | No | New email |

**Returns:** `Either<Failure, User>`
- `Right(user)`: On successful update
- `Left(CacheFailure)`: User not found
- `Left(ServerFailure)`: Server error

**Usage Example:**
```dart
final result = await updateProfileUseCase(const UpdateProfileParams(
  userId: 'user123',
  name: 'Jane Doe',
  phone: '+9876543210',
));

result.fold(
  (failure) => print('Error: ${failure.message}'),
  (user) => print('Profile updated: ${user.name}'),
);
```

---

### Get Current User Use Case

**Description:** Retrieves the currently logged-in user.

**Parameters:** None (uses `NoParams`)

**Returns:** `Either<Failure, User>`
- `Right(user)`: User found
- `Left(NotFoundFailure)`: No user logged in
- `Left(CacheFailure)`: Local storage error

**Usage Example:**
```dart
final result = await getCurrentUserUseCase(const NoParams());

result.fold(
  (failure) => print('No user logged in'),
  (user) => print('Current user: ${user.name}'),
);
```

---

## Inventory Feature

### Add Product Use Case

**Description:** Adds a new product to the inventory.

**Parameters:**
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `product` | `Product` | Yes | Product entity to add |

**Product Fields:**
| Field | Type | Description |
|-------|------|-------------|
| `id` | `String` | Unique identifier |
| `businessId` | `String` | Business owner ID |
| `name` | `String` | Product name |
| `defaultSellingPrice` | `double` | Default selling price |
| `stockQuantity` | `int` | Current stock count |
| `lowStockThreshold` | `int` | Threshold for low stock alert (default: 5) |

**Returns:** `Either<Failure, Product>`

**Usage Example:**
```dart
final product = Product(
  id: 'prod_001',
  businessId: 'biz_001',
  name: 'Widget',
  defaultSellingPrice: 29.99,
  stockQuantity: 100,
  lowStockThreshold: 5,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

final result = await addProductUseCase(AddProductParams(product: product));

result.fold(
  (failure) => print('Error: ${failure.message}'),
  (product) => print('Product added: ${product.name}'),
);
```

---

### Get Products Use Case

**Description:** Retrieves all products for a business.

**Parameters:**
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `businessId` | `String` | Yes | Business ID |

**Returns:** `Either<Failure, List<Product>>`

**Usage Example:**
```dart
final result = await getProductsUseCase('biz_001');

result.fold(
  (failure) => print('Error: ${failure.message}'),
  (products) {
    for (final product in products) {
      print('${product.name}: ${product.stockQuantity} in stock');
    }
  },
);
```

---

### Get Low Stock Alerts Use Case

**Description:** Retrieves products that are at or below the low stock threshold.

**Parameters:**
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `businessId` | `String` | Yes | Business ID |

**Returns:** `Either<Failure, List<Product>>`
- Returns products where `stockQuantity <= lowStockThreshold`

**Usage Example:**
```dart
final result = await getLowStockAlertsUseCase('biz_001');

result.fold(
  (failure) => print('Error: ${failure.message}'),
  (products) {
    if (products.isEmpty) {
      print('All products well stocked!');
    } else {
      for (final product in products) {
        print('LOW STOCK: ${product.name} (${product.stockQuantity} left)');
      }
    }
  },
);
```

---

### Get Out of Stock Alerts Use Case

**Description:** Retrieves products that are completely out of stock.

**Parameters:**
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `businessId` | `String` | Yes | Business ID |

**Returns:** `Either<Failure, List<Product>>`
- Returns products where `stockQuantity == 0`

**Usage Example:**
```dart
final result = await getOutOfStockAlertsUseCase('biz_001');

result.fold(
  (failure) => print('Error: ${failure.message}'),
  (products) {
    if (products.isEmpty) {
      print('No out of stock products!');
    } else {
      for (final product in products) {
        print('OUT OF STOCK: ${product.name}');
      }
    }
  },
);
```

---

### Update Product Use Case

**Description:** Updates an existing product's information.

**Parameters:**
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `product` | `Product` | Yes | Updated product entity |

**Returns:** `Either<Failure, Product>`

**Usage Example:**
```dart
final updatedProduct = product.copyWith(
  name: 'Updated Widget',
  defaultSellingPrice: 34.99,
  stockQuantity: 150,
);

final result = await updateProductUseCase(UpdateProductParams(product: updatedProduct));

result.fold(
  (failure) => print('Error: ${failure.message}'),
  (product) => print('Product updated: ${product.name}'),
);
```

---

### Delete Product Use Case

**Description:** Removes a product from inventory.

**Parameters:**
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `productId` | `String` | Yes | Product ID to delete |

**Returns:** `Either<Failure, void>`

**Usage Example:**
```dart
final result = await deleteProductUseCase('prod_001');

result.fold(
  (failure) => print('Error: ${failure.message}'),
  (_) => print('Product deleted'),
);
```

---

### Adjust Stock Use Case

**Description:** Adjusts the stock quantity of a product (for stocking in/out).

**Parameters:**
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `productId` | `String` | Yes | Product ID |
| `quantityChange` | `int` | Yes | Amount to add (positive) or remove (negative) |

**Returns:** `Either<Failure, Product>`
- `Left(ValidationFailure)`: If result would be negative stock

**Usage Example:**
```dart
// Stock in 50 units
final stockIn = await adjustStockUseCase(const AdjustStockParams(
  productId: 'prod_001',
  quantityChange: 50,
));

// Stock out 10 units
final stockOut = await adjustStockUseCase(const AdjustStockParams(
  productId: 'prod_001',
  quantityChange: -10,
));
```

---

## Expenses Feature

### Add Expense Use Case

**Description:** Records a new expense.

**Parameters:**
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `expense` | `Expense` | Yes | Expense entity to add |

**Expense Fields:**
| Field | Type | Description |
|-------|------|-------------|
| `id` | `String` | Unique identifier |
| `businessId` | `String` | Business ID |
| `category` | `ExpenseCategory` | Expense category |
| `amount` | `double` | Expense amount |
| `note` | `String?` | Optional note/description |
| `createdAt` | `DateTime` | Date of expense |

**Expense Categories:**
- `ExpenseCategory.rent`
- `ExpenseCategory.utilities`
- `ExpenseCategory.stockPurchase`
- `ExpenseCategory.transport`
- `ExpenseCategory.maintenance`
- `ExpenseCategory.other`

**Returns:** `Either<Failure, Expense>`

**Usage Example:**
```dart
final expense = Expense(
  id: 'exp_001',
  businessId: 'biz_001',
  category: ExpenseCategory.utilities,
  amount: 150.00,
  note: 'Monthly electricity bill',
  createdAt: DateTime.now(),
);

final result = await addExpenseUseCase(AddExpenseParams(expense: expense));

result.fold(
  (failure) => print('Error: ${failure.message}'),
  (expense) => print('Expense added: ${expense.category.displayName}'),
);
```

---

### Get Expenses Use Case

**Description:** Retrieves all expenses for a business.

**Parameters:**
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `businessId` | `String` | Yes | Business ID |

**Returns:** `Either<Failure, List<Expense>>`

**Usage Example:**
```dart
final result = await getExpensesUseCase('biz_001');

result.fold(
  (failure) => print('Error: ${failure.message}'),
  (expenses) {
    for (final expense in expenses) {
      print('${expense.category.displayName}: \$${expense.amount}');
    }
  },
);
```

---

### Get Expense Report Use Case

**Description:** Retrieves expenses for a specific date range.

**Parameters:**
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `businessId` | `String` | Yes | Business ID |
| `dateRange` | `DateRange` | Yes | Date range for report |

**Returns:** `Either<Failure, List<Expense>>`

**Usage Example:**
```dart
// Daily report
final dailyRange = DateRange.daily(DateTime.now());

// Weekly report
final weeklyRange = DateRange.weekly(DateTime.now());

// Monthly report
final monthlyRange = DateRange.monthly(DateTime.now());

// Custom range
final customRange = DateRange(
  from: DateTime(2024, 1, 1),
  to: DateTime(2024, 1, 31),
);

final result = await getExpenseReportUseCase(ExpenseReportParams(
  businessId: 'biz_001',
  dateRange: monthlyRange,
));

result.fold(
  (failure) => print('Error: ${failure.message}'),
  (expenses) {
    final total = expenses.fold(0.0, (sum, e) => sum + e.amount);
    print('Total expenses: \$${total.toStringAsFixed(2)}');
  },
);
```

---

## Sales Feature

### Add Sale Use Case

**Description:** Records a new sale transaction.

**Parameters:**
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `sale` | `Sale` | Yes | Sale entity to add |

**Sale Fields:**
| Field | Type | Description |
|-------|------|-------------|
| `id` | `String` | Unique identifier |
| `businessId` | `String` | Business ID |
| `productId` | `String` | Sold product ID |
| `unitPrice` | `double` | Price per unit |
| `quantity` | `int` | Units sold |
| `total` | `double` | Total amount (unitPrice * quantity) |
| `createdAt` | `DateTime` | Date of sale |

**Returns:** `Either<Failure, Sale>`

**Usage Example:**
```dart
final sale = Sale.create(
  id: 'sale_001',
  businessId: 'biz_001',
  productId: 'prod_001',
  unitPrice: 29.99,
  quantity: 3,
);

final result = await addSaleUseCase(AddSaleParams(sale: sale));

result.fold(
  (failure) => print('Error: ${failure.message}'),
  (sale) => print('Sale recorded: \$${sale.total}'),
);
```

---

### Get Sales Use Case

**Description:** Retrieves all sales for a business.

**Parameters:**
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `businessId` | `String` | Yes | Business ID |

**Returns:** `Either<Failure, List<Sale>>`

**Usage Example:**
```dart
final result = await getSalesUseCase('biz_001');

result.fold(
  (failure) => print('Error: ${failure.message}'),
  (sales) {
    for (final sale in sales) {
      print('Sale: ${sale.quantity} x \$${sale.unitPrice} = \$${sale.total}');
    }
  },
);
```

---

### Get Sales Report Use Case

**Description:** Retrieves sales for a specific date range.

**Parameters:**
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `businessId` | `String` | Yes | Business ID |
| `dateRange` | `DateRange` | Yes | Date range for report |

**Returns:** `Either<Failure, List<Sale>>`

**Usage Example:**
```dart
final monthlyRange = DateRange.monthly(DateTime.now());

final result = await getSalesReportUseCase(SalesReportParams(
  businessId: 'biz_001',
  dateRange: monthlyRange,
));

result.fold(
  (failure) => print('Error: ${failure.message}'),
  (sales) {
    final total = sales.fold(0.0, (sum, s) => sum + s.total);
    print('Monthly sales: \$${total.toStringAsFixed(2)}');
  },
);
```

---

### Calculate Profit Use Case

**Description:** Calculates profit (sales - expenses) for a date range.

**Parameters:**
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `businessId` | `String` | Yes | Business ID |
| `dateRange` | `DateRange` | Yes | Date range for calculation |

**Returns:** `Either<Failure, ProfitSummary>`

**ProfitSummary Fields:**
| Field | Type | Description |
|-------|------|-------------|
| `totalSales` | `double` | Total sales amount |
| `totalExpenses` | `double` | Total expenses amount |
| `profit` | `double` | Net profit (sales - expenses) |
| `startDate` | `DateTime` | Report start date |
| `endDate` | `DateTime` | Report end date |
| `isProfit` | `bool` | True if profit > 0 |

**Usage Example:**
```dart
final monthlyRange = DateRange.monthly(DateTime.now());

final result = await calculateProfitUseCase(ProfitParams(
  businessId: 'biz_001',
  dateRange: monthlyRange,
));

result.fold(
  (failure) => print('Error: ${failure.message}'),
  (summary) {
    print('=== Profit Report ===');
    print('Total Sales: \$${summary.totalSales.toStringAsFixed(2)}');
    print('Total Expenses: \$${summary.totalExpenses.toStringAsFixed(2)}');
    print('Net Profit: \$${summary.profit.toStringAsFixed(2)}');
    print('Status: ${summary.isProfit ? "PROFIT" : "LOSS"}');
  },
);
```

---

### Void Sale Use Case

**Description:** Voids/cancels a sale transaction.

**Parameters:**
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `saleId` | `String` | Yes | Sale ID to void |

**Returns:** `Either<Failure, void>`

**Usage Example:**
```dart
final result = await voidSaleUseCase('sale_001');

result.fold(
  (failure) => print('Error: ${failure.message}'),
  (_) => print('Sale voided successfully'),
);
```

---

## Value Objects

### DateRange

**Description:** Represents a date range for reports.

**Factory Constructors:**
| Constructor | Description |
|-------------|-------------|
| `DateRange(from, to)` | Custom date range |
| `DateRange.daily(date)` | Start of day to end of day |
| `DateRange.weekly(date)` | Monday to Sunday of the week |
| `DateRange.monthly(date)` | First day to last day of month |

**Usage Example:**
```dart
// Get today's sales
final today = DateRange.daily(DateTime.now());

// Get this week's expenses
final thisWeek = DateRange.weekly(DateTime.now());

// Get this month's data
final thisMonth = DateRange.monthly(DateTime.now());

// Custom range
final custom = DateRange(
  from: DateTime(2024, 1, 1),
  to: DateTime(2024, 3, 31),
);
```

---

### ProfitSummary

**Description:** Contains profit calculation results.

**Fields:**
| Field | Type | Description |
|-------|------|-------------|
| `totalSales` | `double` | Total sales amount |
| `totalExpenses` | `double` | Total expenses amount |
| `profit` | `double` | Net profit (sales - expenses) |
| `startDate` | `DateTime` | Report period start |
| `endDate` | `DateTime` | Report period end |
| `isProfit` | `bool` | True if profit > 0 |

**Usage Example:**
```dart
final summary = ProfitSummary(
  totalSales: 5000.00,
  totalExpenses: 3000.00,
  profit: 2000.00,
  startDate: DateTime(2024, 1, 1),
  endDate: DateTime(2024, 1, 31),
);

// Check if profitable
if (summary.isProfit) {
  print('You made a profit of \$${summary.profit}!');
} else {
  print('You had a loss of \$${summary.profit.abs()}');
}
```

---

## Common Patterns

### Handling Results

All use cases return `Either<Failure, T>`. Use `fold` to handle both success and failure:

```dart
final result = await someUseCase(params);

result.fold(
  (failure) {
    // Handle failure
    switch (failure) {
      case ServerFailure():
        print('Server error: ${failure.message}');
        break;
      case CacheFailure():
        print('Storage error: ${failure.message}');
        break;
      case NetworkFailure():
        print('No internet');
        break;
      default:
        print('Error: ${failure.message}');
    }
  },
  (success) {
    // Handle success
    print('Success: $success');
  },
);
```

### Dependency Injection

Use GetIt to get use case instances:

```dart
import 'package:mobile/injection_container.dart' as di;

final loginUseCase = di.sl<LoginUseCase>();
final addProductUseCase = di.sl<AddProductUseCase>();
final calculateProfitUseCase = di.sl<CalculateProfitUseCase>();
```

### Sync Status

All entities have `isSynced` property:
- `true`: Data synced with server
- `false`: Data saved locally only (will sync when online)

The `SyncService` automatically syncs data when connectivity is restored.
