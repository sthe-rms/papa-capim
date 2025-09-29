class User {
  final int id;
  final String login;
  final String name;
  final int followersCount;
  final int followingCount;
  final bool isFollowing;
  final int? followId;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.login,
    required this.name,
    required this.followersCount,
    required this.followingCount,
    required this.isFollowing,
    this.followId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      login: json['login'],
      name: json['name'],
      followersCount: json['followers_count'] ?? 0,
      followingCount: json['following_count'] ?? 0,
      isFollowing: json['is_following'] ?? false,
      followId: json['follow_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
