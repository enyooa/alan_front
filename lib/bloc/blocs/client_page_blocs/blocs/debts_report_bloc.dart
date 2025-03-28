import 'dart:convert';
import 'package:alan/bloc/blocs/client_page_blocs/events/debts_report_event.dart';
import 'package:alan/bloc/blocs/client_page_blocs/states/debts_report_state.dart';
import 'package:alan/constant.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


class DebtsReportBloc extends Bloc<DebtsReportEvent, DebtsReportState> {
  DebtsReportBloc() : super(DebtsReportState()) {
    on<FetchDebtsReportEvent>(_onFetchDebtsReport);
  }

  /// Helper to retrieve token from SharedPreferences or wherever you store it
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<void> _onFetchDebtsReport(
    FetchDebtsReportEvent event,
    Emitter<DebtsReportState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse('${baseUrl}report_debs'), headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final documents = (data['documents'] as List).map((e) => e as Map<String, dynamic>).toList();
        final financialOrders = (data['financial_orders'] as List).map((e) => e as Map<String, dynamic>).toList();

        emit(
          state.copyWith(
            isLoading: false,
            documents: documents,
            financialOrders: financialOrders,
          ),
        );
      } else {
        // Show server error
        final errorBody = jsonDecode(response.body);
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: errorBody['message'] ?? 'Failed to fetch debts report',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'An error occurred: $e',
        ),
      );
    }
  }
}
