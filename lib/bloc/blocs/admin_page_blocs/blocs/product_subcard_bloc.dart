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
}
