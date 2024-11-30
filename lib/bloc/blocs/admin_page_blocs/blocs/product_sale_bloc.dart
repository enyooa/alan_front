import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/events/product_sale_event.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/states/product_sale_state.dart';

import 'package:cash_control/constant.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SalesBloc extends Bloc<SalesEvent, SalesState> {
  SalesBloc() : super(SalesInitial()) {
    on<FetchSalesEvent>(_fetchSales);
    on<CreateSalesEvent>(_createSales);
    on<CreateMultipleSalesEvent>(_createBulkSales);

  }

  Future<void> _fetchSales(
      FetchSalesEvent event, Emitter<SalesState> emit) async {
    emit(SalesLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        emit(SalesError(message: "Authentication token not found."));
        return;
      }

      final response = await http.get(
        Uri.parse(baseUrl + 'sales'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> rawData = jsonDecode(response.body);
        emit(SalesLoaded(
          salesList: rawData.map((item) => item as Map<String, dynamic>).toList(),
        ));
      } else {
        emit(SalesError(message: "Failed to fetch sales data."));
      }
    } catch (e) {
      emit(SalesError(message: e.toString()));
    }
  }

  Future<void> _createSales(
      CreateSalesEvent event, Emitter<SalesState> emit) async {
    emit(SalesLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        emit(SalesError(message: "Authentication token not found."));
        return;
      }

      final response = await http.post(
        Uri.parse(baseUrl + 'sales'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'product_subcard_id': event.productSubcardId,
          'unit_measurement': event.unitMeasurement,
          'amount': event.amount,
          'price': event.price,
        }),
      );

      if (response.statusCode == 201) {
        emit(SalesCreated(message: "Продажа успешно создана!"));
      } else {
        final data = jsonDecode(response.body);
        emit(SalesError(
            message: data['message'] ?? "Не удалось создать на продажу."));
      }
    } catch (error) {
      emit(SalesError(message: error.toString()));
    }
  }

  Future<void> _createBulkSales(CreateMultipleSalesEvent event, Emitter<SalesState> emit) async {
    emit(SalesLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        emit(SalesError(message: "Authentication token not found."));
        return;
      }

      final response = await http.post(
        Uri.parse(baseUrl + 'bulk_sales'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'sales': event.sales}),
      );

      if (response.statusCode == 201) {
        emit(SalesCreated(message: "Продажи успешно созданы!"));
      } else {
        final errorData = jsonDecode(response.body);
        emit(SalesError(message: errorData['message'] ?? "Ошибка при создании продаж."));
      }
    } catch (error) {
      emit(SalesError(message: "Ошибка: $error"));
    }
  }
}
