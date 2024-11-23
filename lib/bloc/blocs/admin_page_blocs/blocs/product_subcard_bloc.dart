import 'package:cash_control/bloc/blocs/admin_page_blocs/events/product_subcard_event.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/states/product_subcard_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cash_control/constant.dart';

class ProductSubCardBloc extends Bloc<ProductSubCardEvent, ProductSubCardState> {
  ProductSubCardBloc() : super(ProductSubCardInitial()) {
    on<CreateProductSubCardEvent>(_onCreateProductSubCard);
  }

  Future<void> _onCreateProductSubCard(
      CreateProductSubCardEvent event, Emitter<ProductSubCardState> emit) async {
    emit(ProductSubCardLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        emit(ProductSubCardError("Authentication token not found."));
        return;
      }

      final response = await http.post(
        Uri.parse(baseUrl + 'product_sub_cards'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'product_card_id': event.productCardId,
          'client_id': event.clientId,
          'quantity_sold': event.quantitySold,
          'price_at_sale': event.priceAtSale,
        }),
      );

      if (response.statusCode == 201) {
        emit(ProductSubCardCreated("Sub-product created successfully."));
      } else {
        final data = jsonDecode(response.body);
        emit(ProductSubCardError(data['message'] ?? "Failed to create sub-product."));
      }
    } catch (e) {
      emit(ProductSubCardError(e.toString()));
    }
  }
}
