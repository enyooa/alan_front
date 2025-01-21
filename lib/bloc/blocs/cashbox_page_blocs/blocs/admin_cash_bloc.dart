import 'package:alan/bloc/blocs/cashbox_page_blocs/events/admin_cash_event.dart';
import 'package:alan/bloc/blocs/cashbox_page_blocs/states/admin_cash_state.dart';
import 'package:alan/constant.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AdminCashBloc extends Bloc<AdminCashEvent, AdminCashState> {
  AdminCashBloc()
      : super(AdminCashState(
          isLoading: false,
          cashAccounts: [],
        )) {
    on<FetchAdminCashesEvent>(_fetchAdminCashes);
  }

  // Function to fetch headers with the token
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<void> _fetchAdminCashes(
      FetchAdminCashesEvent event, Emitter<AdminCashState> emit) async {
    emit(state.copyWith(isLoading: true));

    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(baseUrl+'admin-cashes'), headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        final cashAccounts = data
            .map((cash) => {'id': cash['id'].toString(), 'name': cash['name'].toString()})
            .toList();

        emit(state.copyWith(isLoading: false, cashAccounts: cashAccounts));
        print(response);
      } else {
        emit(state.copyWith(
            isLoading: false, errorMessage: 'Failed to fetch cash accounts'));
      }
    } catch (e) {
      emit(state.copyWith(
          isLoading: false, errorMessage: 'An error occurred: $e'));
    }
  }
}
