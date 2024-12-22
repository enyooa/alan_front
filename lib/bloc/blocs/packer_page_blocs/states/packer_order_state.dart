import 'package:equatable/equatable.dart';

abstract class PackerOrdersState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PackerOrdersInitial extends PackerOrdersState {}

class PackerOrdersLoading extends PackerOrdersState {}

class PackerOrdersLoaded extends PackerOrdersState {
  final List<Map<String, dynamic>> orders;

  PackerOrdersLoaded({required this.orders});

  @override
  List<Object?> get props => [orders];
}

class PackerOrdersError extends PackerOrdersState {
  final String message;

  PackerOrdersError({required this.message});

  @override
  List<Object?> get props => [message];
}
class SingleOrderLoading extends PackerOrdersState {}

class SingleOrderLoaded extends PackerOrdersState {
  final Map<String, dynamic> orderDetails;

  SingleOrderLoaded({required this.orderDetails});

  @override
  List<Object?> get props => [orderDetails];
}
class UpdateOrderLoading extends PackerOrdersState {}

class UpdateOrderSuccess extends PackerOrdersState {
  final String message;

  UpdateOrderSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class UpdateOrderError extends PackerOrdersState {
  final String message;

  UpdateOrderError({required this.message});

  @override
  List<Object?> get props => [message];
}
