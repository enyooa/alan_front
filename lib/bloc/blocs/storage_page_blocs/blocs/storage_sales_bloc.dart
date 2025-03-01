import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/events/storage_sales_event.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/states/storage_sales_state.dart';
import 'package:alan/constant.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SalesStorageBloc extends Bloc<SalesStorageEvent, SalesStorageState> {
  SalesStorageBloc() : super(SalesStorageInitial()) {
    on<FetchSalesStorageData>(_onFetchSalesStorageData);
    on<SubmitSalesStorageData>(_onSubmitSalesStorageData);
  }

  Future<void> _onFetchSalesStorageData(
    FetchSalesStorageData event, 
    Emitter<SalesStorageState> emit
  ) async {
    emit(SalesStorageLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        emit(SalesStorageError('Authentication token not found'));
        return;
      }

      final url = Uri.parse(baseUrl + 'getAllInstances');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        emit(SalesStorageLoaded(
          clients: data['clients'],
          productSubCards: data['product_sub_cards'],
          unitMeasurements: data['unit_measurements'],
        ));
      } else {
        emit(SalesStorageError(
          'Failed to fetch data: ${response.body}',
        ));
      }
    } catch (e) {
      emit(SalesStorageError('Error: $e'));
    }
  }

  Future<void> _onSubmitSalesStorageData(
    SubmitSalesStorageData event,
    Emitter<SalesStorageState> emit,
  ) async {
    emit(SalesStorageLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        emit(SalesStorageError('Authentication token not found'));
        return;
      }

      final url = Uri.parse(baseUrl + 'storeSales');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'client_id': event.clientId,
          'address_id': event.addressId,
          'date': event.date.toIso8601String(),
          'products': event.products,
        }),
      );

      if (response.statusCode == 200) {
        // Possibly parse the response to get success message
        emit(SalesStorageSubmitted('Data submitted successfully!'));
      } else {
        emit(SalesStorageError(
          'Failed to submit data: ${response.body}',
        ));
      }
    } catch (e) {
      emit(SalesStorageError('Error: $e'));
    }
  }
}
