import 'package:equatable/equatable.dart';

abstract class ClientOrderItemsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ClientOrderItemsInitial extends ClientOrderItemsState {}

class ClientOrderItemsLoading extends ClientOrderItemsState {}

class ClientOrderItemsLoaded extends ClientOrderItemsState {
  final List<dynamic> clientOrderItems;

  ClientOrderItemsLoaded({required this.clientOrderItems});

  @override
  List<Object?> get props => [clientOrderItems];
}


class ClientOrderItemsError extends ClientOrderItemsState {
  final String error;

  ClientOrderItemsError({required this.error});

  @override
  List<Object?> get props => [error];
}
