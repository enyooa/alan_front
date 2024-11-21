import 'package:cash_control/bloc/blocs/admin_page_blocs/events/price_request_event.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/states/price_request_state.dart';
import 'package:cash_control/constant.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:cash_control/ui/main/models/price_request.dart';

class PriceRequestBloc extends Bloc<PriceRequestEvent, PriceRequestState> {
  PriceRequestBloc() : super(PriceRequestInitial()) {
    on<CreatePriceRequestEvent>(_onCreatePriceRequest);
  }
Future<void> _onCreatePriceRequest(
    CreatePriceRequestEvent event, Emitter<PriceRequestState> emit) async {
  emit(PriceRequestLoading());

  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final roles = prefs.getStringList('roles') ?? [];

    if (token == null || !roles.contains('admin')) {
      emit(PriceRequestError('Access denied: Only admins can create price requests.'));
      return;
    }

    // Serialize the PriceRequest object
    final requestData = event.priceRequest.toJson();
    print('Request Data: $requestData'); // Debugging purposes

    // Send API request
    final response = await http.post(
      Uri.parse(baseUrl + 'price_requests'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestData),
    );

    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 201) {
      emit(PriceRequestCreated('Price request created successfully'));
    } else {
      final data = jsonDecode(response.body);
      emit(PriceRequestError(data['message'] ?? 'Failed to create price request'));
    }
  } catch (error) {
    print('Error: $error');
    emit(PriceRequestError('Error: $error'));
  }
}
  
  }
