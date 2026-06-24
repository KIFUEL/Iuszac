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
  final bool isClosed;
  final DateTime? closedAt;

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
    this.isClosed = false,
    this.closedAt,
  });

  factory ForumPost.fromJson(Map<String, dynamic> json) {
    int parsedReplyCount = json['reply_count'] ?? 0;
    
    if (json['forum_comments'] != null) {
      if (json['forum_comments'] is List) {
        parsedReplyCount = (json['forum_comments'] as List).length;
      }
    }

    return ForumPost(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      userId: json['user_id'],
      author: json['profiles'] != null ? Profile.fromJson(json['profiles']) : null,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      isClosed: json['is_closed'] ?? false,
      isUrgent: json['is_urgent'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']).toLocal() : DateTime.now().toLocal(),
      closedAt: json['closed_at'] != null ? DateTime.parse(json['closed_at']).toLocal() : null,
      replyCount: parsedReplyCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'is_closed': isClosed,
      'closed_at': closedAt?.toIso8601String(),
    };
  }
}
