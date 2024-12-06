class Message {
  final int id;
  final int userId;
  final String message;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.userId,
    required this.message,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      userId: json['user_id'],
      message: json['message'],
      timestamp: DateTime.parse(json['created_at']),
    );
  }
}
