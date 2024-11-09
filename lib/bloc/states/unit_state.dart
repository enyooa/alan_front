import 'package:equatable/equatable.dart';

abstract class UnitState extends Equatable {
  const UnitState();

  @override
  List<Object?> get props => [];
}

class UnitInitial extends UnitState {}

class UnitLoading extends UnitState {}

class UnitsLoaded extends UnitState {
  final List<dynamic> units;

  const UnitsLoaded(this.units);

  @override
  List<Object?> get props => [units];
}

class UnitCreated extends UnitState {}

class UnitUpdated extends UnitState {}

class UnitDeleted extends UnitState {}

class UnitError extends UnitState {
  final String message;

  const UnitError(this.message);

  @override
  List<Object?> get props => [message];
}
