import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:cash_control/bloc/blocs/courier_page_blocs/events/courier_document_event.dart';
import 'package:cash_control/bloc/blocs/courier_page_blocs/states/courier_document_state.dart';
import 'package:cash_control/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CourierDocumentBloc extends Bloc<CourierDocumentEvent, CourierDocumentState> {
  CourierDocumentBloc() : super(CourierDocumentInitial()) {
    on<FetchCourierDocumentsEvent>(_fetchCourierDocuments);
    on<SubmitCourierDocumentEvent>(_submitCourierDocument);

  }

  Future<void> _fetchCourierDocuments(
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
      Uri.parse(baseUrl + 'getCourierDocuments'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['orders'];

      // Filter out orders where `courier_document_id` is not null
      final filteredData = data.where((doc) => doc['courier_document_id'] == null).toList();

      emit(CourierDocumentLoaded(documents: filteredData));
    } else {
      emit(CourierDocumentError(error: "Failed to fetch documents."));
    }
  } catch (e) {
    emit(CourierDocumentError(error: e.toString()));
  }
}



  Future<void> _submitCourierDocument(
  SubmitCourierDocumentEvent event,
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

    final response = await http.post(
      Uri.parse(baseUrl + 'create_courier_document'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'courier_id': event.courierId,
        'orders': event.orders,
      }),
    );

    if (response.statusCode == 201) {
      emit(CourierDocumentSubmittedSuccess());
    } else {
      final error = jsonDecode(response.body)['error'] ?? "Unknown error.";
      emit(CourierDocumentError(error: error));
    }
  } catch (e) {
    emit(CourierDocumentError(error: e.toString()));
  }
}


}
