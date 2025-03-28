import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:alan/bloc/blocs/common_blocs/events/provider_event.dart';
import 'package:alan/bloc/models/provider.dart';
import 'package:alan/bloc/blocs/common_blocs/states/provider_state.dart';
import 'package:alan/constant.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProviderBloc extends Bloc<ProviderEvent, ProviderState> {
  ProviderBloc() : super(ProviderInitial()) {
    on<FetchProvidersEvent>(_fetchProviders);
    on<CreateProviderEvent>(_createProvider);
    on<UpdateProviderEvent>(_updateProvider);
    on<DeleteProviderEvent>(_deleteProvider);
    on<FetchSingleProviderEvent>((event, emit) async {
  emit(ProviderLoading());
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      emit(ProviderError("Authentication token not found."));
      return;
    }

    // GET /api/references/provider/{id}
    final url = Uri.parse('${baseUrl}references/provider/${event.id}');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body); // single provider object
      // data might be {"id":..., "name":"..."}
      emit(SingleProviderLoaded(data));
    } else {
      emit(ProviderError('Failed to fetch provider #${event.id}'));
    }
  } catch (e) {
    emit(ProviderError('Error fetching provider: $e'));
  }
});

  }

  Future<void> _fetchProviders(
      FetchProvidersEvent event, Emitter<ProviderState> emit) async {
    emit(ProviderLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        emit(ProviderError("Authentication token not found."));
        return;
      }

      final response = await http.get(
        Uri.parse(baseUrl + 'providers'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final providers = data.map((json) => Provider.fromJson(json)).toList();
        emit(ProvidersLoaded(providers));
      } else {
        emit(ProviderError("Failed to fetch providers."));
      }
    } catch (e) {
      emit(ProviderError("Error: $e"));
    }
  }

  Future<void> _createProvider(
      CreateProviderEvent event, Emitter<ProviderState> emit) async {
    emit(ProviderLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        emit(ProviderError("Authentication token not found."));
        return;
      }

      final response = await http.post(
        Uri.parse(baseUrl + 'create_providers'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'name': event.name}),
      );

      if (response.statusCode == 201) {
        emit(ProviderSuccess("Поставщик успешно создан!."));
      } else {
        emit(ProviderError("Не удалось создать поставщика."));
      }
    } catch (e) {
      emit(ProviderError("Error: $e"));
    }
  }

  Future<void> _updateProvider(
  UpdateProviderEvent event, 
  Emitter<ProviderState> emit
) async {
  emit(ProviderLoading());

  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      emit(ProviderError("Authentication token not found."));
      return;
    }

    // PATCH references/provider/{id}
    final url = Uri.parse('${baseUrl}references/provider/${event.id}');
    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'name': event.name}),
    );

    if (response.statusCode == 200) {
      emit(ProviderSuccess("Поставщик успешно обновлён."));
    } else {
      final errorData = jsonDecode(response.body);
      emit(ProviderError(errorData['message'] ?? "Не удалось обновить поставщика."));
    }
  } catch (e) {
    emit(ProviderError("Error: $e"));
  }
}

  Future<void> _deleteProvider(
      DeleteProviderEvent event, Emitter<ProviderState> emit) async {
    emit(ProviderLoading());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        emit(ProviderError("Authentication token not found."));
        return;
      }

      final response = await http.delete(
        Uri.parse(baseUrl + 'providers/${event.id}'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        emit(ProviderSuccess("Provider successfully deleted."));
      } else {
        emit(ProviderError("Failed to delete provider."));
      }
    } catch (e) {
      emit(ProviderError("Error: $e"));
    }
  }
}
