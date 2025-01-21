import 'package:alan/bloc/blocs/cashbox_page_blocs/events/financial_element.dart';
import 'package:alan/bloc/blocs/cashbox_page_blocs/states/financial_element.dart';
import 'package:alan/constant.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ReferenceBloc extends Bloc<ReferenceEvent, ReferenceState> {

  ReferenceBloc()
      : super(ReferenceState(references: {
          'Статья расходов': [],
          'Статьи движение денег': [],
        })) {
    on<FetchReferencesEvent>(_fetchReferences);
    on<AddReferenceEvent>(_addReference);
    on<EditReferenceEvent>(_editReference);
    on<DeleteReferenceEvent>(_deleteReference);
  }

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

 Future<void> _fetchReferences(FetchReferencesEvent event, Emitter<ReferenceState> emit) async {
  emit(state.copyWith(isLoading: true));
  try {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('${baseUrl}financial-elements'), headers: headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      final references = {
        'Статья расходов': data
            .where((e) => e['type'] == 'expense')
            .map((e) => {'id': e['id'], 'name': e['name']})
            .toList(),
        'Статьи движение денег': data
            .where((e) => e['type'] == 'income')
            .map((e) => {'id': e['id'], 'name': e['name']})
            .toList(),
      };
      emit(state.copyWith(references: references, isLoading: false));
    } else {
      emit(state.copyWith(isLoading: false, errorMessage: 'Failed to fetch data'));
    }
  } catch (e) {
    emit(state.copyWith(isLoading: false, errorMessage: 'An error occurred: $e'));
  }
}


  Future<void> _addReference(AddReferenceEvent event, Emitter<ReferenceState> emit) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${baseUrl}financial-elements'),
        headers: headers,
        body: jsonEncode({'name': event.item, 'type': event.category == 'Статья расходов' ? 'expense' : 'income'}),
      );
      if (response.statusCode == 201) {
        add(FetchReferencesEvent());
      } else {
        emit(state.copyWith(errorMessage: 'Failed to add item'));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'An error occurred: $e'));
    }
  }

  Future<void> _editReference(EditReferenceEvent event, Emitter<ReferenceState> emit) async {
  try {
    final headers = await _getHeaders();
    final reference = state.references[event.category]![event.index];
    final response = await http.put(
      Uri.parse('${baseUrl}financial-elements/${reference['id']}'),
      headers: headers,
      body: jsonEncode({'name': event.newItem, 'type': event.category == 'Статья расходов' ? 'expense' : 'income'}),
    );
    if (response.statusCode == 200) {
      add(FetchReferencesEvent());
    } else {
      emit(state.copyWith(errorMessage: 'Failed to edit item'));
    }
  } catch (e) {
    emit(state.copyWith(errorMessage: 'An error occurred: $e'));
  }
}

  Future<void> _deleteReference(DeleteReferenceEvent event, Emitter<ReferenceState> emit) async {
  try {
    final headers = await _getHeaders();
    final reference = state.references[event.category]![event.index];
    final response = await http.delete(
      Uri.parse('${baseUrl}financial-elements/${reference['id']}'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      add(FetchReferencesEvent());
    } else {
      emit(state.copyWith(errorMessage: 'Failed to delete item'));
    }
  } catch (e) {
    emit(state.copyWith(errorMessage: 'An error occurred: $e'));
  }
}

}