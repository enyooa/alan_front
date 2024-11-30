import 'package:equatable/equatable.dart';

abstract class OperationsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class UpdateOperationEvent extends OperationsEvent {
  final int id;
  final String type;
  final String operation;

  UpdateOperationEvent({required this.id, required this.type, required this.operation});
}

class DeleteOperationEvent extends OperationsEvent {
  final int id;
  final String type;

  DeleteOperationEvent({required this.id, required this.type});
}


class FetchOperationsHistoryEvent extends OperationsEvent {}


