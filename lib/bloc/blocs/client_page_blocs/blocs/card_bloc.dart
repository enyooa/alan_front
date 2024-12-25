import 'dart:convert';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:cash_control/bloc/blocs/client_page_blocs/events/card_event.dart';
import 'package:cash_control/bloc/blocs/client_page_blocs/states/card_state.dart';
import 'package:cash_control/constant.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProductCardBloc extends Bloc<ProductCardEvent, ProductCardState> {
  ProductCardBloc() : super(ProductCardInitial()) {
    on<FetchProductCardsEvent>(_handleFetchProductCards);

  }


  Future<void> _handleFetchProductCards(
    FetchProductCardsEvent event,
    Emitter<ProductCardState> emit,
) async {
  emit(ProductCardLoading());
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    if (token.isEmpty) {
      emit(ProductCardError('Authentication token not found.'));
      return;
    }

    final uri = Uri.parse(baseUrl + 'product_cards_for_clientpage');
    final response = await http.get(uri, headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      final productCards = responseData.map((product) {
        return {
          'id': product['id'],
          'name_of_products': product['name_of_products'] ?? 'Unnamed Product',
          'description': product['description'] ?? '',
          'photo_url': product['photo_url'] ?? '',
        };
      }).toList();

      emit(ProductCardsLoaded(productCards));
    } else {
      emit(ProductCardError('Failed to fetch product cards.'));
    }
  } catch (e) {
    emit(ProductCardError('Error: $e'));
  }
}



}
