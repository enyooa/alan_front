class User {
  final int id;
  final String firstName;
  final String lastName;
  final String whatsappNumber;
  final List<Role> roles;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.whatsappNumber,
    required this.roles,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      whatsappNumber: json['whatsapp_number'],
      roles: (json['roles'] as List).map((roleJson) => Role.fromJson(roleJson)).toList(),
    );
  }
}

class Role {
  final int id;
  final String name;

  Role({required this.id, required this.name});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'],
      name: json['name'],
    );
  }
}