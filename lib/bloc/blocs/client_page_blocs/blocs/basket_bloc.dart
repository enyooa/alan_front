import 'package:bloc/bloc.dart';
import 'package:cash_control/bloc/blocs/client_page_blocs/events/basket_event.dart';
import 'package:cash_control/bloc/blocs/client_page_blocs/states/basket_state.dart';
import 'package:cash_control/bloc/blocs/client_page_blocs/repositories/basket_repository.dart';
import 'package:equatable/equatable.dart';

class BasketBloc extends Bloc<BasketEvent, BasketState> {
  final BasketRepository repository;

  BasketBloc({required this.repository}) : super(const BasketState()) {
    on<FetchBasketEvent>(_onFetchBasket);
    on<AddToBasketEvent>(_onAddToBasket);
    on<RemoveFromBasketEvent>(_onRemoveFromBasket);
    on<ClearBasketEvent>(_onClearBasket);
    on<PlaceOrderEvent>(_onPlaceOrder);
  }

  Future<void> _onFetchBasket(FetchBasketEvent event, Emitter<BasketState> emit) async {
  emit(BasketLoading());
  try {
    final basketItems = await repository.getBasket(); // List<BasketItem>
    final totalItems = basketItems.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );

    emit(state.copyWith(basketItems: basketItems, totalItems: totalItems));
  } catch (e) {
    emit(BasketError("Failed to fetch basket: ${e.toString()}"));
  }
}

  
  Future<void> _onAddToBasket(
      AddToBasketEvent event, Emitter<BasketState> emit) async {
    try {
      await repository.addToBasket(event.product);
      add(FetchBasketEvent());
    } catch (e) {
      emit(BasketError("Failed to add product: ${e.toString()}"));
    }
  }

  Future<void> _onRemoveFromBasket(
      RemoveFromBasketEvent event, Emitter<BasketState> emit) async {
    try {
      await repository.removeFromBasket(event.productId);
      add(FetchBasketEvent());
    } catch (e) {
      emit(BasketError("Failed to remove product: ${e.toString()}"));
    }
  }

Future<void> _onClearBasket(ClearBasketEvent event, Emitter<BasketState> emit) async {
  emit(BasketLoading());
  try {
    await repository.clearBasket();
    emit(state.copyWith(basketItems: [], totalItems: 0)); // Use an empty list
  } catch (e) {
    emit(BasketError("Failed to clear basket: ${e.toString()}"));
  }
}


 Future<void> _onPlaceOrder(
    PlaceOrderEvent event, Emitter<BasketState> emit) async {
  emit(BasketLoading());

  try {
    final orderId = await repository.placeOrder(event.address); // Get the order ID

    // Clear the basket state
    emit(state.copyWith(basketItems: [], totalItems: 0)); // Use an empty list

    // Emit the OrderPlacedState with the order ID
    emit(OrderPlacedState(orderId: orderId));
  } catch (e) {
    emit(BasketError("Failed to place order: $e"));
  }
}


}
