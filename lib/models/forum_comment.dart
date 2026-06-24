import 'profile.dart';

class ForumComment {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final DateTime createdAt;
  final Profile? author;
  final bool isSolution;

  ForumComment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.createdAt,
    this.author,
    this.isSolution = false,
  });

  factory ForumComment.fromJson(Map<String, dynamic> json) {
    return ForumComment(
      id: json['id'],
      postId: json['post_id'],
      userId: json['user_id'],
      content: json['content'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at']).toLocal()
          : DateTime.now().toLocal(),
      author:
          json['profiles'] != null ? Profile.fromJson(json['profiles']) : null,
      isSolution: json['is_solution'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
