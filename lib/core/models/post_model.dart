class Post {
  final int id;
  final String userLogin;
  final int? postId;
  final String message;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? likesCount;
  final bool? isLiked;
  final int? likeId;

  Post({
    required this.id,
    required this.userLogin,
    this.postId,
    required this.message,
    required this.createdAt,
    required this.updatedAt,
    this.likesCount,
    this.isLiked,
    this.likeId,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      userLogin: json['user_login'],
      postId: json['post_id'],
      message: json['message'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      likesCount: json['likes_count'],
      isLiked: json['is_liked'],
      likeId: json['like_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_login': userLogin,
      'post_id': postId,
      'message': message,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
