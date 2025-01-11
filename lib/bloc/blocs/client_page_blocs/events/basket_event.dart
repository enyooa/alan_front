import 'package:equatable/equatable.dart';

abstract class BasketEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchBasketEvent extends BasketEvent {}

class AddToBasketEvent extends BasketEvent {
  final Map<String, dynamic> product; // Contains price and other details

  AddToBasketEvent(this.product);

  @override
  List<Object?> get props => [product];
}


class RemoveFromBasketEvent extends BasketEvent {
  final String productId;

  RemoveFromBasketEvent(this.productId);
    @override
  List<Object?> get props => [productId];
}

class ClearBasketEvent extends BasketEvent {}

class PlaceOrderEvent extends BasketEvent {
  final String address;

  PlaceOrderEvent({required this.address});

  @override
  List<Object> get props => [address];
}
