import 'dart:convert';
import 'package:alan/bloc/blocs/admin_page_blocs/events/product_receiving_event.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/states/product_receiving_state.dart';
import 'package:alan/constant.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductReceivingBloc extends Bloc<ProductReceivingEvent, ProductReceivingState> {
  ProductReceivingBloc() : super(ProductReceivingInitial()) {
    on<FetchProductReceivingEvent>(_fetchProductReceiving);
    on<CreateProductReceivingEvent>(_createProductReceiving);
    on<CreateBulkProductReceivingEvent>(_createBulkProductReceiving);
    on<UpdateProductReceivingEvent>(_updateProductReceiving);

on<FetchSingleProductReceivingEvent>(_fetchSingleProductReceiving);

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
    

    final response = await http.post(
      Uri.parse(baseUrl + 'admin_warehouses'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        
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
    CreateBulkProductReceivingEvent event,
    Emitter<ProductReceivingState> emit,
  ) async {
    emit(ProductReceivingLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        emit(ProductReceivingError(message: "Authentication token not found."));
        return;
      }

      final response = await http.post(
        Uri.parse(baseUrl + 'storeIncomes'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'receivings': event.receivings}),
      );

      if (response.statusCode == 201) {
        emit(ProductReceivingCreated(
          message: "Все товары успешно добавлены в склад!",
        ));
      } else {
        final errorData = jsonDecode(response.body);
        emit(ProductReceivingError(
          message: errorData['message'] ?? "Error saving bulk receiving.",
        ));
      }
    } catch (error) {
      emit(ProductReceivingError(message: error.toString()));
    }
  }


// 2) Update existing doc
Future<void> _updateProductReceiving(
  UpdateProductReceivingEvent event,
  Emitter<ProductReceivingState> emit,
) async {
  emit(ProductReceivingLoading());
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      emit(ProductReceivingError(message: "No token found."));
      return;
    }

    // e.g. 'updateIncome' or 'updateReceipt/ID' endpoint
      final updateUrl = Uri.parse('${baseUrl}updateIncome/${event.docId}');
    final response = await http.put(
      updateUrl,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(event.updatedData),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      emit(ProductReceivingUpdated(data['message'] ?? 'Документ успешно обновлён!'));
    } else {
      final err = jsonDecode(response.body);
      emit(ProductReceivingError(
        message: err['error'] ?? 'Ошибка обновления документа',
      ));
    }
  } catch (e) {
    emit(ProductReceivingError(message: e.toString()));
  }
}


Future<void> _fetchSingleProductReceiving(
  FetchSingleProductReceivingEvent event,
  Emitter<ProductReceivingState> emit,
) async {
  emit(ProductReceivingLoading());
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      emit(ProductReceivingError(message: "No token found."));
      return;
    }

    // 1) Fetch the doc itself, e.g. GET /api/incomes/{event.docId} 
    //    or whatever your endpoint is:
    final docResponse = await http.get(
      Uri.parse(baseUrl + 'documents/${event.docId}'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (docResponse.statusCode != 200) {
      final errBody = jsonDecode(docResponse.body);
      throw Exception(errBody['message'] ?? 'Failed to load doc #${event.docId}');
    }
    final docData = jsonDecode(docResponse.body);

    // 2) Fetch references if needed (providers, warehouses, subcards, units, expenses).
    //    Or if you already have separate BLoCs for them, you can skip here.
    final refResponse = await http.get(
      Uri.parse(baseUrl+'getWarehouseDetails'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (refResponse.statusCode != 200) {
      throw Exception('Failed to load references for editing');
    }
    final refData = jsonDecode(refResponse.body);

    // 3) Emit loaded state
    emit(ProductReceivingSingleLoaded(
      document: docData,
      providers: refData['providers'] ?? [],
      warehouses: refData['warehouses'] ?? [],
      productSubCards: refData['product_sub_cards'] ?? [],
      unitMeasurements: refData['unit_measurements'] ?? [],
      expenses: refData['expenses'] ?? [],
    ));
  } catch (e) {
    emit(ProductReceivingError(message: e.toString()));
  }
}
}
