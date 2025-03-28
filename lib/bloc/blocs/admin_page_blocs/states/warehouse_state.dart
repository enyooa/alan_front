import 'package:equatable/equatable.dart';

abstract class WarehouseState extends Equatable {
  @override
  List<Object?> get props => [];
}

class WarehouseInitial extends WarehouseState {}

class WarehouseLoading extends WarehouseState {}

class WarehouseLoaded extends WarehouseState {
  final List<dynamic> warehouses; // or List<Map<String,dynamic>>

  WarehouseLoaded({required this.warehouses});

  @override
  List<Object?> get props => [warehouses];
}

class WarehouseError extends WarehouseState {
  final String message;
  WarehouseError({required this.message});

  @override
  List<Object?> get props => [message];
}
