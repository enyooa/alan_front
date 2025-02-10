import 'dart:convert';
import 'package:alan/bloc/blocs/courier_page_blocs/events/courier_document_event.dart';
import 'package:alan/bloc/blocs/courier_page_blocs/states/courier_document_state.dart';
import 'package:bloc/bloc.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:alan/constant.dart';

class CourierDocumentBloc extends Bloc<CourierDocumentEvent, CourierDocumentState> {
  CourierDocumentBloc() : super(CourierDocumentInitial()) {
    on<SubmitCourierDocumentEvent>(_onSubmitCourierDocument);
     on<FetchCourierDocumentsEvent>(_onFetchCourierDocuments);
  }

Future<void> _onSubmitCourierDocument(
    SubmitCourierDocumentEvent event, Emitter<CourierDocumentState> emit) async {
  emit(CourierDocumentLoading());

  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      emit(CourierDocumentError(error: 'Authentication token not found.'));
      return;
    }

    final response = await http.post(
      Uri.parse(baseUrl + 'storeCourierDocument'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'delivery_address': event.deliveryAddress,
        'order_products': event.orderProducts,
        'order_id': event.orderId, // Include order_id in the payload
      }),
    );

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      emit(CourierDocumentSubmitted(message: responseData['message'] ?? 'Document created successfully.'));
    } else {
      final responseData = jsonDecode(response.body);
      emit(CourierDocumentError(error: responseData['error'] ?? 'Failed to create document.'));
    }
  } catch (e) {
    emit(CourierDocumentError(error: e.toString()));
  }
}


  Future<void> _onFetchCourierDocuments(
      FetchCourierDocumentsEvent event, Emitter<CourierDocumentState> emit) async {
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

  