abstract class UnitEvent {}
class CreateUnitEvent extends UnitEvent {
  final String name;
  final String tare;  // Add tare field

  CreateUnitEvent({required this.name, required this.tare});  // Constructor
}

class FetchUnitsEvent extends UnitEvent {}

class FetchSingleUnitEvent extends UnitEvent {
  final int id;
  FetchSingleUnitEvent({required this.id});
}
class UpdateUnitEvent extends UnitEvent {
  final int id;                     // The unit record ID
  final Map<String, dynamic> data;  // e.g. { "name": "...", "tare": "..." }

  UpdateUnitEvent({required this.id, required this.data});
}