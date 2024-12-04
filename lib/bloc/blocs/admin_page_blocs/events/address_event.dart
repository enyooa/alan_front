import 'package:equatable/equatable.dart';

abstract class AddressEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CreateAddressEvent extends AddressEvent {
  final int userId;
  final String name;

  CreateAddressEvent({required this.userId, required this.name});

  @override
  List<Object?> get props => [userId, name];
}
