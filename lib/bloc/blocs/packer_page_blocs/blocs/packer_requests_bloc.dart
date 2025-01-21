import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:alan/bloc/blocs/packer_page_blocs/events/packer_requests_event.dart';
import 'package:alan/bloc/blocs/packer_page_blocs/states/packer_requests_state.dart';

import 'package:http/http.dart' as http;

class RequestsBloc extends Bloc<RequestsEvent, RequestsState> {
  final String baseUrl;

  RequestsBloc({required this.baseUrl}) : super(RequestsInitial()) {
    on<FetchRequestsEvent>(_fetchRequests);
    on<SaveRequestsEvent>(_saveRequests);
  }

  Future<void> _fetchRequests(
      FetchRequestsEvent event, Emitter<RequestsState> emit) async {
    emit(RequestsLoading());

    try {
      final response = await http.get(Uri.parse(baseUrl+'get_packer_document'));
      if (response.statusCode == 200) {
        final data = List<Map<String, dynamic>>.from(
          jsonDecode(response.body)['documents'],
        );
        emit(RequestsLoaded(requests: data));
      } else {
        emit(RequestsError(
            message: 'Failed to fetch requests: ${response.reasonPhrase}'));
      }
    } catch (e) {
      emit(RequestsError(message: e.toString()));
    }
  }

  Future<void> _saveRequests(
      SaveRequestsEvent event, Emitter<RequestsState> emit) async {
    emit(RequestsLoading());

    try {
      final response = await http.post(
        Uri.parse(baseUrl+'storeInvoice'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'requests': event.requests}),
      );

      if (response.statusCode == 201) {
        emit(RequestsSuccess());
      } else {
        emit(RequestsError(
            message: 'Failed to save requests: ${response.reasonPhrase}'));
      }
    } catch (e) {
      emit(RequestsError(message: e.toString()));
    }
  }
}
