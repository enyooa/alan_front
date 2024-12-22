import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:cash_control/bloc/blocs/courier_page_blocs/events/courier_document_event.dart';
import 'package:cash_control/bloc/blocs/courier_page_blocs/states/courier_document_state.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:cash_control/constant.dart';

class CourierDocumentBloc extends Bloc<CourierDocumentEvent, CourierDocumentState> {
  CourierDocumentBloc() : super(CourierDocumentInitial()) {
    on<FetchCourierDocumentsEvent>(_fetchCourierDocuments);
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
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['documents'];
        emit(CourierDocumentLoaded(documents: data));
      } else {
        final error = jsonDecode(response.body)['message'] ?? "Failed to fetch documents.";
        emit(CourierDocumentError(error: error));
      }
    } catch (e) {
      emit(CourierDocumentError(error: e.toString()));
    }
  }
}
