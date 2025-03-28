
// Events
abstract class StorageSalesEvent {}

// 1) Fetch all sales
class FetchAllSalesEvent extends StorageSalesEvent {}

// 2) Create a sale (bulk or single, up to you)
class CreateSalesEvent extends StorageSalesEvent {
  final List<Map<String, dynamic>> sales;
  CreateSalesEvent({required this.sales});
}

// 3) Update a sale
class UpdateSaleEvent extends StorageSalesEvent {
  final int docId;
  final Map<String, dynamic> updatedData;
  UpdateSaleEvent({required this.docId, required this.updatedData});
}

// 4) Delete a sale
class DeleteSaleEvent extends StorageSalesEvent {
  final int docId;
  DeleteSaleEvent({required this.docId});
}
