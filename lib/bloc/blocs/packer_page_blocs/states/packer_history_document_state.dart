import 'package:equatable/equatable.dart';

abstract class PackerHistoryDocumentState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PackerHistoryDocumentInitial extends PackerHistoryDocumentState {}

class PackerHistoryDocumentLoading extends PackerHistoryDocumentState {}

class PackerHistoryDocumentLoaded extends PackerHistoryDocumentState {
  final List<Map<String, dynamic>> documents;
  final List<Map<String, dynamic>> statuses; // New field

  PackerHistoryDocumentLoaded({
    required this.documents,
    required this.statuses,
  });

  @override
  List<Object?> get props => [documents, statuses];
}
class PackerHistoryDocumentError extends PackerHistoryDocumentState {
  final String message;

  PackerHistoryDocumentError({required this.message});

  @override
  List<Object?> get props => [message];
}
