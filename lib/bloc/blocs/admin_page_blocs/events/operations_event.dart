import 'package:equatable/equatable.dart';

abstract class OperationsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchOperationsHistoryEvent extends OperationsEvent {}

class EditOperationEvent extends OperationsEvent {
  final int id;
  final String type;
  final Map<String, dynamic> updatedFields;

  EditOperationEvent({required this.id, required this.type, required this.updatedFields});

  @override
  List<Object?> get props => [id, type, updatedFields];
}

class DeleteOperationEvent extends OperationsEvent {
  final int id;
  final String type;

  DeleteOperationEvent({required this.id, required this.type});

  @override
  List<Object?> get props => [id, type];
}
