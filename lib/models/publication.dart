import 'dart:convert';
import 'profile.dart';

class Publication {
  final String id;
  final String title;
  final String content;
  final String category;
  final String? imageUrl;
  final DateTime createdAt;
  final String? authorId;
  final Profile? author;
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
  final String? eventCost;
  final String? deadline;
  final DateTime? publishedAt;

  // Destacados
  final bool isFeatured;
  final DateTime? featuredUntil;

  // Nuevos campos DOF
  final String? issuingBody;
  final DateTime? entryIntoForce;
  final String? transitoryArticles;

  Publication({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    this.imageUrl,
    required this.createdAt,
    this.authorId,
    this.author,
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
    this.eventCost,
    this.deadline,
    this.publishedAt,
    this.isFeatured = false,
    this.featuredUntil,
    this.issuingBody,
    this.entryIntoForce,
    this.transitoryArticles,
  });

  factory Publication.fromJson(Map<String, dynamic> json) {
    return Publication(
      id: json['id'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      category: json['category'] ?? 'General',
      imageUrl: json['image_url'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
      authorId: json['author_id'],
      author:
          json['profiles'] != null ? Profile.fromJson(json['profiles']) : null,
      oldContent: json['old_content'],
      newContent: json['new_content'],
      status: json['status'] ?? 'published',
      contentType: json['content_type'] ?? 'reforma',
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? <String>[],
      sourceName: json['source_name'],
      sourceUrl: json['source_url'],
      eventStart: json['event_start'] != null ? DateTime.parse(json['event_start']) : null,
      eventEnd: json['event_end'] != null ? DateTime.parse(json['event_end']) : null,
      eventLocation: json['event_location'],
      eventLink: json['event_link'],
      eventCost: json['event_cost'],
      deadline: json['deadline'],
      publishedAt: json['published_at'] != null ? DateTime.parse(json['published_at']) : null,
      isFeatured: json['is_featured'] ?? false,
      featuredUntil: json['featured_until'] != null ? DateTime.parse(json['featured_until']) : null,
      issuingBody: json['issuing_body'],
      entryIntoForce: json['entry_into_force'] != null ? DateTime.parse(json['entry_into_force']) : null,
      transitoryArticles: json['transitory_articles'],
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
      'issuing_body': issuingBody,
      'entry_into_force': entryIntoForce?.toIso8601String(),
      'transitory_articles': transitoryArticles,
    };
  }
}
