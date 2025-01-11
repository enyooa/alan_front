import 'package:equatable/equatable.dart';

abstract class CourierDocumentEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchCourierDocumentsEvent extends CourierDocumentEvent {}
class SubmitCourierDocumentEvent extends CourierDocumentEvent {
  final List<Map<String, dynamic>> documents;

  SubmitCourierDocumentEvent({required this.documents});

  @override
  List<Object?> get props => [documents];
}
