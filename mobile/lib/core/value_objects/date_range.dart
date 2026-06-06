import 'package:equatable/equatable.dart';

class DateRange extends Equatable {
  final DateTime from;
  final DateTime to;

  const DateRange({required this.from, required this.to});

  factory DateRange.daily(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay
        .add(const Duration(days: 1))
        .subtract(const Duration(milliseconds: 1));
    return DateRange(from: startOfDay, to: endOfDay);
  }

  factory DateRange.weekly(DateTime date) {
    final weekday = date.weekday;
    final startOfWeek = date.subtract(Duration(days: weekday - 1));
    final start = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );
    final end = start.add(
      const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
    );
    return DateRange(from: start, to: end);
  }

  factory DateRange.monthly(DateTime date) {
    final start = DateTime(date.year, date.month, 1);
    final end = DateTime(
      date.year,
      date.month + 1,
      1,
    ).subtract(const Duration(milliseconds: 1));
    return DateRange(from: start, to: end);
  }

  @override
  List<Object?> get props => [from, to];
}
