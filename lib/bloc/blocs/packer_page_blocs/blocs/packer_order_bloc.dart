import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:cash_control/bloc/blocs/packer_page_blocs/events/packer_order_event.dart';
import 'package:cash_control/bloc/blocs/packer_page_blocs/states/packer_order_state.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PackerOrdersBloc extends Bloc<PackerOrdersEvent, PackerOrdersState> {
  final String baseUrl;

  PackerOrdersBloc({required this.baseUrl}) : super(PackerOrdersInitial()) {
    on<FetchPackerOrdersEvent>(_fetchPackerOrders);
    on<FetchSingleOrderEvent>(_fetchSingleOrder);
    on<UpdateOrderDetailsEvent>(_updateOrderDetails);
  }

  Future<void> _fetchPackerOrders(
      FetchPackerOrdersEvent event, Emitter<PackerOrdersState> emit) async {
    emit(PackerOrdersLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        emit(PackerOrdersError(message: "Authentication token not found."));
        return;
      }

      final response = await http.get(
        Uri.parse(baseUrl + 'packer/orders'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = List<Map<String, dynamic>>.from(
            jsonDecode(response.body)['orders']);
        emit(PackerOrdersLoaded(orders: data));
      } else {
        emit(PackerOrdersError(message: "Failed to fetch packer orders."));
      }
    } catch (e) {
      emit(PackerOrdersError(message: e.toString()));
    }
  }

  Future<void> _fetchSingleOrder(
      FetchSingleOrderEvent event, Emitter<PackerOrdersState> emit) async {
    emit(SingleOrderLoading());
    print('Fetching details for order ID: ${event.orderId}');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        emit(PackerOrdersError(message: "Authentication token not found."));
        return;
      }

      final response = await http.get(
        Uri.parse(baseUrl + 'packer/orders/${event.orderId}'),
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
        emit(PackerOrdersError(message: "Failed to fetch order details."));
        print('Error fetching order details: ${response.body}');
      }
    } catch (e) {
      emit(PackerOrdersError(message: e.toString()));
      print('Exception occurred: $e');
    }
  }

  Future<void>
_updateOrderDetails(UpdateOrderDetailsEvent event, Emitter<PackerOrdersState> emit) async {
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
        Uri.parse(baseUrl + 'packer/orders/${event.orderId}/products'),
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
