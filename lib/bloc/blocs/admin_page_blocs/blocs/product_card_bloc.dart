import 'dart:convert';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/events/product_card_event.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/states/product_card_state.dart';
import 'package:cash_control/constant.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

class ProductCardBloc extends Bloc<ProductCardEvent, ProductCardState> {
  ProductCardBloc() : super(ProductCardInitial()) {
    on<CreateProductCardEvent>(_createProductCard);
  }

  Future<void> _createProductCard(
      CreateProductCardEvent event, Emitter<ProductCardState> emit) async {
    emit(ProductCardLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        emit(ProductCardError("Authentication token not found."));
        return;
      }

      final uri = Uri.parse(baseUrl+'product_card_create');
      final request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['name_of_products'] = event.nameOfProducts;
      request.fields['description'] = event.description ?? '';
      request.fields['country'] = event.country ?? '';
      request.fields['type'] = event.type ?? '';
      request.fields['brutto'] = event.brutto.toString();
      request.fields['netto'] = event.netto.toString();

      if (event.photoProduct != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'photo_product',
          event.photoProduct!.path,
        ));
      }

      final response = await request.send();

      if (response.statusCode == 201) {
        emit(ProductCardSuccess("Product card created successfully."));
      } else {
        final responseBody = await response.stream.bytesToString();
        final errorData = jsonDecode(responseBody);
        emit(ProductCardError(errorData['message'] ?? "Failed to create product card."));
      }
    } catch (e) {
      emit(ProductCardError("Error: $e"));
    }
  }
}
