import 'package:bloc/bloc.dart';
import 'package:cash_control/bloc/blocs/common_blocs/events/unit_event.dart';
import 'package:cash_control/bloc/blocs/common_blocs/states/unit_state.dart';
import 'package:cash_control/constant.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class UnitBloc extends Bloc<UnitEvent, UnitState> {
  UnitBloc() : super(UnitInitial()) {
    on<CreateUnitEvent>(_createUnit);
    on<FetchUnitsEvent>(_fetchUnits);

  }

Future<void> _fetchUnits(FetchUnitsEvent event, Emitter<UnitState> emit) async {
  emit(UnitLoading());

  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      emit(UnitError("Authentication token not found."));
      return;
    }

    final response = await http.get(
      Uri.parse(baseUrl + 'unit-measurements'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final units = jsonDecode(response.body) as List;
      emit(UnitSuccess(units.map((u) => u['name']).join(','))); // Comma-separated units
    } else {
      emit(UnitError("Failed to fetch unit measurements."));
    }
  } catch (e) {
    emit(UnitError("Error: $e"));
  }
}

  Future<void> _createUnit(CreateUnitEvent event, Emitter<UnitState> emit) async {
    emit(UnitLoading());

    try {
      // Retrieve the token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        emit(UnitError("Authentication token not found."));
        return;
      }

      // API request
      final response = await http.post(
        Uri.parse(baseUrl + 'unit-measurements'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': event.name,
        }),
      );

      if (response.statusCode == 201) {
        emit(UnitSuccess("Единица успешно сохранена"));
      } else {
        final errorData = jsonDecode(response.body);
        emit(UnitError(errorData['message'] ?? "Не удалось сохранить единицу"));
      }
    } catch (e) {
      emit(UnitError("Ошибка: $e"));
    }
  }
}
