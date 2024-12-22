import 'package:bloc/bloc.dart';
import 'package:cash_control/bloc/blocs/common_blocs/events/user_photo_event.dart';
import 'package:cash_control/bloc/blocs/common_blocs/states/user_photo_state.dart';
import 'package:equatable/equatable.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PhotoBloc extends Bloc<PhotoEvent, PhotoState> {
  final String baseUrl;

  PhotoBloc({required this.baseUrl}) : super(PhotoInitial()) {
    on<FetchPhotoEvent>(_onFetchPhoto);
    on<UploadPhotoEvent>(_onUploadPhoto);
  }

  Future<void> _onFetchPhoto(FetchPhotoEvent event, Emitter<PhotoState> emit) async {
    emit(PhotoLoading());
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception('Unauthorized');

      final response = await http.get(
        Uri.parse(baseUrl+'profile'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final photoUrl = data['user']['photo'] ?? '';
        prefs.setString('photo', photoUrl); // Cache the photo URL

        emit(PhotoSuccess(photoUrl));
      } else {
        throw Exception('Failed to fetch photo');
      }
    } catch (e) {
      emit(PhotoError(e.toString()));
    }
  }

  Future<void> _onUploadPhoto(UploadPhotoEvent event, Emitter<PhotoState> emit) async {
    emit(PhotoLoading());
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
        final data = jsonDecode(responseBody);

        final photoUrl = data['photo'];
        prefs.setString('photo', photoUrl); // Update cached photo URL

        emit(PhotoSuccess(photoUrl));
      } else {
        throw Exception('Failed to upload photo');
      }
    } catch (e) {
      emit(PhotoError(e.toString()));
    }
  }
}
