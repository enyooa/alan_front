import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:alan/bloc/blocs/client_page_blocs/events/sales_event.dart';
import 'package:alan/bloc/blocs/client_page_blocs/states/sales_state.dart';


import 'package:alan/constant.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SalesBloc extends Bloc<SalesEvent, SalesState> {
  SalesBloc() : super(SalesInitial()) {
    on<FetchSalesWithDetailsEvent>(_fetchSalesWithDetails);
        on<ResetSalesEvent>(_resetSalesState); // Handle reset event

  }

  


  Future<void> _fetchSalesWithDetails(
    FetchSalesWithDetailsEvent event, Emitter<SalesState> emit) async {
  emit(SalesLoading());

  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      emit(SalesError(message: "Authentication token not found. Please log in."));
      return;
    }

    final response = await http.get(
      Uri.parse(baseUrl + 'getSalesClientPage'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> rawData = jsonDecode(response.body);
      emit(SalesLoadedWithDetails(
        salesDetails: rawData
            .map((item) => item as Map<String, dynamic>)
            .toList(),
      ));
    } else {
      emit(SalesError(message: "Failed to fetch sales details."));
    }
  } catch (e) {
    emit(SalesError(message: e.toString()));
  }
}

Future<void> _resetSalesState(ResetSalesEvent event, Emitter<SalesState> emit) async {
    emit(SalesInitial());
  }

}
