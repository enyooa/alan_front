abstract class UnitState {}

class UnitInitial extends UnitState {}

class UnitLoading extends UnitState {}

class UnitSuccess extends UnitState {
  final String message;

  UnitSuccess(this.message);
}

class UnitError extends UnitState {
  final String error;

  UnitError(this.error);
}
