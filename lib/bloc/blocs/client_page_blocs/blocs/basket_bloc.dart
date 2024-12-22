import 'package:bloc/bloc.dart';
import 'package:cash_control/bloc/blocs/client_page_blocs/events/basket_event.dart';
import 'package:cash_control/bloc/blocs/client_page_blocs/states/basket_state.dart';
import 'package:cash_control/bloc/blocs/client_page_blocs/repositories/basket_repository.dart';
import 'package:equatable/equatable.dart';

class BasketBloc extends Bloc<BasketEvent, BasketState> {
  final BasketRepository repository;

  BasketBloc({required this.repository}) : super(BasketState.initial()) {
    // Event handlers
    on<FetchBasketEvent>(_onFetchBasket);
    on<AddToBasketEvent>(_onAddToBasket);
    on<RemoveFromBasketEvent>(_onRemoveFromBasket);
    on<ClearBasketEvent>(_onClearBasket);
    on<PlaceOrderEvent>(_onPlaceOrder);

  }

  /// Handle fetching the basket from the backend
  Future<void> _onFetchBasket(
    FetchBasketEvent event, Emitter<BasketState> emit) async {
  emit(BasketLoading());

  try {
    final basketItems = await repository.getBasket();
    final totalItems = basketItems.values.fold<int>(
      0,
      (sum, item) => sum + (item['quantity'] as int? ?? 0),
    );

    emit(state.copyWith(basketItems: basketItems, totalItems: totalItems));
  } catch (e) {
    print('Error fetching basket: $e');
    emit(BasketError("Failed to fetch basket: ${e.toString()}"));
  }
}

  /// Handle adding a product to the basket
  Future<void> _onAddToBasket(
    AddToBasketEvent event, Emitter<BasketState> emit) async {
  emit(BasketLoading());

  try {
    await repository.addToBasket(event.product);

    // Fetch the updated basket from the backend
    final updatedBasket = await repository.getBasket();
    final totalItems = updatedBasket.values.fold<int>(
      0,
      (sum, item) => sum + (item['quantity'] as int? ?? 0),
    );

    emit(state.copyWith(basketItems: updatedBasket, totalItems: totalItems));
  } catch (e) {
    print('Error in _onAddToBasket: $e');
    emit(BasketError("Failed to add product to basket: ${e.toString()}"));
  }
}

  /// Handle removing a product from the basket
  Future<void> _onRemoveFromBasket(
      RemoveFromBasketEvent event, Emitter<BasketState> emit) async {
    emit(BasketLoading());

    try {
      await repository.removeFromBasket(event.productId);

      // Fetch the updated basket from the backend
      final updatedBasket = await repository.getBasket();
      final totalItems = updatedBasket.values.fold<int>(
        0,
        (sum, item) => sum + (item['quantity'] as int? ?? 0),
      );

      emit(state.copyWith(basketItems: updatedBasket, totalItems: totalItems));
    } catch (e) {
      emit(BasketError("Failed to remove product from basket: ${e.toString()}"));
    }
  }

  /// Handle clearing the basket
  Future<void> _onClearBasket(
      ClearBasketEvent event, Emitter<BasketState> emit) async {
    emit(BasketLoading());

    try {
      await repository.clearBasket();

      emit(state.copyWith(basketItems: {}, totalItems: 0));
    } catch (e) {
      emit(BasketError("Failed to clear basket: ${e.toString()}"));
    }
  }

  Future<void> _onPlaceOrder(PlaceOrderEvent event, Emitter<BasketState> emit) async {
    emit(BasketLoading());

    try {
      await repository.placeOrder(event.address);

      emit(state.copyWith(basketItems: {}, totalItems: 0));
      emit(OrderPlacedState(orderId: '12345')); // Replace with actual order ID
    } catch (e) {
      emit(BasketError("Failed to place order: $e"));
    }
  }
}
