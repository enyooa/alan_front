abstract class InventoryTransferState {}

class InventoryTransferInitial extends InventoryTransferState {}

class InventoryTransferLoading extends InventoryTransferState {}

class InventoryTransferSuccess extends InventoryTransferState {
  final String message;

  InventoryTransferSuccess(this.message);
}

class InventoryTransferError extends InventoryTransferState {
  final String error;

  InventoryTransferError(this.error);
}
