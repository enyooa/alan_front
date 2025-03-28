import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:alan/bloc/blocs/packer_page_blocs/events/packer_history_document_event.dart';
import 'package:alan/bloc/blocs/packer_page_blocs/states/packer_history_document_state.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alan/constant.dart';

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
        Uri.parse(baseUrl+'history_orders'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;

        // Parse orders and statuses from the response.
        final List<dynamic> rawOrders = decoded['orders'] ?? [];
        final List<dynamic> rawStatuses = decoded['statuses'] ?? [];

        final documents = rawOrders.map((e) => Map<String, dynamic>.from(e)).toList();
        final statuses = rawStatuses.map((s) => Map<String, dynamic>.from(s)).toList();

        emit(PackerHistoryDocumentLoaded(documents: documents, statuses: statuses));
      } else {
        emit(PackerHistoryDocumentError(message: "Failed to fetch history documents."));
      }
    } catch (e) {
      emit(PackerHistoryDocumentError(message: e.toString()));
    }
  }
}
