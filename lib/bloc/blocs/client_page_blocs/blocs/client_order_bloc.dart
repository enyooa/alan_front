import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:alan/bloc/blocs/client_page_blocs/events/client_order_event.dart';
import 'package:alan/bloc/blocs/client_page_blocs/states/client_order_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:alan/constant.dart';

class ClientOrderBloc extends Bloc<ClientOrderEvent, ClientOrderState> {
  ClientOrderBloc() : super(ClientOrderInitial()) {
    on<FetchClientOrdersEvent>(_onFetchClientOrders);
    on<ConfirmClientOrderEvent>(_onConfirmClientOrder);
  }

  Future<void> _onFetchClientOrders(
    FetchClientOrdersEvent event,
    Emitter<ClientOrderState> emit,
  ) async {
    emit(ClientOrderLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        emit(const ClientOrderError("No authentication token found."));
        return;
      }

      // Example endpoint: GET /api/getClientOrders
      final response = await http.get(
        Uri.parse('${baseUrl}client-orders'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // We expect an array of orders
        final data = jsonDecode(response.body);
        final List<Map<String, dynamic>> orders =
            List<Map<String, dynamic>>.from(data);
        emit(ClientOrdersFetched(orders));
      } else {
        final errorData = jsonDecode(response.body);
        emit(ClientOrderError(errorData['error'] ?? 'Failed to fetch orders'));
      }
    } catch (e) {
      emit(ClientOrderError(e.toString()));
    }
  }

  Future<void> _onConfirmClientOrder(
    ConfirmClientOrderEvent event,
    Emitter<ClientOrderState> emit,
  ) async {
    emit(ClientOrderLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        emit(const ClientOrderError("No token found."));
        return;
      }

      // Example endpoint: PUT /api/orders/{orderId}/confirm
      final response = await http.put(
        Uri.parse('${baseUrl}orders/${event.orderId}/confirm'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        emit(ClientOrderConfirmed(data['message'] ?? 'Order confirmed.'));
      } else {
        final errorData = jsonDecode(response.body);
        emit(ClientOrderError(errorData['error'] ?? 'Failed to confirm.'));
      }
    } catch (e) {
      emit(ClientOrderError(e.toString()));
    }
  }
}
