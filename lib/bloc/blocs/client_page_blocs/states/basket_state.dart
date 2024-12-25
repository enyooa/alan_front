import 'package:cash_control/bloc/models/basket_item.dart';
import 'package:equatable/equatable.dart';

class BasketState extends Equatable {
  final List<BasketItem> basketItems; // Use List<BasketItem>
  final int totalItems;

  const BasketState({
    this.basketItems = const [],
    this.totalItems = 0,
  });

  BasketState copyWith({
    List<BasketItem>? basketItems,
    int? totalItems,
  }) {
    return BasketState(
      basketItems: basketItems ?? this.basketItems,
      totalItems: totalItems ?? this.totalItems,
    );
  }

  @override
  List<Object?> get props => [basketItems, totalItems];
}





class BasketLoading extends BasketState {}

class BasketUpdated extends BasketState {
  BasketUpdated(List<BasketItem> basketItems)
      : super(
          basketItems: basketItems,
          totalItems: basketItems.fold<int>(
            0,
            (sum, item) => sum + item.quantity,
          ),
        );
}


class BasketError extends BasketState {
  final String message;

  BasketError(this.message);

  @override
  List<Object?> get props => [message];
}

class OrderPlacedState extends BasketState {
  final String orderId;

  OrderPlacedState({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}
