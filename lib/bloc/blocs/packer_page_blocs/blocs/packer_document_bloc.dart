import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:cash_control/bloc/blocs/packer_page_blocs/events/packer_document_event.dart';
import 'package:cash_control/bloc/blocs/packer_page_blocs/states/packer_document_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:cash_control/constant.dart';

class PackerDocumentBloc extends Bloc<PackerDocumentEvent, PackerDocumentState> {
  PackerDocumentBloc() : super(PackerDocumentInitial()) {
    on<SubmitPackerDocumentEvent>(_onSubmitPackerDocument);
     on<FetchPackerDocumentsEvent>(_onFetchPackerDocuments);
  }

Future<void> _onSubmitPackerDocument(
      SubmitPackerDocumentEvent event, Emitter<PackerDocumentState> emit) async {
    emit(PackerDocumentLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        emit(PackerDocumentError(error: 'Authentication token not found.'));
        return;
      }

      final response = await http.post(
        Uri.parse(baseUrl+'create_packer_document'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'id_courier': event.idCourier,
          'delivery_address': event.deliveryAddress,
          'order_products': event.orderProducts,
        }),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        emit(PackerDocumentSubmitted(message: responseData['message'] ?? 'Document created successfully.'));
      } else {
        final responseData = jsonDecode(response.body);
        emit(PackerDocumentError(error: responseData['error'] ?? 'Failed to create document.'));
      }
    } catch (e) {
      emit(PackerDocumentError(error: e.toString()));
    }
  }


  Future<void> _onFetchPackerDocuments(
      FetchPackerDocumentsEvent event, Emitter<PackerDocumentState> emit) async {
    emit(PackerDocumentLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        emit(PackerDocumentError(error: "Authentication token not found."));
        return;
      }

      final response = await http.get(
        Uri.parse(baseUrl + 'get_packer_document'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        emit(PackerDocumentsFetched(documents: data));
      } else {
        final errorData = jsonDecode(response.body);
        emit(PackerDocumentError(error: errorData['error'] ?? 'Failed to fetch documents.'));
      }
    } catch (e) {
      emit(PackerDocumentError(error: e.toString()));
    }
  }



}

  