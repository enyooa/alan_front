import 'package:equatable/equatable.dart';

abstract class CourierDocumentEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SubmitCourierDocumentEvent extends CourierDocumentEvent {
  final String deliveryAddress;
  final List<Map<String, dynamic>> orderProducts; 
  final int orderId; 

  SubmitCourierDocumentEvent({
    required this.deliveryAddress,
    required this.orderProducts,
    required this.orderId, 

  });

  @override
  List<Object?> get props => [deliveryAddress, orderProducts,orderId];
}

class FetchCourierDocumentsEvent extends CourierDocumentEvent {}
