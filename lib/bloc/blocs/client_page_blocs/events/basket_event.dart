import 'package:equatable/equatable.dart';

abstract class BasketEvent extends Equatable {
  const BasketEvent();

  @override
  List<Object> get props => [];
}

class AddToBasketEvent extends BasketEvent {
  final Map<String, dynamic> product;

  const AddToBasketEvent(this.product);

  @override
  List<Object> get props => [product];
}

class RemoveFromBasketEvent extends BasketEvent {
  final String productId;

  const RemoveFromBasketEvent(this.productId);

  @override
  List<Object> get props => [productId];
}

class ClearBasketEvent extends BasketEvent {}
