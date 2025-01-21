import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:alan/bloc/blocs/client_page_blocs/events/client_order_items_event.dart';
import 'package:alan/bloc/blocs/client_page_blocs/states/client_order_items_state.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alan/constant.dart';

class ClientOrderItemsBloc extends Bloc<ClientOrderItemsEvent, ClientOrderItemsState> {
  ClientOrderItemsBloc() : super(ClientOrderItemsInitial()) {
    on<FetchClientOrderItemsEvent>(_fetchClientOrderItems);
    on<ConfirmCourierDocumentEvent>(_confirmCourierDocument);
  }

  // Fetch Client Order Items
  Future<void> _fetchClientOrderItems(FetchClientOrderItemsEvent event, Emitter<ClientOrderItemsState> emit) async {
    emit(ClientOrderItemsLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        emit(ClientOrderItemsError(error: "Authentication token not found."));
        return;
      }

      final response = await http.get(
        Uri.parse(baseUrl + 'client-order-items'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is! List) throw Exception("Unexpected response format.");
        emit(ClientOrderItemsLoaded(clientOrderItems: data));
      } else {
        emit(ClientOrderItemsError(error: "Failed to fetch client order items."));
      }
    } catch (e) {
      emit(ClientOrderItemsError(error: e.toString()));
    }
  }

  // Confirm Courier Document
  Future<void> _confirmCourierDocument(ConfirmCourierDocumentEvent event, Emitter<ClientOrderItemsState> emit) async {
    if (state is! ClientOrderItemsLoaded) return;

    final currentState = state as ClientOrderItemsLoaded;
    final updatedItems = List<dynamic>.from(currentState.clientOrderItems);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        emit(ClientOrderItemsError(error: "Authentication token not found."));
        return;
      }

      final response = await http.post(
        Uri.parse(baseUrl + 'confirm-courier-document'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'courier_document_id': event.courierDocumentId}),
      );

      if (response.statusCode == 200) {
        // Update local state
        final updatedDocuments = updatedItems.map((doc) {
          final courierDocument = doc['courier_document'];
          if (courierDocument?['id'] == event.courierDocumentId) {
            courierDocument['is_confirmed'] = true;
          }
          return doc;
        }).toList();

        emit(ClientOrderItemsLoaded(clientOrderItems: updatedDocuments));
      } else {
        final errorMessage = jsonDecode(response.body)['error'] ?? "Confirmation failed.";
        emit(ClientOrderItemsError(error: errorMessage));
      }
    } catch (e) {
      emit(ClientOrderItemsError(error: e.toString()));
    }
  }
}
