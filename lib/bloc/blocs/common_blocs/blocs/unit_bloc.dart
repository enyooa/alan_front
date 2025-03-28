// unit_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:alan/bloc/blocs/common_blocs/events/unit_event.dart';
import 'package:alan/bloc/blocs/common_blocs/states/unit_state.dart';
import 'package:alan/constant.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UnitBloc extends Bloc<UnitEvent, UnitState> {
  UnitBloc() : super(UnitInitial()) {
    on<CreateUnitEvent>(_createUnit);
    on<FetchUnitsEvent>(_fetchUnits);
    on<UpdateUnitEvent>(_updateUnit); // <-- NEW
    on<FetchSingleUnitEvent>((event, emit) async {
  emit(UnitLoading());
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      emit(UnitError("Authentication token not found."));
      return;
    }

    // GET references/unit/{id}
    final url = Uri.parse('${baseUrl}references/unit/${event.id}');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body); // single unit object
      emit(SingleUnitLoaded(data));
    } else {
      emit(UnitError('Failed to fetch unit #${event.id}'));
    }
  } catch (e) {
    emit(UnitError('Error fetching unit: $e'));
  }
});

  }

  // 1) Fetch
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
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final units = jsonDecode(response.body) as List;
        final unitData = units.map((u) => {
          'id': u['id'],
          'name': u['name'],
          'tare': u['tare'],
        }).toList();

        emit(UnitFetchedSuccess(unitData));
      } else {
        emit(UnitError("Failed to fetch unit measurements."));
      }
    } catch (e) {
      emit(UnitError("Error: $e"));
    }
  }

  // 2) Create
  Future<void> _createUnit(CreateUnitEvent event, Emitter<UnitState> emit) async {
    emit(UnitLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        emit(UnitError("Authentication token not found."));
        return;
      }

      final response = await http.post(
        Uri.parse(baseUrl + 'unit-measurements'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': event.name,
          'tare': event.tare,
        }),
      );

      if (response.statusCode == 201) {
        emit(UnitCreatedSuccess("Единица успешно сохранена"));
      } else {
        final errorData = jsonDecode(response.body);
        emit(UnitError(errorData['message'] ?? "Не удалось сохранить единицу"));
      }
    } catch (e) {
      emit(UnitError("Ошибка: $e"));
    }
  }

  // 3) Update (NEW)
  Future<void> _updateUnit(UpdateUnitEvent event, Emitter<UnitState> emit) async {
    emit(UnitLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        emit(UnitError("Authentication token not found."));
        return;
      }

      // PATCH references/unit/{id}
      final url = Uri.parse('${baseUrl}references/unit/${event.id}');
      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(event.data),
      );

      if (response.statusCode == 200) {
        emit(UnitUpdatedSuccess("Единица измерения успешно обновлена."));
      } else {
        final errorData = jsonDecode(response.body);
        emit(UnitError(errorData['message'] ?? "Ошибка обновления."));
      }
    } catch (err) {
      emit(UnitError("Ошибка: $err"));
    }
  }
}
