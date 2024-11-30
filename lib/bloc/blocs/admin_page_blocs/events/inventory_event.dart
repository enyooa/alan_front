import 'package:equatable/equatable.dart';

abstract class InventoryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchInventoryEvent extends InventoryEvent {}

class SubmitInventoryEvent extends InventoryEvent {
  final int storageUserId; // ID of the storage user
  final List<Map<String, dynamic>> inventoryRows; // Inventory rows to submit

  SubmitInventoryEvent({
    required this.storageUserId,
    required this.inventoryRows,
  });

  @override
  List<Object?> get props => [storageUserId, inventoryRows];
}
