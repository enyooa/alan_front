import 'package:bloc/bloc.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/events/address_event.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/states/address_state.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For token storage
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cash_control/constant.dart';

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  AddressBloc() : super(AddressInitial()) {
    on<CreateAddressEvent>(_handleCreateAddress);
  }

  Future<void> _handleCreateAddress(CreateAddressEvent event, Emitter<AddressState> emit) async {
    emit(AddressLoading());
    try {
      // Retrieve the stored token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        emit(AddressError('Authentication token not found.'));
        return;
      }

      // Update the URL to match your environment
      final uri = Uri.parse(baseUrl + "storeAdress/${event.userId}");
      print("Making POST request to $uri");

      // Make the HTTP POST request
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token', // Include the Bearer token
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'name': event.name}),
      );

      // Log response
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 201) {
        emit(AddressCreated('Address successfully created!'));
      } else {
        final responseData = jsonDecode(response.body);
        emit(AddressError(responseData['message'] ?? 'Error creating address.'));
      }
    } catch (e) {
      print("Error occurred: $e");
      emit(AddressError('Error: $e'));
    }
  }
}
