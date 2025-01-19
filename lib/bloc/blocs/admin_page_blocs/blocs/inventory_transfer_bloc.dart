import 'dart:convert';
import 'package:cash_control/bloc/blocs/admin_page_blocs/events/inventory_transfer_event.dart';
import 'package:cash_control/bloc/blocs/admin_page_blocs/states/inventory_transfer_state.dart';
import 'package:cash_control/constant.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

class InventoryTransferBloc extends Bloc<InventoryTransferEvent, InventoryTransferState> {
  InventoryTransferBloc() : super(InventoryTransferInitial());

  @override
  Stream<InventoryTransferState> mapEventToState(InventoryTransferEvent event) async* {
    if (event is FetchAdminWarehouseQuantities) {
      yield InventoryTransferLoading();

      try {
        final response = await http.get(Uri.parse(baseUrl+'inventory/admin-warehouse'));
        final data = json.decode(response.body);

        if (data['success']) {
          yield InventoryTransferSuccess(data['data']);
        } else {
          yield InventoryTransferError(data['message']);
        }
      } catch (e) {
        yield InventoryTransferError('Failed to fetch quantities.');
      }
    } else if (event is TransferInventory) {
      yield InventoryTransferLoading();

      try {
        final response = await http.post(
          Uri.parse(baseUrl+'inventory/transfer'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'transfers': event.transfers,
            'address_id': event.addressId,
            'user_id': event.userId,
            'date': event.date,
          }),
        );

        final data = json.decode(response.body);

        if (data['success']) {
          yield InventoryTransferSuccess(data['message']);
        } else {
          yield InventoryTransferError(data['message']);
        }
      } catch (e) {
        yield InventoryTransferError('Failed to transfer inventory.');
      }
    }
  }
}
