import 'package:equatable/equatable.dart';

abstract class CourierDocumentEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchCourierDocumentsEvent extends CourierDocumentEvent {}
class SubmitCourierDocumentEvent extends CourierDocumentEvent {
  final int courierId; // ID of the courier
  final List<Map<String, dynamic>> orders; // Orders with products

  SubmitCourierDocumentEvent({
    required this.courierId,
    required this.orders,
  });

  @override
  List<Object?> get props => [courierId, orders];
}
