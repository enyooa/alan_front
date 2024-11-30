import 'package:equatable/equatable.dart';

abstract class OperationsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class UpdateOperationEvent extends OperationsEvent {
  final int id;
  final String operation;
  final String date;

  UpdateOperationEvent({required this.id, required this.operation, required this.date});

  @override
  List<Object?> get props => [id, operation, date];
}


class FetchOperationsHistoryEvent extends OperationsEvent {}
