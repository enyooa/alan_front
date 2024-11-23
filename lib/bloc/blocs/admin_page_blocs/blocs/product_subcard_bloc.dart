import 'dart:convert';
import 'package:cash_control/bloc/blocs/admin_page_blocs/events/product_subcard_event.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/states/product_subcard_state.dart';
import 'package:cash_control/ui/main/models/product_subcard.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cash_control/constant.dart';

class ProductSubCardBloc extends Bloc<ProductSubCardEvent, ProductSubCardState> {
  ProductSubCardBloc() : super(ProductSubCardInitial()) {
    on<FetchProductSubCardsEvent>(_fetchProductSubCards);
    on<CreateProductSubCardEvent>(_createProductSubCard);
  }

  Future<void> _fetchProductSubCards(
      FetchProductSubCardsEvent event, Emitter<ProductSubCardState> emit) async {
    emit(ProductSubCardLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        throw Exception("Authentication token not found.");
      }

      final response = await http.get(
        Uri.parse(baseUrl + 'product_subcards'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
       final List<dynamic> data = jsonDecode(response.body);
final List<ProductSubCard> subcards = data
    .map((json) => ProductSubCard.fromJson(json as Map<String, dynamic>))
    .toList();
emit(ProductSubCardsLoaded(subcards));

      } else {
        throw Exception("Failed to fetch product subcards");
      }
    } catch (e) {
      emit(ProductSubCardError(e.toString()));
    }
  }

  Future<void> _createProductSubCard(
      CreateProductSubCardEvent event, Emitter<ProductSubCardState> emit) async {
    emit(ProductSubCardLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        throw Exception("Authentication token not found.");
      }

      final response = await http.post(
        Uri.parse(baseUrl + 'product_subcards'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode({
          'product_card_id': event.productCardId,
          'quantity_sold': event.quantitySold,
          'price_at_sale': event.priceAtSale,
        }),
      );
print("Response status: ${response.statusCode}");
print("Response body: ${response.body}");
      if (response.statusCode == 201) {
        emit(ProductSubCardSuccess("Подкарточка успешно создана"));
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        emit(ProductSubCardError(errorData['message'] ?? "Не удалось создать подкарточку"));
      }
    } catch (e) {
      emit(ProductSubCardError(e.toString()));
    }
  }
}
