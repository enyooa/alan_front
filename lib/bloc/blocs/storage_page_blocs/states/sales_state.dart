abstract class StorageSalesState {}

class StorageSalesInitial extends StorageSalesState {}

class StorageSalesLoading extends StorageSalesState {}

class StorageSalesListLoaded extends StorageSalesState {
  final List<dynamic> sales;
  StorageSalesListLoaded(this.sales);
}

class StorageSalesCreated extends StorageSalesState {
  final String message;
  StorageSalesCreated(this.message);
}

class StorageSalesUpdated extends StorageSalesState {
  final String message;
  StorageSalesUpdated(this.message);
}

class StorageSalesDeleted extends StorageSalesState {
  final String message;
  StorageSalesDeleted(this.message);
}

class StorageSalesError extends StorageSalesState {
  final String message;
  StorageSalesError(this.message);
}