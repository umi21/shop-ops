import 'package:equatable/equatable.dart';
import 'package:mobile/core/value_objects/date_range.dart';
import 'package:mobile/features/sales/domain/entities/sale.dart';

abstract class SalesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadSalesEvent extends SalesEvent {
  final String businessId;
  LoadSalesEvent(this.businessId);

  @override
  List<Object?> get props => [businessId];
}

class ChangeSalesPeriodEvent extends SalesEvent {
  final String period;
  ChangeSalesPeriodEvent(this.period);

  @override
  List<Object?> get props => [period];
}

class AddSaleEvent extends SalesEvent {
  final Sale sale;
  AddSaleEvent(this.sale);

  @override
  List<Object?> get props => [sale];
}

class VoidSaleEvent extends SalesEvent {
  final String saleId;
  VoidSaleEvent(this.saleId);

  @override
  List<Object?> get props => [saleId];
}

class FilterSalesByDateEvent extends SalesEvent {
  final DateRange dateRange;
  FilterSalesByDateEvent(this.dateRange);

  @override
  List<Object?> get props => [dateRange];
}

class SearchSalesEvent extends SalesEvent {
  final String query;
  SearchSalesEvent(this.query);

  @override
  List<Object?> get props => [query];
}
