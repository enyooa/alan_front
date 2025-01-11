import 'package:bloc/bloc.dart';
import 'package:cash_control/bloc/blocs/storage_page_blocs/events/sales_report_event.dart';
import 'package:cash_control/bloc/blocs/storage_page_blocs/states/sales_report_state.dart';
import 'package:cash_control/constant.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SalesReportBloc extends Bloc<SalesReportEvent, SalesReportState> {
  SalesReportBloc() : super(SalesReportInitial()) {
    on<FetchSalesReport>(_onFetchSalesReport);
  }

  Future<void> _onFetchSalesReport(
      FetchSalesReport event, Emitter<SalesReportState> emit) async {
    emit(SalesReportLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        emit(SalesReportError("Authentication token not found."));
        return;
      }

      final url = Uri.parse(baseUrl + 'fetchSalesReport');
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        emit(SalesReportLoaded(data['sales']));
      } else {
        emit(SalesReportError("Failed to fetch sales report."));
      }
    } catch (e) {
      emit(SalesReportError("Error: $e"));
    }
  }
}
