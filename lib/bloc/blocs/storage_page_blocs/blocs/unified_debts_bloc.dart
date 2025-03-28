import 'dart:convert';
import 'package:alan/bloc/blocs/storage_page_blocs/events/unified_debts_event.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/states/unified_debts_state.dart';
import 'package:alan/bloc/models/debts_row.dart';
import 'package:alan/ui/admin/dynamic_pages/report_pages/debts_report.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// Наши файлы


// Предположим, что у вас в constant.dart есть baseUrl = 'https://example.com/api/'
import 'package:alan/constant.dart';

class UnifiedDebtsBloc extends Bloc<UnifiedDebtsEvent, UnifiedDebtsState> {
  UnifiedDebtsBloc() : super(UnifiedDebtsInitial()) {
    on<FetchUnifiedDebtsEvent>(_onFetch);
  }

  Future<void> _onFetch(
    FetchUnifiedDebtsEvent event,
    Emitter<UnifiedDebtsState> emit,
  ) async {
    emit(UnifiedDebtsLoading());

    try {
      // Собираем query-параметры
      final Map<String, String> params = {};
      if (event.dateFrom != null && event.dateFrom!.isNotEmpty) {
        params['date_from'] = event.dateFrom!;
      }
      if (event.dateTo != null && event.dateTo!.isNotEmpty) {
        params['date_to'] = event.dateTo!;
      }

      // Формируем Uri
      // baseUrl может быть: 'https://example.com/api/'
      // => итог: 'https://example.com/api/admin-report-debts?date_from=...'
      final uri = Uri.parse('${baseUrl}admin-report-debts').replace(queryParameters: params);

      // Если нужна авторизация - достаём токен из SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };

      // GET-запрос
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        // Парсим JSON
        final List<dynamic> jsonList = json.decode(response.body);
        final rows = jsonList.map((e) => DebtsRow.fromJson(e)).toList();
        emit(UnifiedDebtsLoaded(rows));
      } else {
        emit(UnifiedDebtsError(
          'Ошибка при загрузке: ${response.statusCode}\n${response.body}',
        ));
      }
    } catch (e) {
      emit(UnifiedDebtsError('Исключение: $e'));
    }
  }
}
