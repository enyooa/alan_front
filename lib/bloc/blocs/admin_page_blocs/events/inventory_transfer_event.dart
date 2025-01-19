abstract class InventoryTransferEvent {}

class FetchAdminWarehouseQuantities extends InventoryTransferEvent {}

class TransferInventory extends InventoryTransferEvent {
  final List<Map<String, dynamic>> transfers;
  final int addressId;
  final int userId;
  final String date;

  TransferInventory({
    required this.transfers,
    required this.addressId,
    required this.userId,
    required this.date,
  });
}
