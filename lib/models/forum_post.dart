import 'profile.dart';

class ForumPost {
  final String id;
  final String title;
  final String content;
  final String userId;
  final DateTime createdAt;
  final Profile? author;
  final bool isUrgent;
  final List<String> tags;
  final int replyCount;

  ForumPost({
    required this.id,
    required this.title,
    required this.content,
    required this.userId,
    required this.createdAt,
    this.author,
    this.isUrgent = false,
    this.tags = const [],
    this.replyCount = 0,
  });

  factory ForumPost.fromJson(Map<String, dynamic> json) {
    return ForumPost(
      id: json['id'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      userId: json['user_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      author:
          json['profiles'] != null ? Profile.fromJson(json['profiles']) : null,
      isUrgent: json['is_urgent'] ?? false,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      replyCount: json['reply_count'] ?? (json['forum_comments'] as List?)?.length ?? 0,
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
