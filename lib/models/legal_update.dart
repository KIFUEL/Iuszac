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

  LegalUpdate({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    this.imageUrl,
    required this.createdAt,
    this.authorId,
    this.author,
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
      'category': category,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
      'author_id': authorId,
    };
  }
}
