import 'package:bloc/bloc.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/events/address_event.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/states/address_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cash_control/constant.dart';
class AddressBloc extends Bloc<AddressEvent, AddressState> {
  AddressBloc() : super(AddressInitial()) {
    on<CreateAddressEvent>(_handleCreateAddress);
    on<FetchAddressesEvent>(_handleFetchAddresses);
  }

  Future<void> _handleCreateAddress(CreateAddressEvent event, Emitter<AddressState> emit) async {
    emit(AddressLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        emit(AddressError('Authentication token not found.'));
        return;
      }

      final uri = Uri.parse(baseUrl + "storeAdress/${event.userId}");
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'name': event.name}),
      );

      if (response.statusCode == 201) {
        emit(AddressCreated('Адрес успешно создан!'));
      } else {
        final responseData = jsonDecode(response.body);
        emit(AddressError(responseData['message'] ?? 'Error creating address.'));
      }
    } catch (e) {
      emit(AddressError('Error: $e'));
    }
  }

  Future<void> _handleFetchAddresses(
      FetchAddressesEvent event, Emitter<AddressState> emit) async {
    emit(AddressLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        emit(AddressError('Authentication token not found.'));
        return;
      }

      final uri = Uri.parse(baseUrl + "getClientAdresses");
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        final addresses = List<Map<String, dynamic>>.from(responseData['data'].map((client) {
          return {
            'client_id': client['client_id'],
            'client_name': client['client_name'],
            'addresses': List<Map<String, dynamic>>.from(client['addresses'].map((address) {
              return {
                'id': int.parse(address['id'].toString()), // Ensure ID is an int
                'name': address['name'],
              };
            })),
          };
        }));

        emit(AddressesFetched(addresses));
      } else {
        final responseData = jsonDecode(response.body);
        emit(AddressError(responseData['message'] ?? 'Error fetching addresses.'));
      }
    } catch (e) {
      emit(AddressError('Error: $e'));
    }
  }

  }
