import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/value_objects/date_range.dart';

void main() {
  group('DateRange Value Object', () {
    test('should create DateRange with from and to dates', () {
      final dateRange = DateRange(
        from: DateTime(2024, 1, 1),
        to: DateTime(2024, 1, 31),
      );

      expect(dateRange.from, DateTime(2024, 1, 1));
      expect(dateRange.to, DateTime(2024, 1, 31));
    });

    test('daily factory should create start and end of same day', () {
      final date = DateTime(2024, 1, 15, 10, 30);
      final dateRange = DateRange.daily(date);

      expect(dateRange.from, DateTime(2024, 1, 15));
      expect(dateRange.to.day, 15);
      expect(dateRange.to.hour, 23);
      expect(dateRange.to.minute, 59);
    });

    test('weekly factory should create Monday to Sunday range', () {
      final date = DateTime(2024, 1, 17); // Wednesday
      final dateRange = DateRange.weekly(date);

      expect(dateRange.from.weekday, DateTime.monday);
      expect(dateRange.to.weekday, DateTime.sunday);
      expect(dateRange.from.month, 1);
      expect(dateRange.to.month, 1);
    });

    test('monthly factory should create first to last day of month', () {
      final date = DateTime(2024, 1, 15);
      final dateRange = DateRange.monthly(date);

      expect(dateRange.from.day, 1);
      expect(dateRange.from.month, 1);
      expect(dateRange.to.day, 31);
      expect(dateRange.to.month, 1);
    });

    test('two DateRanges with same props should be equal', () {
      final dateRange1 = DateRange(
        from: DateTime(2024, 1, 1),
        to: DateTime(2024, 1, 31),
      );

      final dateRange2 = DateRange(
        from: DateTime(2024, 1, 1),
        to: DateTime(2024, 1, 31),
      );

      expect(dateRange1, equals(dateRange2));
    });
  });
}
