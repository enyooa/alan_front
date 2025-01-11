abstract class SalesStorageState {}

class SalesStorageInitial extends SalesStorageState {}

class SalesStorageLoading extends SalesStorageState {}

class SalesStorageLoaded extends SalesStorageState {
  final List<dynamic> clients;
  final List<dynamic> unitMeasurements;
  final List<dynamic> productSubCards;

  SalesStorageLoaded({
    required this.clients,
    required this.unitMeasurements,
    required this.productSubCards,
  });
}

class SalesStorageError extends SalesStorageState {
  final String error;

  SalesStorageError(this.error);
}
class SalesStorageSubmitted extends SalesStorageState {
  final String message;

  SalesStorageSubmitted(this.message);
}


