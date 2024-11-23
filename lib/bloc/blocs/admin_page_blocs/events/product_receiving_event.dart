// априходование товара
import 'package:equatable/equatable.dart';

abstract class ProductReceivingEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchProductReceivingEvent extends ProductReceivingEvent {
  @override
  List<Object?> get props => [];
}

class CreateProductReceivingEvent extends ProductReceivingEvent {
  final int productCardId;
  final String? unitMeasurement;
  final double quantity;
  final int price;
  final int totalSum;
  final String? date; // Optional date field

  CreateProductReceivingEvent({
    required this.productCardId,
    this.unitMeasurement,
    required this.quantity,
    required this.price,
    required this.totalSum,
    this.date,
  });

  @override
  List<Object?> get props => [
        productCardId,
        unitMeasurement,
        quantity,
        price,
        totalSum,
        date,
      ];
}
