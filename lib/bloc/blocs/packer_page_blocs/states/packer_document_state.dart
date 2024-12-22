import 'package:equatable/equatable.dart';

abstract class PackerDocumentState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PackerDocumentInitial extends PackerDocumentState {}

class PackerDocumentLoading extends PackerDocumentState {}

class PackerDocumentSubmitted extends PackerDocumentState {
  final String message;

  PackerDocumentSubmitted({required this.message});

  @override
  List<Object?> get props => [message];
}

class PackerDocumentError extends PackerDocumentState {
  final String error;

  PackerDocumentError({required this.error});

  @override
  List<Object?> get props => [error];
}
class PackerDocumentsFetched extends PackerDocumentState {
  final List<Map<String, dynamic>> documents;

  PackerDocumentsFetched({required this.documents});

  @override
  List<Object?> get props => [documents];
}

