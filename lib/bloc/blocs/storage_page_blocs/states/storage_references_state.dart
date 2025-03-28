  // storage_references_state.dart

  abstract class StorageReferencesState {}

  class StorageReferencesInitial extends StorageReferencesState {}

  class StorageReferencesLoading extends StorageReferencesState {}

  // If references are loaded successfully
  class StorageReferencesLoaded extends StorageReferencesState {
    final List<dynamic> providers;
    final List<dynamic> clients;
    final List<dynamic> productSubCards;
    final List<dynamic> unitMeasurements;
    final List<dynamic> expenses;

    StorageReferencesLoaded({
      required this.providers,
      required this.clients,
      required this.productSubCards,
      required this.unitMeasurements,
      required this.expenses,
    });
  }

  // If error occurs either in fetch or store
  class StorageReferencesError extends StorageReferencesState {
    final String message;
    StorageReferencesError(this.message);
  }

  // If we successfully store the income doc
  class StoreIncomeCreated extends StorageReferencesState {
    final String message;
    StoreIncomeCreated(this.message);
  }
