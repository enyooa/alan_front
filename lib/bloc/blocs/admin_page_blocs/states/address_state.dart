import 'package:equatable/equatable.dart';

abstract class AddressState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AddressInitial extends AddressState {}

class AddressLoading extends AddressState {}

class AddressCreated extends AddressState {
  final String message;

  AddressCreated(this.message);

  @override
  List<Object?> get props => [message];
}

class AddressError extends AddressState {
  final String error;

  AddressError(this.error);

  @override
  List<Object?> get props => [error];
}
class AddressesFetched extends AddressState {
  final List<Map<String, dynamic>> addresses;

  AddressesFetched(this.addresses);

  @override
  List<Object?> get props => [addresses];
}

