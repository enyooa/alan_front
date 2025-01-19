import 'package:equatable/equatable.dart';

abstract class PackerHistoryDocumentEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchPackerHistoryDocumentsEvent extends PackerHistoryDocumentEvent {}
