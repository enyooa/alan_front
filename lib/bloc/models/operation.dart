class Operation {
  final int id;
  final String operation;
  final String createdAt;
  final String type;

  Operation({
    required this.id,
    required this.operation,
    required this.createdAt,
    required this.type,
  });

  factory Operation.fromJson(Map<String, dynamic> json) {
    return Operation(
      id: int.parse(json['id'].toString()), // Ensure it's an integer
      operation: json['operation'].toString(),
      createdAt: json['created_at'].toString(),
      type: json['type'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'operation': operation,
      'created_at': createdAt,
      'type': type,
    };
  }
}
