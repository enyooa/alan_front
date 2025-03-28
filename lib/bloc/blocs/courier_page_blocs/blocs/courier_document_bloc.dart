import 'dart:convert';
import 'package:alan/bloc/blocs/courier_page_blocs/events/courier_document_event.dart';
import 'package:alan/bloc/blocs/courier_page_blocs/states/courier_document_state.dart';
import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:alan/constant.dart';

class CourierDocumentBloc extends Bloc<CourierDocumentEvent, CourierDocumentState> {
  CourierDocumentBloc() : super(CourierDocumentInitial()) {
    on<SubmitCourierDocumentEvent>(_onSubmitCourierData);
    on<FetchCourierDocumentsEvent>(_onFetchCourierDocuments);
  }

  /// [storeCourierData] call: updating order->courier_id, status_id, 
  /// and each order_item->courier_quantity, with no separate "courier docs."
  Future<void> _onSubmitCourierData(
    SubmitCourierDocumentEvent event,
    Emitter<CourierDocumentState> emit,
  ) async {
    emit(CourierDocumentLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        emit(CourierDocumentError(error: 'Authentication token not found.'));
        return;
      }

      // Post to your new endpoint: storeCourierData
      final response = await http.post(
        Uri.parse(baseUrl + 'storeCourierDocument'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'order_id': event.orderId,
          'products': event.orderProducts,
        }),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        emit(CourierDocumentSubmitted(
          message: responseData['message'] ?? 'Courier data updated successfully.',
        ));
      } else {
        final responseData = jsonDecode(response.body);
        emit(CourierDocumentError(
          error: responseData['error'] ?? 'Failed to update courier data.',
        ));
      }
    } catch (e) {
      emit(CourierDocumentError(error: e.toString()));
    }
  }

  /// If you still need to fetch "courier documents" from the server, 
  /// you can keep or remove this method
  Future<void> _onFetchCourierDocuments(
    FetchCourierDocumentsEvent event,
    Emitter<CourierDocumentState> emit,
  ) async {
    emit(CourierDocumentLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        emit(CourierDocumentError(error: "Authentication token not found."));
        return;
      }

      final response = await http.get(
        Uri.parse(baseUrl + 'get_Courier_document'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        emit(CourierDocumentsFetched(documents: data));
      } else {
        final errorData = jsonDecode(response.body);
        emit(CourierDocumentError(error: errorData['error'] ?? 'Failed to fetch documents.'));
      }
    } catch (e) {
      emit(CourierDocumentError(error: e.toString()));
    }
  }
}
