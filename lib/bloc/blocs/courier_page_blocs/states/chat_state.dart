abstract class ChatState {}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatConnected extends ChatState {}

class ChatMessageReceived extends ChatState {
  final List<String> messages;

  ChatMessageReceived(this.messages);
}

class ChatError extends ChatState {
  final String error;

  ChatError(this.error);
}
