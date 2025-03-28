import 'package:equatable/equatable.dart';

abstract class CourierOrdersState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CourierOrdersInitial extends CourierOrdersState {}

class CourierOrdersLoading extends CourierOrdersState {}

class CourierOrdersLoaded extends CourierOrdersState {
  final List<Map<String, dynamic>> orders;
  final List<Map<String, dynamic>> statuses;  // <-- new

  CourierOrdersLoaded({
    required this.orders,
    required this.statuses,  // <-- new
  });

  @override
  List<Object?> get props => [orders, statuses];
}


class CourierOrdersError extends CourierOrdersState {
  final String message;

  CourierOrdersError({required this.message});

  @override
  List<Object?> get props => [message];
}
class SingleOrderLoading extends CourierOrdersState {}

class SingleOrderLoaded extends CourierOrdersState {
  final Map<String, dynamic> orderDetails;

  SingleOrderLoaded({required this.orderDetails});

  @override
  List<Object?> get props => [orderDetails];
}
class UpdateOrderLoading extends CourierOrdersState {}

class UpdateOrderSuccess extends CourierOrdersState {
  final String message;

  UpdateOrderSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class UpdateOrderError extends CourierOrdersState {
  final String message;

  UpdateOrderError({required this.message});

  @override
  List<Object?> get props => [message];
}
