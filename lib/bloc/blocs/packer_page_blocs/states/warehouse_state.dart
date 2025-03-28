import 'package:equatable/equatable.dart';

abstract class WarehouseMovementState extends Equatable {
  @override
  List<Object?> get props => [];
}

class WarehouseMovementInitial extends WarehouseMovementState {}

class WarehouseMovementLoading extends WarehouseMovementState {}

class WarehouseMovementLoaded extends WarehouseMovementState {
  final List<Map<String, dynamic>> reportData;

  WarehouseMovementLoaded({required this.reportData});

  @override
  List<Object?> get props => [reportData];
}

class WarehouseMovementError extends WarehouseMovementState {
  final String error;

  WarehouseMovementError({required this.error});

  @override
  List<Object?> get props => [error];
}
