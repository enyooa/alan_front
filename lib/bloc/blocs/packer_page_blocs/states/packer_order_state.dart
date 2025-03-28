import 'package:equatable/equatable.dart';

abstract class PackerOrdersState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PackerOrdersInitial extends PackerOrdersState {}

class PackerOrdersLoading extends PackerOrdersState {}

class PackerOrdersLoaded extends PackerOrdersState {
  final List<Map<String, dynamic>> orders;
  final List<Map<String, dynamic>> statuses;

  PackerOrdersLoaded({
    required this.orders,
    required this.statuses,
  });

  @override
  List<Object?> get props => [orders, statuses];
}

class PackerOrdersError extends PackerOrdersState {
  final String message;
  PackerOrdersError({required this.message});
}

// Single order states
class SingleOrderLoading extends PackerOrdersState {}
class SingleOrderLoaded extends PackerOrdersState {
  final Map<String, dynamic> orderDetails;
  SingleOrderLoaded({required this.orderDetails});
}

// Update
class UpdateOrderLoading extends PackerOrdersState {}
class UpdateOrderSuccess extends PackerOrdersState {
  final String message;
  UpdateOrderSuccess({required this.message});
}
class UpdateOrderError extends PackerOrdersState {
  final String message;
  UpdateOrderError({required this.message});
}

// NEW: Submit order states
class SubmitOrderLoading extends PackerOrdersState {}

class SubmitOrderSuccess extends PackerOrdersState {
  final String message;
  SubmitOrderSuccess({required this.message});
}

class SubmitOrderError extends PackerOrdersState {
  final String error;
  SubmitOrderError({required this.error});
}
