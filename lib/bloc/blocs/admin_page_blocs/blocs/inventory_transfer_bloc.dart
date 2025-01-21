import 'dart:convert';
import 'package:alan/bloc/blocs/admin_page_blocs/events/inventory_transfer_event.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/states/inventory_transfer_state.dart';
import 'package:alan/constant.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class InventoryTransferBloc extends Bloc<InventoryTransferEvent, InventoryTransferState> {
  InventoryTransferBloc() : super(InventoryTransferInitial());

  @override
  Stream<InventoryTransferState> mapEventToState(InventoryTransferEvent event) async* {
    if (event is FetchAdminWarehouseQuantities) {
      yield* _fetchAdminWarehouseQuantities();
    } else if (event is TransferInventory) {
      yield* _transferInventory(event);
    }
  }

  Stream<InventoryTransferState> _fetchAdminWarehouseQuantities() async* {
    yield InventoryTransferLoading();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        yield InventoryTransferError('Authentication token not found.');
        return;
      }

      final response = await http.get(
        Uri.parse(baseUrl+'inventory/admin-warehouse'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          yield InventoryTransferSuccess(data['data']);
        } else {
          yield InventoryTransferError(data['message']);
        }
      } else {
        yield InventoryTransferError('Failed to fetch quantities: ${response.statusCode}.');
      }
    } catch (e) {
      yield InventoryTransferError('Failed to fetch quantities: $e');
    }
  }

  Stream<InventoryTransferState> _transferInventory(TransferInventory event) async* {
    yield InventoryTransferLoading();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        yield InventoryTransferError('Authentication token not found.');
        return;
      }

      final response = await http.post(
        Uri.parse(baseUrl+'inventory/transfer'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'transfers': event.transfers,
          'address_id': event.addressId,
          'user_id': event.userId,
          'date': event.date,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success']) {
          yield InventoryTransferSuccess(data['message']);
        } else {
          yield InventoryTransferError(data['message']);
        }
      } else {
        yield InventoryTransferError(
            'Failed to transfer inventory: ${response.statusCode}.');
      }
    } catch (e) {
      yield InventoryTransferError('Failed to transfer inventory: $e');
    }
  }
}
