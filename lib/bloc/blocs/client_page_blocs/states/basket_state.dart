import 'package:equatable/equatable.dart';

class BasketState extends Equatable {
  final Map<String, Map<String, dynamic>> basketItems;
  final int totalItems;

  const BasketState({this.basketItems = const {}, this.totalItems = 0});

  // Factory method for the initial state
  factory BasketState.initial() {
    return const BasketState();
  }

  BasketState copyWith({
    Map<String, Map<String, dynamic>>? basketItems,
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



class BasketLoading extends BasketState {
  BasketLoading() : super(basketItems: {}, totalItems: 0);
}

class BasketUpdated extends BasketState {
  BasketUpdated(Map<String, Map<String, dynamic>> basketItems)
      : super(
          basketItems: basketItems,
          totalItems: basketItems.values.fold<int>(
            0,
            (sum, item) => sum + (item['quantity'] as int? ?? 0),
          ),
        );
}


class BasketError extends BasketState {
  final String message;

  BasketError(this.message) : super(basketItems: {}, totalItems: 0);

  @override
  List<Object?> get props => [message];
}

class OrderPlacedState extends BasketState {
  final String orderId;

  OrderPlacedState({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}
