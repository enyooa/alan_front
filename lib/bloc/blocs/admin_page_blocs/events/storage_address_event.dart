import 'package:equatable/equatable.dart';

abstract class StorageAddressEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchStorageAddressesEvent extends StorageAddressEvent {}
