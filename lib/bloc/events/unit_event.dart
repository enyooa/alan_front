import 'package:equatable/equatable.dart';

abstract class UnitEvent extends Equatable {
  const UnitEvent();

  @override
  List<Object?> get props => [];
}

class FetchUnitsEvent extends UnitEvent {}

class CreateUnitEvent extends UnitEvent {
  final String name;

  const CreateUnitEvent({required this.name});

  @override
  List<Object?> get props => [name];
}

class UpdateUnitEvent extends UnitEvent {
  final int unitId;
  final String name;

  const UpdateUnitEvent({required this.unitId, required this.name});

  @override
  List<Object?> get props => [unitId, name];
}

class DeleteUnitEvent extends UnitEvent {
  final int unitId;

  const DeleteUnitEvent(this.unitId);

  @override
  List<Object?> get props => [unitId];
}
