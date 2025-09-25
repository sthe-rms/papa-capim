class User {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String? profilePicture; // A foto de perfil pode ser nula

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profilePicture,
  });

  // Factory constructor para criar um User a partir de um JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      profilePicture: json['profile_picture'],
    );
  }
}
