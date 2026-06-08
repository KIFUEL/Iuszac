import 'profile.dart';

class MentorshipReview {
  final String id;
  final String sessionId;
  final String userId;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final Profile? user; // El perfil de quien dejó la reseña

  MentorshipReview({
    required this.id,
    required this.sessionId,
    required this.userId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.user,
  });

  factory MentorshipReview.fromJson(Map<String, dynamic> json) {
    return MentorshipReview(
      id: json['id'],
      sessionId: json['session_id'],
      userId: json['user_id'],
      rating: json['rating'] ?? 5,
      comment: json['comment'],
      createdAt: DateTime.parse(json['created_at']),
      user: json['profiles'] != null ? Profile.fromJson(json['profiles']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'user_id': userId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
