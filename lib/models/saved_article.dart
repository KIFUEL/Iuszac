import '../models/legal_article.dart';

class SavedArticle {
  final String id;
  final String userId;
  final String articleId;
  final DateTime savedAt;
  final LegalArticle? article;

  SavedArticle({
    required this.id,
    required this.userId,
    required this.articleId,
    required this.savedAt,
    this.article,
  });

  factory SavedArticle.fromJson(Map<String, dynamic> json) {
    return SavedArticle(
      id: json['id'],
      userId: json['user_id'],
      articleId: json['article_id'],
      savedAt: DateTime.parse(json['saved_at'] ?? json['created_at']),
      article: json['legal_articles'] != null
          ? LegalArticle.fromJson(json['legal_articles'])
          : null,
    );
  }
}
