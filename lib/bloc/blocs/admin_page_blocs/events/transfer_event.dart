// product_transfer_event.dart

abstract class ProductTransferEvent {}

class CreateBulkProductTransferEvent extends ProductTransferEvent {
  final Map<String, dynamic> payload;
  CreateBulkProductTransferEvent({required this.payload});
}
