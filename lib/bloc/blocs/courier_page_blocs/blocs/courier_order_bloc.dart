import 'dart:convert';
import 'package:alan/bloc/blocs/courier_page_blocs/events/courier_order_event.dart';
import 'package:alan/bloc/blocs/courier_page_blocs/states/courier_order_state.dart';
import 'package:bloc/bloc.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CourierOrdersBloc extends Bloc<CourierOrdersEvent, CourierOrdersState> {
  final String baseUrl;

  CourierOrdersBloc({required this.baseUrl}) : super(CourierOrdersInitial()) {
    on<FetchCourierOrdersEvent>(_fetchCourierOrders);
    on<FetchSingleOrderEvent>(_fetchSingleOrder);
    on<UpdateOrderDetailsEvent>(_updateOrderDetails);
  }
Future<void> _fetchCourierOrders(
      FetchCourierOrdersEvent event, Emitter<CourierOrdersState> emit) async {
    emit(CourierOrdersLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        emit(CourierOrdersError(message: "Authentication token not found."));
        return;
      }

      final response = await http.get(
        Uri.parse(baseUrl + 'getCourierOrders'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
  final json = jsonDecode(response.body) as Map<String, dynamic>;
  
  // Parse orders
  final List<dynamic> ordersData = json['orders'];
  final orders = ordersData.map((e) => Map<String, dynamic>.from(e)).toList();

  // Parse statuses
  final List<dynamic> statusesData = json['statuses'];
  final statuses = statusesData.map((s) => Map<String, dynamic>.from(s)).toList();

  // Modify your loaded state to include statuses
  emit(CourierOrdersLoaded(
    orders: orders,
    statuses: statuses,
  ));
} 

    } catch (e) {
      emit(CourierOrdersError(message: e.toString()));
    }
  }


  Future<void> _fetchSingleOrder(
      FetchSingleOrderEvent event, Emitter<CourierOrdersState> emit) async {
    emit(SingleOrderLoading());
    print('Fetching details for order ID: ${event.orderId}');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        emit(CourierOrdersError(message: "Authentication token not found."));
        return;
      }

      final response = await http.get(
        Uri.parse(baseUrl + 'courier/orders/${event.orderId}'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = Map<String, dynamic>.from(jsonDecode(response.body)['data']);
        print('Fetched order details: $data');
        emit(SingleOrderLoaded(orderDetails: data));
      } else {
        emit(CourierOrdersError(message: "Failed to fetch order details."));
        print('Error fetching order details: ${response.body}');
      }
    } catch (e) {
      emit(CourierOrdersError(message: e.toString()));
      print('Exception occurred: $e');
    }
  }

  Future<void>
_updateOrderDetails(UpdateOrderDetailsEvent event, Emitter<CourierOrdersState> emit) async {
    emit(UpdateOrderLoading());
    print('Updating order ID: ${event.orderId} with products: ${event.updatedProducts}');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      print('Token: $token');

      if (token == null) {
        emit(UpdateOrderError(message: "Authentication token not found."));
        print('Authentication token not found.');
        return;
      }

      final response = await http.put(
        Uri.parse(baseUrl + 'Courier/orders/${event.orderId}/products'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'products': event.updatedProducts}),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final message = jsonDecode(response.body)['message'] ?? "Order updated successfully.";
        emit(UpdateOrderSuccess(message: message));
        print('Order update successful: $message');
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? "Failed to update order.";
        emit(UpdateOrderError(message: errorMessage));
        print('Error updating order: ${response.body}');
      }
    } catch (e) {
      emit(UpdateOrderError(message: e.toString()));
      print('Exception occurred: $e');
    }
  }
}
