import 'package:equatable/equatable.dart';

abstract class StorageAddressState extends Equatable {
  @override
  List<Object?> get props => [];
}

class StorageAddressInitial extends StorageAddressState {}

class StorageAddressLoading extends StorageAddressState {}

class StorageAddressesFetched extends StorageAddressState {
  final List<Map<String, dynamic>> storageUsers;

  StorageAddressesFetched(this.storageUsers);

  @override
  List<Object?> get props => [storageUsers];
}

class StorageAddressError extends StorageAddressState {
  final String error;

  StorageAddressError(this.error);

  @override
  List<Object?> get props => [error];
}
