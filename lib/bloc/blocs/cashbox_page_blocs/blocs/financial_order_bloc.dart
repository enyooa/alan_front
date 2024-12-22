import 'dart:convert';
import 'package:cash_control/bloc/blocs/cashbox_page_blocs/events/financial_order_event.dart';
import 'package:cash_control/bloc/blocs/cashbox_page_blocs/states/financial_order_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cash_control/constant.dart';

class FinancialOrderBloc extends Bloc<FinancialOrderEvent, FinancialOrderState> {
  FinancialOrderBloc() : super(FinancialOrderInitial()) {
    on<FetchFinancialOrdersEvent>(_fetchFinancialOrders);
    on<AddFinancialOrderEvent>(_addFinancialOrder);
  }

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<void> _fetchFinancialOrders(
    FetchFinancialOrdersEvent event, Emitter<FinancialOrderState> emit) async {
  emit(FinancialOrderLoading());
  try {
    final headers = await _getHeaders();

    // Fetch updated orders from API
    final response = await http.get(
      Uri.parse(baseUrl + 'financial-order'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final orders = data.cast<Map<String, dynamic>>();

      // Cache the orders for later use
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('financial_orders', jsonEncode(orders));

      emit(FinancialOrderLoaded(orders));
    } else {
      emit(FinancialOrderError('Failed to fetch orders'));
    }
  } catch (e) {
    emit(FinancialOrderError('Error: $e'));
  }
}



Future<void> _addFinancialOrder(
    AddFinancialOrderEvent event, Emitter<FinancialOrderState> emit) async {
  emit(FinancialOrderLoading());
  try {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse(baseUrl + 'financial-order'),
      headers: headers,
      body: jsonEncode(event.orderData),
    );

    if (response.statusCode == 201) {
      // Fetch the updated list of orders after creation
      add(FetchFinancialOrdersEvent());
      emit(FinancialOrderSaved());
    } else {
      final errorMessage =
          jsonDecode(response.body)['message'] ?? 'Failed to save financial order';
      emit(FinancialOrderError(errorMessage));
    }
  } catch (e) {
    emit(FinancialOrderError('An error occurred: $e'));
  }
}


Future<void> _editFinancialOrder(
    EditFinancialOrderEvent event, Emitter<FinancialOrderState> emit) async {
  emit(FinancialOrderLoading());
  try {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse(baseUrl + 'financial-order/${event.orderId}'),
      headers: headers,
      body: jsonEncode(event.updatedOrderData),
    );

    if (response.statusCode == 200) {
      if (state is FinancialOrderLoaded) {
        final currentOrders = (state as FinancialOrderLoaded).financialOrders;
        final updatedOrders = currentOrders.map((order) {
          if (order['id'] == event.orderId) {
            return {...order, ...event.updatedOrderData};
          }
          return order;
        }).toList();

        emit(FinancialOrderLoaded(updatedOrders));
      }
    } else {
      final errorMessage =
          jsonDecode(response.body)['message'] ?? 'Failed to edit financial order';
      emit(FinancialOrderError(errorMessage));
    }
  } catch (e) {
    emit(FinancialOrderError('An error occurred: $e'));
  }
}

Future<void> _deleteFinancialOrder(
    DeleteFinancialOrderEvent event, Emitter<FinancialOrderState> emit) async {
  emit(FinancialOrderLoading());
  try {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse(baseUrl + 'financial-order/${event.orderId}'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      if (state is FinancialOrderLoaded) {
        final currentOrders = (state as FinancialOrderLoaded).financialOrders;
        final updatedOrders = currentOrders
            .where((order) => order['id'] != event.orderId)
            .toList();

        emit(FinancialOrderLoaded(updatedOrders));
      }
    } else {
      final errorMessage =
          jsonDecode(response.body)['message'] ?? 'Failed to delete financial order';
      emit(FinancialOrderError(errorMessage));
    }
  } catch (e) {
    emit(FinancialOrderError('An error occurred: $e'));
  }
}


}
