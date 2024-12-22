import 'package:bloc/bloc.dart';
import 'package:cash_control/bloc/blocs/common_blocs/events/account_event.dart';
import 'package:cash_control/bloc/blocs/common_blocs/states/account_state.dart';
import 'package:equatable/equatable.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final String baseUrl;

  AccountBloc({required this.baseUrl}) : super(AccountInitial()) {
    on<FetchUserData>(_onFetchUserData);
    on<UploadPhoto>(_onUploadPhoto);
    on<ToggleNotification>(_onToggleNotification);
    on<Logout>(_onLogout);
  }

  Future<void> _onFetchUserData(FetchUserData event, Emitter<AccountState> emit) async {
    emit(AccountLoading());
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception('Unauthorized');

      final response = await http.get(
        Uri.parse(baseUrl+'profile'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['user'];
        final userData = {
          'id': data['id'],
          'fullName': '${data['first_name']} ${data['last_name']}',
          'whatsappNumber': data['whatsapp_number'],
          'photoUrl': data['photo'] ?? '',
          'notifications': prefs.getBool('notifications') ?? true,
        };

        emit(AccountLoaded(userData));
      } else {
        throw Exception('Failed to fetch user data');
      }
    } catch (e) {
      emit(AccountError('Error fetching user data: ${e.toString()}'));
    }
  }

  Future<void> _onUploadPhoto(UploadPhoto event, Emitter<AccountState> emit) async {
    if (state is! AccountLoaded) return;

    emit(AccountLoading());
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception('Unauthorized');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(baseUrl+'uploadPhoto'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('photo', event.photo.path));

      var response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final photoUrl = jsonDecode(responseBody)['photo'];
        prefs.setString('photo', photoUrl);

        emit((state as AccountLoaded).copyWith(photoUrl: photoUrl));
      } else {
        throw Exception('Failed to upload photo');
      }
    } catch (e) {
      emit(AccountError('Error uploading photo: ${e.toString()}'));
    }
  }

  Future<void> _onToggleNotification(ToggleNotification event, Emitter<AccountState> emit) async {
    if (state is! AccountLoaded) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', event.isEnabled);
    emit((state as AccountLoaded).copyWith(notifications: event.isEnabled));
  }

  Future<void> _onLogout(Logout event, Emitter<AccountState> emit) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    emit(AccountLoggedOut());
  }
}
