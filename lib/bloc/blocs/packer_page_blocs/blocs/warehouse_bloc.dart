import 'package:bloc/bloc.dart';
import 'package:cash_control/bloc/blocs/packer_page_blocs/events/warehouse_event.dart';
import 'package:cash_control/bloc/blocs/packer_page_blocs/states/warehouse_state.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cash_control/constant.dart';

class PackagingBloc extends Bloc<PackagingEvent, PackagingState> {
  PackagingBloc() : super(PackagingInitial()) {
    on<FetchPackagingDataEvent>(_fetchPackagingData);
  }

  Future<void> _fetchPackagingData(
      FetchPackagingDataEvent event, Emitter<PackagingState> emit) async {
    emit(PackagingLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        emit(PackagingError(error:'Authentication token not found.'));
        return;
      }

      final response = await http.get(
        Uri.parse(baseUrl +
            'generalWarehouse?startDate=${event.startDate.toIso8601String()}&endDate=${event.endDate.toIso8601String()}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;

        // Parse response data into tableData format
        final List<Map<String, dynamic>> tableData = data.map((item) {
          return {
            'name': item['product_subcard_name'] ?? 'Unknown',
            'unit': item['unit_measurement'] ?? '',
            'quantity': item['amount'] ?? 0,
          };
        }).toList();

        // Debug log
        print('Parsed Data: $tableData');

        emit(PackagingLoaded(tableData: tableData));
      } else {
        final error = jsonDecode(response.body);
        emit(PackagingError(error:error['message'] ?? 'Error fetching data.'));
      }
    } catch (e) {
      emit(PackagingError(error:'Error: $e'));
    }
  }
}
