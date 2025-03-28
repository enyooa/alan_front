import 'dart:convert';
import 'package:alan/bloc/blocs/storage_page_blocs/events/storage_report_event.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/states/storage_report_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alan/constant.dart';            // где baseUrl
import 'package:alan/ui/admin/widgets/storage_report_item.dart'; 
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class StorageReportBloc extends Bloc<StorageReportEvent, StorageReportState> {
  StorageReportBloc() : super(StorageReportInitial()) {
    // Обрабатываем событие FetchStorageReportEvent
    on<FetchStorageReportEvent>(_fetchStorageReport);
  }

  // Получение заголовков с токеном
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<void> _fetchStorageReport(
    FetchStorageReportEvent event,
    Emitter<StorageReportState> emit,
  ) async {
    emit(StorageReportLoading());

    try {
      // Соберём query-параметры
      final queryParams = <String, String>{};
      if (event.dateFrom != null && event.dateFrom!.isNotEmpty) {
        queryParams['date_from'] = event.dateFrom!;
      }
      if (event.dateTo != null && event.dateTo!.isNotEmpty) {
        queryParams['date_to'] = event.dateTo!;
      }

      // Пример: baseUrl = 'https://example.com/api/'
      // Допустим, endpoint: '/storage-report'
      // Сформируем Uri. Если baseUrl имеет trailing slash, аккуратно составляем путь
      final uri = Uri.parse('${baseUrl}storage-report').replace(queryParameters: queryParams);

      final headers = await _getHeaders();
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        // Парсим JSON
        final List<dynamic> jsonList = json.decode(response.body);
        // Превращаем каждый элемент в StorageReportItem
        final items = jsonList
            .map((e) => StorageReportItem.fromJson(e as Map<String, dynamic>))
            .toList();

        // Успешная загрузка
        emit(StorageReportLoaded(items));
      } else {
        emit(StorageReportError(
          'Ошибка при получении отчёта: ${response.body}',
        ));
      }
    } catch (e) {
      emit(StorageReportError('Исключение: $e'));
    }
  }
}
