abstract class ProviderEvent {}

class FetchProvidersEvent extends ProviderEvent {}

class CreateProviderEvent extends ProviderEvent {
  final String name;

  CreateProviderEvent({required this.name});
}

class UpdateProviderEvent extends ProviderEvent {
  final int id;
  final String name;

  UpdateProviderEvent({required this.id, required this.name});
}

class DeleteProviderEvent extends ProviderEvent {
  final int id;

  DeleteProviderEvent({required this.id});
}
class FetchSingleProviderEvent extends ProviderEvent {
  final int id;
  FetchSingleProviderEvent({required this.id});
}
