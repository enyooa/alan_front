abstract class UnitState {}

class UnitInitial extends UnitState {}

class UnitLoading extends UnitState {}

class UnitFetchedSuccess extends UnitState {
  final List<Map<String, dynamic>> units;

  UnitFetchedSuccess(this.units);
}

class UnitCreatedSuccess extends UnitState {
  final String message;

  UnitCreatedSuccess(this.message);
}

class UnitError extends UnitState {
  final String error;

  UnitError(this.error);
}
