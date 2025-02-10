import 'package:equatable/equatable.dart';

abstract class CourierDocumentState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CourierDocumentInitial extends CourierDocumentState {}

class CourierDocumentLoading extends CourierDocumentState {}

class CourierDocumentSubmitted extends CourierDocumentState {
  final String message;

  CourierDocumentSubmitted({required this.message});

  @override
  List<Object?> get props => [message];
}

class CourierDocumentError extends CourierDocumentState {
  final String error;

  CourierDocumentError({required this.error});

  @override
  List<Object?> get props => [error];
}
class CourierDocumentsFetched extends CourierDocumentState {
  final List<Map<String, dynamic>> documents;

  CourierDocumentsFetched({required this.documents});

  @override
  List<Object?> get props => [documents];
}

