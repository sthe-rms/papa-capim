// lib/core/models/post_model.dart

class Post {
  final int id;
  final String userLogin;
  final int? postId;
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

  // Construtor de cópia para atualizar o estado de forma imutável e segura
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
    bool forceLikeIdToNull = false, // Flag para forçar a nulificação do likeId
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
    );
  }

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
      'likes_count': likesCount,
      'is_liked': isLiked,
      'like_id': likeId,
    };
  }
}
