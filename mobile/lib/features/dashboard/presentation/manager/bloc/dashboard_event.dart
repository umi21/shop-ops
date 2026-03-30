import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadDashboardDataEvent extends DashboardEvent {
  final String businessId;
  LoadDashboardDataEvent(this.businessId);

  @override
  List<Object?> get props => [businessId];
}

class ChangeDashboardPeriodEvent extends DashboardEvent {
  final String period;
  ChangeDashboardPeriodEvent(this.period);

  @override
  List<Object?> get props => [period];
}

class RefreshDashboardEvent extends DashboardEvent {
  final String businessId;
  RefreshDashboardEvent(this.businessId);

  @override
  List<Object?> get props => [businessId];
}
