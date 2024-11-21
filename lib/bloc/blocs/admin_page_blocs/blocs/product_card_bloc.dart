import 'dart:convert';
import 'dart:io';
import 'package:cash_control/bloc/blocs/admin_page_blocs/events/product_card_event.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/states/product_card_state.dart';
import 'package:cash_control/constant.dart';
import 'package:cash_control/ui/main/models/product_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProductCardBloc extends Bloc<ProductCardEvent, ProductCardState> {
  ProductCardBloc() : super(ProductInitial()) {
    on<FetchProductCardsEvent>(_fetchProductCards);
    on<CreateProductCardEvent>(_createProductCard);
  }

  Future<void> _fetchProductCards(
      FetchProductCardsEvent event, Emitter<ProductCardState> emit) async {
    emit(ProductLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final roles = prefs.getStringList('roles') ?? [];

      // Check if the user is authenticated and has an admin role
      if (token == null || !roles.contains('admin')) {
        emit(ProductCardError(message: "Access denied: Only admins can fetch product cards."));
        return;
      }

      final response = await http.get(
        Uri.parse(baseUrl + 'product_cards'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> rawData = jsonDecode(response.body);
        final products =
            rawData.map((e) => ProductCard.fromJson(e as Map<String, dynamic>)).toList();
        emit(ProductCardLoaded(products: products));
      } else {
        emit(ProductCardError(message: "Failed to fetch product cards"));
      }
    } catch (e) {
      emit(ProductCardError(message: e.toString()));
    }
  }

  Future<void> _createProductCard(
      CreateProductCardEvent event, Emitter<ProductCardState> emit) async {
    emit(ProductLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        emit(ProductCardError(message: "Authentication token not found"));
        return;
      }

      final uri = Uri.parse(baseUrl + 'product_card_create');
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
            'photo_product', event.photoProduct!.path));
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        emit(ProductCardCreated(message: "Product card created successfully"));
      } else {
        final data = jsonDecode(responseBody);
        emit(ProductCardError(message: data['message'] ?? "Failed to create product card"));
      }
    } catch (e) {
      emit(ProductCardError(message: e.toString()));
    }
  }
}
