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
      id: json['id'] ?? 0,
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

  User copyWith({
    int? id,
    String? login,
    String? name,
    int? followersCount,
    int? followingCount,
    bool? isFollowing,
    int? followId,
    bool forceFollowIdToNull = false,
  }) {
    return User(
      id: id ?? this.id,
      login: login ?? this.login,
      name: name ?? this.name,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      isFollowing: isFollowing ?? this.isFollowing,
      followId: forceFollowIdToNull ? null : followId ?? this.followId,
      createdAt: this.createdAt, 
      updatedAt: this.updatedAt, 
    );
  }
}
