import 'dart:convert';

import 'package:alan/bloc/blocs/admin_page_blocs/states/expenses_state.dart';
import 'package:alan/constant.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../events/expenses_event.dart';
class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  ExpenseBloc() : super(ExpenseInitial()) {
    on<FetchExpensesEvent>(_onFetchExpenses);
    on<CreateExpenseEvent>(_createExpense);
    on<FetchSingleExpenseEvent>(_fetchSingleExpense);
    on<UpdateExpenseEvent>(_updateExpense);
  }

  Future<void> _onFetchExpenses(
    FetchExpensesEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoading());
    try {
      // Получаем токен из SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token', // авторизация
      };

      // Обращаемся к /references/expense (пример)
      final uri = Uri.parse('${baseUrl}references/expense');
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        // Парсим JSON -> List<Map<String,dynamic>>
        final List<dynamic> data = jsonDecode(response.body);
        
        // Предположим, сервер возвращает [{"name":"Фрахт","amount":800000}, ...]
        // Превращаем в List<Map<String,dynamic>>
        final expenses = data.map((e) => {
          'name': e['name'],
          'amount': (e['amount'] as num?)?.toDouble() ?? 0.0,
        }).toList();

        emit(ExpenseLoaded(expenses));
      } else {
        emit(ExpenseError('Ошибка загрузки расходов: ${response.statusCode}\n${response.body}'));
      }
    } catch (e) {
      emit(ExpenseError('Исключение: $e'));
    }
  }

   // 1) CREATE
  Future<void> _createExpense(
    CreateExpenseEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        emit(ExpenseError('Authentication token not found.'));
        return;
      }

      // Suppose your route is POST /api/references/expense or /api/create_expense
      final url = Uri.parse(baseUrl + 'create_expense');
      final body = {
        'name': event.name,
      };
      if (event.amount != null) {
        body['amount'] = event.amount as String;
      }

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        emit(ExpenseCreatedSuccess("Расход успешно создан!"));
      } else {
        final errorData = jsonDecode(response.body);
        emit(ExpenseError(
          errorData['message'] ?? "Не удалось создать расход.",
        ));
      }
    } catch (e) {
      emit(ExpenseError("Ошибка: $e"));
    }
  }

  // 2) SINGLE FETCH
  Future<void> _fetchSingleExpense(
    FetchSingleExpenseEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        emit(ExpenseError('Authentication token not found.'));
        return;
      }

      // GET /api/references/expense/{id}
      final url = Uri.parse('${baseUrl}references/expense/${event.id}');
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // data => { "id":..., "name":"...", "amount":..., ... }
        emit(SingleExpenseLoaded(data));
      } else {
        emit(ExpenseError('Failed to fetch expense #${event.id}'));
      }
    } catch (err) {
      emit(ExpenseError('Error fetching expense: $err'));
    }
  }

  // 3) UPDATE
  Future<void> _updateExpense(
    UpdateExpenseEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(ExpenseLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        emit(ExpenseError("Authentication token not found."));
        return;
      }

      // PATCH /api/references/expense/{id}
      final url = Uri.parse('${baseUrl}references/expense/${event.id}');
      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(event.updatedFields),
      );

      if (response.statusCode == 200) {
        emit(ExpenseUpdatedSuccess("Расход успешно обновлен."));
      } else {
        final errorData = jsonDecode(response.body);
        emit(ExpenseError(
          errorData['message'] ?? "Не удалось обновить расход.",
        ));
      }
    } catch (err) {
      emit(ExpenseError("Ошибка: $err"));
    }
  }
}