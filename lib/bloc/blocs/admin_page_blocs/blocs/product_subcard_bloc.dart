import 'package:bloc/bloc.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/events/product_subcard_event.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/states/product_subcard_state.dart';
import 'package:cash_control/constant.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProductSubCardBloc extends Bloc<ProductSubCardEvent, ProductSubCardState> {
  ProductSubCardBloc() : super(ProductSubCardInitial()) {
    on<CreateProductSubCardEvent>(_handleCreateProductSubCard);
    on<FetchProductSubCardsEvent>(_handleFetchProductSubCards);
    on<UpdateProductSubCardEvent>(_updateProductSubCard);
    on<DeleteProductSubCardEvent>(_deleteProductSubCard);
  }

  Future<void> _handleCreateProductSubCard(
    CreateProductSubCardEvent event,
    Emitter<ProductSubCardState> emit,
  ) async {
    emit(ProductSubCardLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final uri = Uri.parse(baseUrl+'product_subcards');
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'product_card_id': event.productCardId,
          'name': event.name,
          'brutto': event.brutto,
          'netto': event.netto,
        }),
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        emit(ProductSubCardCreated('Подкарточка успешно создано!'));
      } else {
        final responseData = json.decode(response.body);
        emit(ProductSubCardError('Error: ${responseData['error']}'));
      }
    } catch (e) {
      emit(ProductSubCardError('Failed to create product subcard: $e'));
    }
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
      Uri.parse('${baseUrl}product_subcards'),
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

Future<void> _updateProductSubCard(
  UpdateProductSubCardEvent event,
  Emitter<ProductSubCardState> emit,
) async {
  emit(ProductSubCardLoading());
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      emit(ProductSubCardError("Authentication token not found."));
      return;
    }

    final response = await http.put(
      Uri.parse('$baseUrl/product_subcards/${event.id}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(event.updatedFields),
    );

    if (response.statusCode == 200) {
      emit(ProductSubCardUpdated(message: "Подкарточка успешно обновлена!"));
    } else {
      final errorData = jsonDecode(response.body);
      emit(ProductSubCardError(errorData['message'] ?? "Ошибка обновления."));
    }
  } catch (error) {
    emit(ProductSubCardError("Ошибка: $error"));
  }
}


  Future<void> _deleteProductSubCard(
    DeleteProductSubCardEvent event,
    Emitter<ProductSubCardState> emit,
  ) async {
    emit(ProductSubCardLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        emit(ProductSubCardError("Authentication token not found."));
        return;
      }

      final response = await http.delete(
        Uri.parse('{$baseUrl}product_subcards/${event.id}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        emit(ProductSubCardDeleted(message: "Подкарточка успешно удалена!"));
      } else {
        final errorData = jsonDecode(response.body);
        emit(ProductSubCardError( errorData['message'] ?? "Ошибка удаления."));
      }
    } catch (error) {
      emit(ProductSubCardError("Ошибка: $error"));
    }
  }
}
