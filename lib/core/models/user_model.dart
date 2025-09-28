class User {
  final int? id;   
  final String login;
  final String name;

  User({
    this.id,
    required this.login,
    required this.name,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],  
      login: json['login'] ?? '',
      name: json['name'] ?? '',
    );
  }
}
