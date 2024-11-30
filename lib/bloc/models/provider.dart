class Provider {
  final int id;
  final String name;

  Provider({required this.id, required this.name});

  factory Provider.fromJson(Map<String, dynamic> json) {
    return Provider(
      id: json['id'],
      name: json['name'],
    );
  }
}
