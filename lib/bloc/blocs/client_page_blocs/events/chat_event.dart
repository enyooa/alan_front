abstract class ChatEvent {}

class ConnectWebSocket extends ChatEvent {}

class SendMessageEvent extends ChatEvent {
  final String content;

  SendMessageEvent(this.content);
}

class FetchMessagesEvent extends ChatEvent {}
