
// sales_storage_state.dart
abstract class SalesStorageState {}

class SalesStorageInitial extends SalesStorageState {}
class SalesStorageLoading extends SalesStorageState {}

class SalesStorageLoaded extends SalesStorageState {
  final List<dynamic> clients;
  final List<dynamic> productSubCards;
  final List<dynamic> unitMeasurements;

  SalesStorageLoaded({
    required this.clients,
    required this.productSubCards,
    required this.unitMeasurements,
  });
}

class SalesStorageSubmitted extends SalesStorageState {
  final String message;
  SalesStorageSubmitted(this.message);
}

class SalesStorageError extends SalesStorageState {
  final String error;
  SalesStorageError(this.error);
}
