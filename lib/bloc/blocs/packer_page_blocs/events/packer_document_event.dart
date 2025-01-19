import 'package:equatable/equatable.dart';

abstract class PackerDocumentEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SubmitPackerDocumentEvent extends PackerDocumentEvent {
  final int idCourier;
  final String deliveryAddress;
  final List<Map<String, dynamic>> orderProducts; 
  final int orderId; 

  SubmitPackerDocumentEvent({
    required this.idCourier,
    required this.deliveryAddress,
    required this.orderProducts,
    required this.orderId, 

  });

  @override
  List<Object?> get props => [idCourier, deliveryAddress, orderProducts,orderId];
}

class FetchPackerDocumentsEvent extends PackerDocumentEvent {}
