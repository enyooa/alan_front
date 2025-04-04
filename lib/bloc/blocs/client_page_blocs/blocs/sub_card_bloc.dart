import 'package:bloc/bloc.dart';
import 'package:alan/bloc/blocs/client_page_blocs/events/sub_card_event.dart';
import 'package:alan/bloc/blocs/client_page_blocs/states/sub_card_state.dart';

import 'package:alan/constant.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProductSubCardBloc extends Bloc<ProductSubCardEvent, ProductSubCardState> {
  ProductSubCardBloc() : super(ProductSubCardInitial()) {
    on<FetchProductSubCardsEvent>(_handleFetchProductSubCards);

  }


 Future<void> _handleFetchProductSubCards(
  FetchProductSubCardsEvent event,
  Emitter<ProductSubCardState> emit,
) async {
  emit(ProductSubCardLoading());
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.get(
      Uri.parse('${baseUrl}product_subcards_for_clientpage'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);

      // Safely map the response data
      final productSubCards = responseData.map((subCard) {
        return {
          'id': subCard['id'] ?? 0, // Default to 0 if `id` is null
          'name': subCard['name'] ?? 'Unnamed Subcard', // Default name if `name` is null
          'product_card_id': subCard['product_card_id'] ?? 0, // Default to 0 if `product_card_id` is null
        };
      }).toList();

      emit(ProductSubCardsLoaded(productSubCards));
    } else {
      emit(ProductSubCardError('Failed to load product subcards.'));
    }
  } catch (e) {
    emit(ProductSubCardError('Error: $e'));
  }
}

}
