import 'package:alan/bloc/models/provider.dart';

abstract class ProviderState {}

class ProviderInitial extends ProviderState {}

class ProviderLoading extends ProviderState {}

class ProvidersLoaded extends ProviderState {
  final List<Provider> providers;

  ProvidersLoaded(this.providers);
}

class ProviderSuccess extends ProviderState {
  final String message;

  ProviderSuccess(this.message);
}

class ProviderError extends ProviderState {
  final String error;

  ProviderError(this.error);
}
class SingleProviderLoaded extends ProviderState {
  final Map<String, dynamic> providerData;
  SingleProviderLoaded(this.providerData);
}
