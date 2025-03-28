import 'dart:convert';
import 'package:alan/bloc/blocs/storage_page_blocs/events/sales_report_event.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/states/sales_report_state.dart';
import 'package:alan/bloc/models/sale_row.dart';
import 'package:alan/ui/admin/dynamic_pages/report_pages/sales_report.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


import 'package:alan/constant.dart'; // здесь baseUrl, и т.д.

class SalesReportBloc extends Bloc<SalesReportEvent, SalesReportState> {
  SalesReportBloc() : super(SalesReportInitial()) {
    on<FetchSalesReportEvent>(_onFetchSales);
    on<ExportSalesPdfEvent>(_onExportPdf);
    on<ExportSalesExcelEvent>(_onExportExcel);
  }

  Future<void> _onFetchSales(
    FetchSalesReportEvent event,
    Emitter<SalesReportState> emit,
  ) async {
    emit(SalesReportLoading());

    try {
      // Собираем query-параметры
      final params = <String, String>{};
      if (event.startDate != null && event.startDate!.isNotEmpty) {
        params['start_date'] = event.startDate!;
      }
      if (event.endDate != null && event.endDate!.isNotEmpty) {
        params['end_date'] = event.endDate!;
      }

      // Формируем Uri
      final uri = Uri.parse('${baseUrl}sales-report').replace(queryParameters: params);

      // Если нужно авторизоваться:
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      // GET запрос
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        final items = data.map((e) => SalesRow.fromJson(e)).toList();
        emit(SalesReportLoaded(items));
      } else {
        emit(SalesReportError(
          'Ошибка: ${response.statusCode}\n${response.body}',
        ));
      }
    } catch (e) {
      emit(SalesReportError('Исключение: $e'));
    }
  }

  // Пример заглушек: для экспорта PDF/Excel
  Future<void> _onExportPdf(
    ExportSalesPdfEvent event,
    Emitter<SalesReportState> emit,
  ) async {
    // Тут можно реализовать логику или просто открыть URL
    // emit(...) если нужно
  }

  Future<void> _onExportExcel(
    ExportSalesExcelEvent event,
    Emitter<SalesReportState> emit,
  ) async {
    // Аналогично
  }
}
