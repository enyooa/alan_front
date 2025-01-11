import 'package:equatable/equatable.dart';

abstract class PackerDocumentEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SubmitPackerDocumentEvent extends PackerDocumentEvent {
  final int idCourier;
  final String deliveryAddress;
  final List<Map<String, dynamic>> orderProducts; // Add complete order products list

  SubmitPackerDocumentEvent({
    required this.idCourier,
    required this.deliveryAddress,
    required this.orderProducts,
  });

  @override
  List<Object?> get props => [idCourier, deliveryAddress, orderProducts];
}

class FetchPackerDocumentsEvent extends PackerDocumentEvent {}
