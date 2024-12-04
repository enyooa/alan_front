import 'package:equatable/equatable.dart';

class BasketState extends Equatable {
  final Map<String, Map<String, dynamic>> basketItems;
  final int totalItems;

  const BasketState({required this.basketItems, required this.totalItems});

  factory BasketState.initial() {
    return const BasketState(basketItems: {}, totalItems: 0);
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
  List<Object> get props => [basketItems, totalItems];
}
