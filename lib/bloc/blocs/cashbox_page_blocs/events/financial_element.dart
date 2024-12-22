abstract class ReferenceEvent {}

class FetchReferencesEvent extends ReferenceEvent {}

class AddReferenceEvent extends ReferenceEvent {
  final String category;
  final String item;
  AddReferenceEvent(this.category, this.item);
}

class EditReferenceEvent extends ReferenceEvent {
  final String category;
  final int index;
  final String newItem;
  EditReferenceEvent(this.category, this.index, this.newItem);
}

class DeleteReferenceEvent extends ReferenceEvent {
  final String category;
  final int index;
  DeleteReferenceEvent(this.category, this.index);
}
