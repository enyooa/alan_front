import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:alan/bloc/blocs/courier_page_blocs/events/invoice_event.dart';
import 'package:alan/bloc/blocs/courier_page_blocs/states/invoice_state.dart';
import 'package:alan/constant.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


class InvoiceBloc extends Bloc<InvoiceEvent, InvoiceState> {


  InvoiceBloc() : super(InvoiceInitial()) {
    on<FetchInvoiceOrders>(_fetchOrders);
    on<SubmitCourierDocument>(_submitCourierDocument);
  }

  Future<void> _fetchOrders(
    FetchInvoiceOrders event,
    Emitter<InvoiceState> emit,
  ) async {
    emit(InvoiceLoading());
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse(baseUrl+'getCourierDocuments'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        emit(InvoiceOrdersFetched(orders: data['orders']));
      } else {
        emit(InvoiceError(error: 'Failed to fetch orders'));
      }
    } catch (e) {
      emit(InvoiceError(error: e.toString()));
    }
  }

 Future<void> _submitCourierDocument(
  SubmitCourierDocument event,
  Emitter<InvoiceState> emit,
) async {
  emit(InvoiceSubmitting());
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    print('Token: $token');
    print('Submitting: order_id=${event.orderId}, products=${event.updatedProducts}');

    final response = await http.post(
      Uri.parse(baseUrl + 'storeCourierDocument'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'order_id': event.orderId,
        'products': event.updatedProducts,
      }),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 201) {
      emit(InvoiceSubmitted());
    } else {
      final errorResponse = jsonDecode(response.body);
      emit(InvoiceError(error: errorResponse['error'] ?? 'Unknown error'));
    }
  } catch (e) {
    print('Error: $e');
    emit(InvoiceError(error: e.toString()));
  }
}
}
