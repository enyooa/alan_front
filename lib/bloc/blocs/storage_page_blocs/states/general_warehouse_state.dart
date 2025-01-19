import 'package:equatable/equatable.dart';

abstract class GeneralWarehouseState extends Equatable {
  @override
  List<Object?> get props => [];
}

class GeneralWarehouseInitial extends GeneralWarehouseState {}

class GeneralWarehouseLoading extends GeneralWarehouseState {}

class GeneralWarehouseLoaded extends GeneralWarehouseState {
  final List<Map<String, dynamic>> warehouseData;

  GeneralWarehouseLoaded({required this.warehouseData});

  @override
  List<Object?> get props => [warehouseData];
}

class GeneralWarehouseWriteOffSuccess extends GeneralWarehouseState {
  final String message;

  GeneralWarehouseWriteOffSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class GeneralWarehouseError extends GeneralWarehouseState {
  final String error;

  GeneralWarehouseError({required this.error});

  @override
  List<Object?> get props => [error];
}
