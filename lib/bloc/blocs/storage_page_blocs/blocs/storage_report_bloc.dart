import 'dart:convert';
import 'package:alan/bloc/blocs/storage_page_blocs/events/storage_report_event.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/states/storage_report_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alan/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class StorageReportBloc extends Bloc<StorageReportEvent, StorageReportState> {
  StorageReportBloc() : super(StorageReportInitial()) {
    on<FetchStorageReportEvent>(_fetchStorageReport);
  }

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<void> _fetchStorageReport(
      FetchStorageReportEvent event, Emitter<StorageReportState> emit) async {
    emit(StorageReportLoading());
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse(baseUrl + 'fetchSalesReport'), // Ensure correct endpoint
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['sales'];
        emit(StorageReportLoaded(data.cast<Map<String, dynamic>>()));
      } else {
        emit(StorageReportError(
            'Ошибка при получении данных: ${response.body}'));
      }
    } catch (e) {
      emit(StorageReportError('Ошибка: $e'));
    }
  }
}
