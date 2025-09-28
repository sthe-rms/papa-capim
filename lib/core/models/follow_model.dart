class Follow {
  final int id;
  final String followerLogin;
  final String followedLogin;
  final DateTime createdAt;
  final DateTime updatedAt;

  Follow({
    required this.id,
    required this.followerLogin,
    required this.followedLogin,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Follow.fromJson(Map<String, dynamic> json) {
    return Follow(
      id: json['id'],
      followerLogin: json['follower_login'],
      followedLogin: json['followed_login'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}