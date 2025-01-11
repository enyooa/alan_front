import 'package:equatable/equatable.dart';

abstract class CourierState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CourierInitial extends CourierState {}

class CourierLoading extends CourierState {}

class CourierLoaded extends CourierState {
  final List<Map<String, dynamic>> couriers;

  CourierLoaded(this.couriers);

  @override
  List<Object?> get props => [couriers];
}

class CourierError extends CourierState {
  final String message;

  CourierError(this.message);

  @override
  List<Object?> get props => [message];
}
