abstract class SalesStorageEvent {}

class FetchSalesStorageData extends SalesStorageEvent {}
class SubmitSalesStorageData extends SalesStorageEvent {
  final int clientId;
  final int addressId;
  final DateTime date;
  final List<Map<String, dynamic>> products;

  SubmitSalesStorageData({
    required this.clientId,
    required this.addressId,
    required this.date,
    required this.products,
  });
}

