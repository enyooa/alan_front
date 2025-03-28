import 'dart:convert';
import 'package:alan/bloc/blocs/admin_page_blocs/events/docs_event.dart';
import 'package:alan/bloc/blocs/admin_page_blocs/states/docs_state.dart';
import 'package:alan/bloc/models/doc_item.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:alan/constant.dart'; // где baseUrl?

class DocsBloc extends Bloc<DocsEvent, DocsState> {
  DocsBloc() : super(DocsInitial()) {
    on<FetchDocsEvent>(_onFetch);
    on<DeleteDocEvent>(_onDelete);
    on<CreateDocEvent>(_onCreateDoc); // если нужно
  }

  Future<void> _onFetch(FetchDocsEvent event, Emitter<DocsState> emit) async {
    emit(DocsLoading());
    try {
      // Получаем токен, если нужно
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      // Пример: GET /api/documents/allHistories
      final uri = Uri.parse('${baseUrl}documents/allHistories');
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        final docs = data.map((e) => DocItem.fromJson(e)).toList();
        emit(DocsLoaded(docs));
      } else {
        emit(DocsError('Ошибка: ${response.statusCode}\n${response.body}'));
      }
    } catch (e) {
      emit(DocsError('Исключение: $e'));
    }
  }

  Future<void> _onDelete(DeleteDocEvent event, Emitter<DocsState> emit) async {
    if (state is! DocsLoaded) return; // можно обработать по-другому
    final currentDocs = (state as DocsLoaded).docs;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      // DELETE /api/documents/{id}
      final uri = Uri.parse('${baseUrl}documents/${event.docId}');
      final response = await http.delete(uri, headers: headers);

      if (response.statusCode == 200) {
        // Успешно удалили, убираем из списка
        final newList = currentDocs.where((d) => d.docId != event.docId).toList();
        emit(DocsLoaded(newList));
      } else {
        emit(DocsError('Ошибка удаления: ${response.statusCode}\n${response.body}'));
        // Можно вернуть старый state
        emit(DocsLoaded(currentDocs));
      }
    } catch (e) {
      emit(DocsError('Ошибка удаления: $e'));
      emit(DocsLoaded(currentDocs));
    }
  }

  Future<void> _onCreateDoc(CreateDocEvent event, Emitter<DocsState> emit) async {
    // Пример. В реальном приложении отправляем POST на /api/documents
    // После успешного создания - перезагружаем FetchDocsEvent или вручную добавляем в список.
  }
}
