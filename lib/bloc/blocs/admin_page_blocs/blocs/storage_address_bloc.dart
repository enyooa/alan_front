import 'package:bloc/bloc.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/events/storage_address_event.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/states/storage_address_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cash_control/constant.dart';

class StorageAddressBloc extends Bloc<StorageAddressEvent, StorageAddressState> {
  StorageAddressBloc() : super(StorageAddressInitial()) {
    on<FetchStorageAddressesEvent>(_handleFetchStorageAddresses);
  }

  Future<void> _handleFetchStorageAddresses(
      FetchStorageAddressesEvent event, Emitter<StorageAddressState> emit) async {
    emit(StorageAddressLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        emit(StorageAddressError('Authentication token not found.'));
        return;
      }

      final uri = Uri.parse(baseUrl + 'getStorageUserAddresses');
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final storageUsers = List<Map<String, dynamic>>.from(responseData['data'].map((user) {
          return {
            'storage_user_id': user['user_id'],
            'storage_user_name': user['user_name'],
            'addresses': List<Map<String, dynamic>>.from(user['addresses']),
          };
        }));

        emit(StorageAddressesFetched(storageUsers));
      } else {
        final responseData = jsonDecode(response.body);
        emit(StorageAddressError(
            responseData['message'] ?? 'Error fetching storage user addresses.'));
      }
    } catch (e) {
      emit(StorageAddressError('Error: $e'));
    }
  }
}
