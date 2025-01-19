import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:cash_control/bloc/blocs/packer_page_blocs/events/packer_history_document_event.dart';
import 'package:cash_control/bloc/blocs/packer_page_blocs/states/packer_history_document_state.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PackerHistoryDocumentBloc
    extends Bloc<PackerHistoryDocumentEvent, PackerHistoryDocumentState> {
  final String baseUrl;

  PackerHistoryDocumentBloc({required this.baseUrl})
      : super(PackerHistoryDocumentInitial()) {
    on<FetchPackerHistoryDocumentsEvent>(_fetchPackerHistoryDocuments);
  }

  Future<void> _fetchPackerHistoryDocuments(
      FetchPackerHistoryDocumentsEvent event,
      Emitter<PackerHistoryDocumentState> emit) async {
    emit(PackerHistoryDocumentLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        emit(PackerHistoryDocumentError(message: "Authentication token not found."));
        return;
      }

      final response = await http.get(
        Uri.parse(baseUrl + 'history_orders'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['orders'];
        final documents = data.map((e) => Map<String, dynamic>.from(e)).toList();
        emit(PackerHistoryDocumentLoaded(documents: documents));
      } else {
        emit(PackerHistoryDocumentError(
            message: "Failed to fetch history documents."));
      }
    } catch (e) {
      emit(PackerHistoryDocumentError(message: e.toString()));
    }
  }
}
