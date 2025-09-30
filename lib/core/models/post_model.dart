class Post {
  final int id;
  final String userLogin;
  final int? postId;
  final String message;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int likesCount;
  final bool isLiked;
  final int? likeId;
  List<Post> replies;

  Post({
    required this.id,
    required this.userLogin,
    this.postId,
    required this.message,
    required this.createdAt,
    required this.updatedAt,
    required this.likesCount,
    required this.isLiked,
    this.likeId,
    this.replies = const [],
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? 0, // Correção aplicada aqui
      userLogin: json['user_login'],
      postId: json['post_id'],
      message: json['message'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      likesCount: json['likes_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
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

  Post copyWith({
    int? id,
    String? userLogin,
    int? postId,
    String? message,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likesCount,
    bool? isLiked,
    int? likeId,
    bool forceLikeIdToNull = false,
    List<Post>? replies,
  }) {
    return Post(
      id: id ?? this.id,
      userLogin: userLogin ?? this.userLogin,
      postId: postId ?? this.postId,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      likeId: forceLikeIdToNull ? null : likeId ?? this.likeId,
      replies: replies ?? this.replies,
    );
  }
}
