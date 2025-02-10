abstract class UnitEvent {}
class CreateUnitEvent extends UnitEvent {
  final String name;
  final String tare;  // Add tare field

  CreateUnitEvent({required this.name, required this.tare});  // Constructor
}

class FetchUnitsEvent extends UnitEvent {}
