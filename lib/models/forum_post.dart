import 'profile.dart';

class ForumPost {
  final String id;
  final String title;
  final String content;
  final String userId;
  final DateTime createdAt;
  final Profile? author;

  ForumPost({
    required this.id,
    required this.title,
    required this.content,
    required this.userId,
    required this.createdAt,
    this.author,
  });

  factory ForumPost.fromJson(Map<String, dynamic> json) {
    return ForumPost(
      id: json['id'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      userId: json['user_id'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      author: json['profiles'] != null 
          ? Profile.fromJson(json['profiles']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
