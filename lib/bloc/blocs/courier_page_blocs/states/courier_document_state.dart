import 'package:equatable/equatable.dart';

abstract class CourierDocumentState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CourierDocumentInitial extends CourierDocumentState {}

class CourierDocumentLoading extends CourierDocumentState {}

class CourierDocumentLoaded extends CourierDocumentState {
  final List<dynamic> documents;

  CourierDocumentLoaded({required this.documents});

  @override
  List<Object?> get props => [documents];
}

class CourierDocumentSubmittedSuccess extends CourierDocumentState {}

class CourierDocumentError extends CourierDocumentState {
  final String error;

  CourierDocumentError({required this.error});

  @override
  List<Object?> get props => [error];
}
