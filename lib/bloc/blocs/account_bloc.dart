import 'package:bloc/bloc.dart';
import 'package:cash_control/bloc/events/account_event.dart';
import 'package:cash_control/bloc/states/account_state.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AccountBloc extends Bloc<AccountEvent, AccountState> {
  AccountBloc() : super(AccountInitial()) {
    on<LoadUserData>(_onLoadUserData);
    on<ToggleNotification>(_onToggleNotification);
    on<Logout>(_onLogout);
  }

  Future<void> _onLoadUserData(LoadUserData event, Emitter<AccountState> emit) async {
    emit(AccountLoading());
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final firstName = prefs.getString('first_name') ?? '';
      final lastName = prefs.getString('last_name') ?? '';
      final surname = prefs.getString('surname') ?? '';
      final fullName = '$firstName $lastName $surname'.trim();
      final whatsappNumber = prefs.getString('whatsapp_number') ?? '';
      final isNotificationEnabled = prefs.getBool('notifications') ?? true;

      emit(AccountLoaded(
        fullName: fullName,
        whatsappNumber: whatsappNumber,
        isNotificationEnabled: isNotificationEnabled,
      ));
    } catch (e) {
      emit(AccountError('Failed to load user data'));
    }
  }

  Future<void> _onToggleNotification(ToggleNotification event, Emitter<AccountState> emit) async {
    if (state is AccountLoaded) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications', event.isEnabled);

      emit((state as AccountLoaded).copyWith(isNotificationEnabled: event.isEnabled));
    }
  }

  Future<void> _onLogout(Logout event, Emitter<AccountState> emit) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    emit(AccountLoggedOut());
  }
}
