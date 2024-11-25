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
    on<CreateProductCardEvent>(_handleCreateProductCard);
    on<FetchProductCardsEvent>(_handleFetchProductCards);

  }

  Future<void> _handleCreateProductCard(
    CreateProductCardEvent event,
    Emitter<ProductCardState> emit,
  ) async {
    emit(ProductCardLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final uri = Uri.parse(baseUrl+'product_card_create');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['name_of_products'] = event.nameOfProducts;

      if (event.description != null) {
        request.fields['description'] = event.description!;
      }
      if (event.country != null) {
        request.fields['country'] = event.country!;
      }
      if (event.type != null) {
        request.fields['type'] = event.type!;
      }
      if (event.photoProduct != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'photo_product',
            event.photoProduct!.path,
          ),
        );
      }

      final response = await request.send();
      if (response.statusCode == 201) {
        emit(ProductCardCreated('Карточка товара успешно создана!'));
      } else {
        final responseData = await response.stream.bytesToString();
        emit(ProductCardError('Error: $responseData'));
      }
    } catch (e) {
      emit(ProductCardError('Failed to create product card: $e'));
    }
  }

  Future<void> _handleFetchProductCards(
  FetchProductCardsEvent event,
  Emitter<ProductCardState> emit,
) async {
  emit(ProductCardLoading());
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    print('Token: $token');

    final uri = Uri.parse('${baseUrl}product_cards');
    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      print('Response Data: $responseData');

      final productCards = responseData.map((product) {
        return {
          'id': product['id'],
          'name': product['name_of_products'],
        };
      }).toList();

      emit(ProductCardsLoaded(productCards));
    } else {
      print('Error: ${response.statusCode}, ${response.body}');
      emit(ProductCardError('Failed to fetch product cards.'));
    }
  } catch (e) {
    print('Exception: $e');
    emit(ProductCardError('Error: $e'));
  }
}

}
