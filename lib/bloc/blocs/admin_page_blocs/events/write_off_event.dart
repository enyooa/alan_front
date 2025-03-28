// product_writeoff_event.dart

abstract class ProductWriteOffEvent {}

class CreateBulkProductWriteOffEvent extends ProductWriteOffEvent {
  final List<Map<String, dynamic>> writeOffs; 
  // same shape as "receivings," but we call it "write_offs"

  CreateBulkProductWriteOffEvent({required this.writeOffs});
}
