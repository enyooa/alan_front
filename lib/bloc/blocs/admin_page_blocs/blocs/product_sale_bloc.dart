import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/events/product_sale_event.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/states/product_sale_state.dart';

import 'package:alan/constant.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SalesBloc extends Bloc<SalesEvent, SalesState> {
  SalesBloc() : super(SalesInitial()) {
    on<CreateSalesEvent>(_createSales);
    on<CreateMultipleSalesEvent>(_createBulkSales);
    on<FetchSalesWithDetailsEvent>(_fetchSalesWithDetails);
    on<UpdateSalesEvent>(_updateSales);
    on<DeleteSalesEvent>(_deleteSales);
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

 Future<void> _createBulkSales(
    CreateMultipleSalesEvent event, Emitter<SalesState> emit) async {
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
      emit(SalesError(
          message: errorData['message'] ?? "Ошибка при создании продаж."));
    }
  } catch (error) {
    emit(SalesError(message: "Ошибка: $error"));
  }
}


  Future<void> _fetchSalesWithDetails(
      FetchSalesWithDetailsEvent event, Emitter<SalesState> emit) async {
    emit(SalesLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        emit(SalesError(message: "Authentication token not found."));
        return;
      }

      final response = await http.get(
        Uri.parse(baseUrl + 'getSalesWithDetails'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> rawData = jsonDecode(response.body);
        emit(SalesLoadedWithDetails(
          salesDetails: rawData
              .map((item) => item as Map<String, dynamic>)
              .toList(),
        ));
      } else {
        emit(SalesError(message: "Failed to fetch sales details."));
      }
    } catch (e) {
      emit(SalesError(message: e.toString()));
    }
  }



Future<void> _updateSales(UpdateSalesEvent event, Emitter<SalesState> emit) async {
  emit(SalesLoading());
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      emit(SalesError(message: "Authentication token not found."));
      return;
    }

    final response = await http.put(
      Uri.parse('{$baseUrl}sales/${event.id}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(event.updatedFields),
    );

    if (response.statusCode == 200) {
      emit(SalesUpdated(message: "Sale updated successfully."));
    } else {
      final errorData = jsonDecode(response.body);
      emit(SalesError(message: errorData['message'] ?? "Failed to update sale."));
    }
  } catch (error) {
    emit(SalesError(message: "Error: $error"));
  }
}




Future<void> _deleteSales(DeleteSalesEvent event, Emitter<SalesState> emit) async {
  emit(SalesLoading());

  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      emit(SalesError(message: "Authentication token not found."));
      return;
    }

    final response = await http.delete(
      Uri.parse('{$baseUrl}sales/${event.id}'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      emit(SalesCreated(message: "Продажи успешно удалены!"));
    } else {
      final errorData = jsonDecode(response.body);
      emit(SalesError(message: errorData['message'] ?? "Failed to delete sale."));
    }
  } catch (error) {
    emit(SalesError(message: "Error: $error"));
  }
}

}
