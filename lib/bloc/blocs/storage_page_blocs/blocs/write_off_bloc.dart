import 'dart:convert';
import 'package:alan/bloc/blocs/storage_page_blocs/events/write_off_event.dart';
import 'package:alan/bloc/blocs/storage_page_blocs/states/write_off_state.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:alan/constant.dart'; // for baseUrl

class WriteOffBloc extends Bloc<WriteOffEvent, WriteOffState> {
  WriteOffBloc() : super(WriteOffInitial()) {
    on<FetchWriteOffsEvent>(_handleFetch);
    on<CreateWriteOffEvent>(_handleCreate);
    on<UpdateWriteOffEvent>(_handleUpdate);
    on<DeleteWriteOffEvent>(_handleDelete);
    on<FetchSingleWriteOffEvent>(_handleFetchSingle);
  }

  // 1) FETCH
  Future<void> _handleFetch(
  FetchWriteOffsEvent event,
  Emitter<WriteOffState> emit,
) async {
  emit(WriteOffLoading());
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      emit(WriteOffError(message: "No token found"));
      return;
    }

    // Update the endpoint to the documents endpoint and add a filter parameter:
    final response = await http.get(
  Uri.parse('${baseUrl}writeoff'),
  headers: {
    'Authorization': 'Bearer $token',
    'Accept': 'application/json',
  },
);
print('List fetch status: ${response.statusCode}');
print('List fetch body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      emit(WriteOffListLoaded(writeOffDocs: data));
    } else {
      final err = jsonDecode(response.body);
      emit(WriteOffError(message: err['error'] ?? 'Error fetching write-offs'));
    }
  } catch (e) {
    emit(WriteOffError(message: e.toString()));
  }
}

  // 2) FETCH SINGLE
  Future<void> _handleFetchSingle(
    FetchSingleWriteOffEvent event,
    Emitter<WriteOffState> emit,
  ) async {
    emit(WriteOffLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        emit(WriteOffError(message: "No token found"));
        return;
      }

      // UPDATED ROUTE HERE:
      final response = await http.get(
  Uri.parse('${baseUrl}documents/${event.docId}'),
  headers: {
    'Authorization': 'Bearer $token',
    'Accept': 'application/json',
  },
);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        emit(WriteOffSingleLoaded(document: data));
      } else {
        final err = jsonDecode(response.body);
        emit(WriteOffError(message: err['error'] ?? 'Error fetching write-off document'));
      }
    } catch (e) {
      emit(WriteOffError(message: e.toString()));
    }
  }

  // 3) CREATE
  Future<void> _handleCreate(
    CreateWriteOffEvent event,
    Emitter<WriteOffState> emit,
  ) async {
    emit(WriteOffLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        emit(WriteOffError(message: "No token found"));
        return;
      }

      final response = await http.post(
        Uri.parse(baseUrl + 'writeoff'), // POST /api/writeoff
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(event.payload),
      );
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final msg = data['message'] ?? 'Write-off created';
        emit(WriteOffCreated(message: msg));
      } else {
        final err = jsonDecode(response.body);
        emit(WriteOffError(message: err['error'] ?? 'Error creating write-off'));
      }
    } catch (e) {
      emit(WriteOffError(message: e.toString()));
    }
  }

  // 4) UPDATE
  Future<void> _handleUpdate(
  UpdateWriteOffEvent event,
  Emitter<WriteOffState> emit,
) async {
  emit(WriteOffLoading());
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      emit(WriteOffError(message: "No token found"));
      return;
    }

    // Ensure payload includes document_type for validation
    final updatedPayload = {
      ...event.updatedData,
      'document_type': 'writeOff',
    };

    final response = await http.put(
      Uri.parse('${baseUrl}writeoff_update/${event.docId}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(updatedPayload),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final msg = data['message'] ?? 'Write-off updated';
      emit(WriteOffUpdated(message: msg));
    } else {
      final err = jsonDecode(response.body);
      emit(WriteOffError(message: err['error'] ?? 'Error updating write-off'));
    }
  } catch (e) {
    emit(WriteOffError(message: e.toString()));
  }
}

  // 5) DELETE
  Future<void> _handleDelete(
    DeleteWriteOffEvent event,
    Emitter<WriteOffState> emit,
  ) async {
    emit(WriteOffLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        emit(WriteOffError(message: "No token found"));
        return;
      }

      final response = await http.delete(
        Uri.parse('${baseUrl}writeoff/${event.docId}'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final msg = data['message'] ?? 'Write-off deleted';
        emit(WriteOffDeleted(message: msg));
      } else {
        final err = jsonDecode(response.body);
        emit(WriteOffError(message: err['error'] ?? 'Error deleting write-off'));
      }
    } catch (e) {
      emit(WriteOffError(message: e.toString()));
    }
  }
}
