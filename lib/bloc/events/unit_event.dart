abstract class UnitEvent {}

class CreateUnitEvent extends UnitEvent {
  final String name;

  CreateUnitEvent({required this.name});
}
class FetchUnitsEvent extends UnitEvent {}
