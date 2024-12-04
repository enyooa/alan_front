import 'package:bloc/bloc.dart';
import 'package:cash_control/bloc/blocs/client_page_blocs/events/basket_event.dart';
import 'package:cash_control/bloc/blocs/client_page_blocs/states/basket_state.dart';
import 'package:equatable/equatable.dart';

class BasketBloc extends Bloc<BasketEvent, BasketState> {
  BasketBloc() : super(BasketState.initial()) {
    on<AddToBasketEvent>(_onAddToBasket);
    on<RemoveFromBasketEvent>(_onRemoveFromBasket);
    on<ClearBasketEvent>(_onClearBasket);
  }

  void _onAddToBasket(AddToBasketEvent event, Emitter<BasketState> emit) {
    final currentBasket = state.basketItems;
    final productId = event.product['id'].toString(); // Ensure productId is String

    // If the product is already in the basket, increment its quantity
    if (currentBasket.containsKey(productId)) {
      final updatedBasket = Map<String, Map<String, dynamic>>.from(currentBasket)
        ..update(productId, (existingProduct) {
          return {
            ...existingProduct,
            'quantity': existingProduct['quantity'] + 1,
          };
        });

      emit(state.copyWith(
        basketItems: updatedBasket,
        totalItems: state.totalItems + 1,
      ));
    } else {
      // Add the product to the basket with an initial quantity of 1
      final updatedBasket = Map<String, Map<String, dynamic>>.from(currentBasket)
        ..[productId] = {
          ...event.product,
          'quantity': 1,
        };

      emit(state.copyWith(
        basketItems: updatedBasket,
        totalItems: state.totalItems + 1,
      ));
    }
  }

  void _onRemoveFromBasket(RemoveFromBasketEvent event, Emitter<BasketState> emit) {
    final currentBasket = state.basketItems;
    final productId = event.productId.toString(); // Ensure productId is String

    if (currentBasket.containsKey(productId)) {
      final currentQuantity = currentBasket[productId]!['quantity'];

      if (currentQuantity > 1) {
        // Decrement the quantity if more than 1
        final updatedBasket = Map<String, Map<String, dynamic>>.from(currentBasket)
          ..update(productId, (existingProduct) {
            return {
              ...existingProduct,
              'quantity': currentQuantity - 1,
            };
          });

        emit(state.copyWith(
          basketItems: updatedBasket,
          totalItems: state.totalItems - 1,
        ));
      } else {
        // Remove the product from the basket if quantity is 1
        final updatedBasket = Map<String, Map<String, dynamic>>.from(currentBasket)
          ..remove(productId);

        emit(state.copyWith(
          basketItems: updatedBasket,
          totalItems: state.totalItems - 1,
        ));
      }
    }
  }

  void _onClearBasket(ClearBasketEvent event, Emitter<BasketState> emit) {
    emit(state.copyWith(basketItems: {}, totalItems: 0));
  }
}
