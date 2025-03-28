import 'dart:convert';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/events/product_card_event.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/states/product_card_state.dart';
import 'package:alan/constant.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProductCardBloc extends Bloc<ProductCardEvent, ProductCardState> {
  ProductCardBloc() : super(ProductCardInitial()) {
    on<CreateProductCardEvent>(_handleCreateProductCard);
    on<FetchProductCardsEvent>(_handleFetchProductCards);
    on<UpdateProductCardEvent>(_updateProductCard);
    on<DeleteProductCardEvent>(_deleteProductCard);
    // product_card_bloc.dart

// 5) FETCH SINGLE product card
on<FetchSingleProductCardEvent>((event, emit) async {
  emit(ProductCardLoading());
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      emit(ProductCardError('Authentication token not found.'));
      return;
    }

    // GET /references/productCard/{id}
    final url = Uri.parse(baseUrl + 'references/productCard/${event.id}');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body); // likely a single JSON object
      emit(SingleProductCardLoaded(data));
    } else {
      final errorBody = response.body;
      emit(ProductCardError(
        'Failed to fetch productCard #${event.id}: $errorBody',
      ));
    }
  } catch (e) {
    emit(ProductCardError(
      'Error fetching productCard #${event.id}: $e',
    ));
  }
});


  }

  // ========== 1) CREATE ==========
  Future<void> _handleCreateProductCard(
    CreateProductCardEvent event,
    Emitter<ProductCardState> emit,
  ) async {
    emit(ProductCardLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final uri = Uri.parse(baseUrl + 'product_card_create');
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

  // ========== 2) FETCH ==========
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

      final uri = Uri.parse(baseUrl + 'product_cards');
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

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

  // ========== 3) UPDATE ==========
  Future<void> _updateProductCard(
    UpdateProductCardEvent event,
    Emitter<ProductCardState> emit,
  ) async {
    emit(ProductCardLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        emit(ProductCardError('Authentication token not found.'));
        return;
      }

      // 1) Build the URL to PATCH references/productCard/{id}
      final uri = Uri.parse(baseUrl + 'references/productCard/${event.id}');

      // 2) Use POST + _method=PATCH for multipart data
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['_method'] = 'PATCH'; // <--- Key line: inform Laravel it's a PATCH

      // 3) Add all updated text fields
      event.updatedFields.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });

      // 4) If there's an image file, add it
      if (event.photoFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'photo_product',
            event.photoFile!.path,
          ),
        );
      }

      // 5) Send the request
      final response = await request.send();

      // 6) Evaluate result
      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        emit(ProductCardCreated('Карточки товара обновлены!'));
      } else {
        final respStr = await response.stream.bytesToString();
        emit(ProductCardError('Ошибка при сохранении карточек товара'));
      }
    } catch (e) {
      emit(ProductCardError('Error: $e'));
    }
  }

  // ========== 4) DELETE ==========
  Future<void> _deleteProductCard(
    DeleteProductCardEvent event,
    Emitter<ProductCardState> emit,
  ) async {
    emit(ProductCardLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        emit(ProductCardError("Authentication token not found."));
        return;
      }

      // Example delete endpoint: product_cards/{id}
      final response = await http.delete(
        Uri.parse('{$baseUrl}product_cards/${event.id}'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        emit(ProductCardCreated("Product card deleted successfully."));
      } else {
        final errorData = jsonDecode(response.body);
        emit(ProductCardError(
          errorData['message'] ?? "Failed to delete product card.",
        ));
      }
    } catch (error) {
      emit(ProductCardError("Error: $error"));
    }
  }
}
