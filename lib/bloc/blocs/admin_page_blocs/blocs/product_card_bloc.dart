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
    on<FetchProductCardsEvent>(_fetchProductCards);
  }

  // Create Product Card
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
          'photo_product',
          event.photoProduct!.path,
        ));
      }

      final response = await request.send();

      if (response.statusCode == 201) {
        emit(ProductCardSuccess("Карточка товара успешно создано."));
      } else {
        final responseBody = await response.stream.bytesToString();
        final errorData = jsonDecode(responseBody);
        emit(ProductCardError(errorData['message'] ?? "Failed to create product card."));
      }
    } catch (e) {
      emit(ProductCardError("Error: $e"));
    }
  }

  // Fetch Product Cards
  Future<void> _fetchProductCards(
      FetchProductCardsEvent event, Emitter<ProductCardState> emit) async {
    emit(ProductCardLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        emit(ProductCardError("Authentication token not found."));
        return;
      }

      final response = await http.get(
        Uri.parse(baseUrl + 'product_cards'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final productCards = data.map((json) => ProductCard.fromJson(json)).toList();
        emit(ProductCardLoaded(productCards: productCards));
      } else {
        emit(ProductCardError("Failed to fetch product cards."));
      }
    } catch (e) {
      emit(ProductCardError("Error: $e"));
    }
  }
}

// Model for ProductCard (if not already implemented)
class ProductCard {
  final int id;
  final String nameOfProducts;

  ProductCard({required this.id, required this.nameOfProducts});

  factory ProductCard.fromJson(Map<String, dynamic> json) {
    return ProductCard(
      id: json['id'],
      nameOfProducts: json['name_of_products'],
    );
  }
}
