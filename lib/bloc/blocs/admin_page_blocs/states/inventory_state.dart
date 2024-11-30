import 'package:equatable/equatable.dart';

abstract class InventoryState extends Equatable {
  @override
  List<Object?> get props => [];
}

class InventoryInitial extends InventoryState {}

class InventoryLoading extends InventoryState {}

class InventoryLoaded extends InventoryState {
  final List<Map<String, dynamic>> inventoryList; // Inventory data

  InventoryLoaded({required this.inventoryList});

  @override
  List<Object?> get props => [inventoryList];
}

class InventorySubmitted extends InventoryState {
  final String message;

  InventorySubmitted({required this.message});

  @override
  List<Object?> get props => [message];
}

class InventoryError extends InventoryState {
  final String message;

  InventoryError({required this.message});

  @override
  List<Object?> get props => [message];
}
