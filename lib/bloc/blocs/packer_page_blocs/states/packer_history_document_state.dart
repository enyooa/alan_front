import 'package:equatable/equatable.dart';

abstract class PackerHistoryDocumentState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PackerHistoryDocumentInitial extends PackerHistoryDocumentState {}

class PackerHistoryDocumentLoading extends PackerHistoryDocumentState {}

class PackerHistoryDocumentLoaded extends PackerHistoryDocumentState {
  final List<Map<String, dynamic>> documents;

  PackerHistoryDocumentLoaded({required this.documents});

  @override
  List<Object?> get props => [documents];
}

class PackerHistoryDocumentError extends PackerHistoryDocumentState {
  final String message;

  PackerHistoryDocumentError({required this.message});

  @override
  List<Object?> get props => [message];
}
