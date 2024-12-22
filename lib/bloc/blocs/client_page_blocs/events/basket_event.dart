abstract class BasketEvent {}

class FetchBasketEvent extends BasketEvent {}

class AddToBasketEvent extends BasketEvent {
  final Map<String, dynamic> product;

  AddToBasketEvent(this.product);
}

class RemoveFromBasketEvent extends BasketEvent {
  final String productId;

  RemoveFromBasketEvent(this.productId);
}

class ClearBasketEvent extends BasketEvent {}

class PlaceOrderEvent extends BasketEvent {
  final String address;

  PlaceOrderEvent({required this.address});

  @override
  List<Object> get props => [address];
}
