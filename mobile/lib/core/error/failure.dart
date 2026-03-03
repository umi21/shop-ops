import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable{
  final String message;
  final List<dynamic> properties;

  const Failure(this.message, [this.properties = const <dynamic>[]]);

  @override
  List<Object?> get props => [message, properties];
} 