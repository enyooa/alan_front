import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cash_control/bloc/blocs/courier_page_blocs/events/chat_event.dart';
import 'package:cash_control/bloc/blocs/courier_page_blocs/states/chat_state.dart';
import 'package:cash_control/ui/courier/widgets/chat_service.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatService chatService;
  Timer? _pollingTimer;

  ChatBloc(this.chatService) : super(ChatInitial()) {
    on<ConnectWebSocket>((event, emit) {
      _startPolling(emit);
    });

    on<SendMessageEvent>((event, emit) async {
      try {
        await chatService.sendMessage('1', event.content); // Replace '1' with actual user ID
        add(FetchMessagesEvent());
      } catch (e) {
        emit(ChatError('Failed to send message: $e'));
      }
    });

    on<FetchMessagesEvent>((event, emit) async {
      try {
        final messages = await chatService.fetchMessages();
        final formattedMessages = messages.map((e) => e['message'].toString()).toList();
        emit(ChatMessageReceived(formattedMessages));
      } catch (e) {
        emit(ChatError('Failed to fetch messages: $e'));
      }
    });
  }

  void _startPolling(Emitter<ChatState> emit) {
    emit(ChatLoading());
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      add(FetchMessagesEvent());
    });
    emit(ChatConnected());
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }
}
