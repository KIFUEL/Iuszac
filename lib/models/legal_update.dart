import 'dart:convert';
import 'profile.dart';

class LegalUpdate {
  final String id;
  final String title;
  final String content;
  final String category;
  final String? imageUrl;
  final DateTime createdAt;
  final String? authorId;
  final Profile? author;
  final String? articleId;
  final String? oldContent;
  final String? newContent;
  
  // Phase 4 fields
  final String status;
  final String contentType;
  final List<String> tags;
  final String? sourceName;
  final String? sourceUrl;
  final DateTime? eventStart;
  final DateTime? eventEnd;
  final String? eventLocation;
  final String? eventLink;
  final String? deadline;
  final DateTime? publishedAt;

  LegalUpdate({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    this.imageUrl,
    required this.createdAt,
    this.authorId,
    this.author,
    this.articleId,
    this.oldContent,
    this.newContent,
    this.status = 'published',
    this.contentType = 'reforma',
    this.tags = const [],
    this.sourceName,
    this.sourceUrl,
    this.eventStart,
    this.eventEnd,
    this.eventLocation,
    this.eventLink,
    this.deadline,
    this.publishedAt,
  });

  factory LegalUpdate.fromJson(Map<String, dynamic> json) {
    return LegalUpdate(
      id: json['id'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      category: json['category'] ?? 'General',
      imageUrl: json['image_url'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      authorId: json['author_id'],
      author:
          json['profiles'] != null ? Profile.fromJson(json['profiles']) : null,
      articleId: json['article_id'],
      oldContent: json['old_content'],
      newContent: json['new_content'],
      status: json['status'] ?? 'published',
      contentType: json['content_type'] ?? 'reforma',
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      sourceName: json['source_name'],
      sourceUrl: json['source_url'],
      eventStart: json['event_start'] != null ? DateTime.parse(json['event_start']) : null,
      eventEnd: json['event_end'] != null ? DateTime.parse(json['event_end']) : null,
      eventLocation: json['event_location'],
      eventLink: json['event_link'],
      deadline: json['deadline'],
      publishedAt: json['published_at'] != null ? DateTime.parse(json['published_at']) : null,
    );
  }

  String get plainContent {
    try {
      final decoded = jsonDecode(content);
      if (decoded is List) {
        final buffer = StringBuffer();
        for (var op in decoded) {
          if (op is Map && op.containsKey('insert')) {
            final insertVal = op['insert'];
            if (insertVal is String) {
              buffer.write(insertVal);
            }
          }
        }
        return buffer.toString().trim();
      }
    } catch (_) {
      // Fallback to raw content if not JSON
    }
    return content;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
      'author_id': authorId,
      'article_id': articleId,
      'old_content': oldContent,
      'new_content': newContent,
      'status': status,
      'content_type': contentType,
      'tags': tags,
      'source_name': sourceName,
      'source_url': sourceUrl,
      'event_start': eventStart?.toIso8601String(),
      'event_end': eventEnd?.toIso8601String(),
      'event_location': eventLocation,
      'event_link': eventLink,
      'deadline': deadline,
      'published_at': publishedAt?.toIso8601String(),
    };
  }
}
