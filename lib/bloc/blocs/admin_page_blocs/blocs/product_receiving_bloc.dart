import 'dart:convert';
import 'package:cash_control/bloc/blocs/admin_page_blocs/events/product_receiving_event.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/states/product_receiving_state.dart';
import 'package:cash_control/constant.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductReceivingBloc extends Bloc<ProductReceivingEvent, ProductReceivingState> {
  ProductReceivingBloc() : super(ProductReceivingInitial()) {
    on<FetchProductReceivingEvent>(_fetchProductReceiving);
    on<CreateProductReceivingEvent>(_createProductReceiving);
    on<CreateBulkProductReceivingEvent>(_createBulkProductReceiving);

  }

  Future<void> _fetchProductReceiving(
      FetchProductReceivingEvent event, Emitter<ProductReceivingState> emit) async {
    emit(ProductReceivingLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final roles = prefs.getStringList('roles') ?? [];

      if (token == null || !roles.contains('admin')) {
        emit(ProductReceivingError(message: "Access denied: Only admins can fetch receiving data."));
        return;
      }

      final response = await http.get(
        Uri.parse(baseUrl + 'admin_warehouses'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> rawData = jsonDecode(response.body);
        emit(ProductReceivingLoaded(
          productReceivingList: rawData.map((item) => item as Map<String, dynamic>).toList(),
        ));
      } else {
        emit(ProductReceivingError(message: "Failed to fetch product receiving data."));
      }
    } catch (e) {
      emit(ProductReceivingError(message: e.toString()));
    }
  }

  Future<void> _createProductReceiving(
  CreateProductReceivingEvent event, Emitter<ProductReceivingState> emit) async {
  emit(ProductReceivingLoading());

  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getInt('user_id'); // Fetch admin's ID

    if (token == null || userId == null) {
      emit(ProductReceivingError(message: "Authentication token or user ID not found."));
      return;
    }

    final response = await http.post(
      Uri.parse(baseUrl + 'admin_warehouses'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'organization_id': userId,
        'product_card_id': event.productCardId,
        'unit_measurement': event.unitMeasurement,
        'quantity': event.quantity,
        'price': event.price,
        'total_sum': event.totalSum,
        'date': event.date, // This will already be a formatted string
      }),
    );

    if (response.statusCode == 201) {
      emit(ProductReceivingCreated(message: "Товары успешно перенесены на склад!."));
    } else {
      final data = jsonDecode(response.body);
      emit(ProductReceivingError(
          message: data['message'] ?? "Ошибка при сохранении товара"));
    }
  } catch (error) {
    emit(ProductReceivingError(message: error.toString()));
  }
}


Future<void> _createBulkProductReceiving(
    CreateBulkProductReceivingEvent event, Emitter<ProductReceivingState> emit) async {
  emit(ProductReceivingLoading());

  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      emit(ProductReceivingError(message: "Authentication token not found."));
      return;
    }

    final response = await http.post(
      Uri.parse(baseUrl + 'receivingBulkStore'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'receivings': event.receivings}),
    );

    if (response.statusCode == 201) {
      emit(ProductReceivingCreated(message: "Все товары успешно добавлены в склад!"));
    } else {
      final errorData = jsonDecode(response.body);
      emit(ProductReceivingError(message: errorData['message'] ?? "Error saving bulk receiving."));
    }
  } catch (error) {
    emit(ProductReceivingError(message: error.toString()));
  }
}


}
