import 'package:alan/bloc/models/operation.dart';
import 'package:equatable/equatable.dart';

abstract class OperationsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class OperationsInitial extends OperationsState {}

class OperationsLoading extends OperationsState {}

class OperationsLoaded extends OperationsState {
  final List<Operation> operations;

  OperationsLoaded({required this.operations});
}


class OperationsSuccess extends OperationsState {
  final String message;

  OperationsSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class OperationsError extends OperationsState {
  final String message;

  OperationsError({required this.message});

  @override
  List<Object?> get props => [message];
}
