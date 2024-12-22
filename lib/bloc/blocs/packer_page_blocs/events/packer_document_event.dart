import 'package:equatable/equatable.dart';

abstract class PackerDocumentEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SubmitPackerDocumentEvent extends PackerDocumentEvent {
  final int idCourier;
  final String? deliveryAddress;
  final int productSubcardId;
  final double? amountOfProducts;

  SubmitPackerDocumentEvent({
    required this.idCourier,
    this.deliveryAddress,
    required this.productSubcardId,
    this.amountOfProducts,
  });

  @override
  List<Object?> get props => [idCourier, deliveryAddress, productSubcardId, amountOfProducts];
}
class FetchPackerDocumentsEvent extends PackerDocumentEvent {}
