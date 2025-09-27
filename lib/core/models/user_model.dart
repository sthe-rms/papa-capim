class User {
  final int id;
  final String name;
  final String login; // CORREÇÃO: Alterado de 'email' para 'login'

  User({required this.id, required this.name, required this.login});

  // Factory constructor para criar um User a partir de um JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(id: json['id'], name: json['name'], login: json['login']);
  }
}
