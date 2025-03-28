import 'package:bloc/bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/events/product_subcard_event.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/states/product_subcard_state.dart';
import 'package:alan/constant.dart';
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
// product_subcard_bloc.dart

on<FetchSingleSubCardEvent>((event, emit) async {
  emit(ProductSubCardLoading());
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      emit(ProductSubCardError("Authentication token not found."));
      return;
    }

    // GET references/subproductCard/{id}
    final url = Uri.parse('${baseUrl}references/subproductCard/${event.id}');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // e.g. a single subcard object
      emit(SingleProductSubCardLoaded(data));
    } else {
      emit(ProductSubCardError('Failed to fetch subproductCard #${event.id}'));
    }
  } catch (e) {
    emit(ProductSubCardError('Error fetching subproductCard: $e'));
  }
});

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

      // Map the response to a list of subcards
      final productSubCards = responseData.map((subCard) {
        return {
          'id': subCard['id'],
          'name': subCard['name'],
          'product_card_id': subCard['product_card_id'],
          'remaining_quantity': subCard['remaining_quantity'], // Include the new field
          'unit_measurement': subCard['unit_measurement'],
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

    // product_subcard_bloc.dart, in _updateProductSubCard
    final response = await http.patch(
      Uri.parse('${baseUrl}references/subproductCard/${event.id}'),
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
