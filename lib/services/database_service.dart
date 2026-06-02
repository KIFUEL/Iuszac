import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/legal_update.dart';
import '../models/forum_post.dart';
import '../models/forum_comment.dart';
import '../models/mentor.dart';
import '../models/legal_code.dart';
import '../models/legal_article.dart';
import '../models/mentorship_session.dart';

class DatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 1. Actualizaciones Legales (Reformas)
  Future<List<LegalUpdate>> getLegalUpdates() async {
    final response = await _supabase
        .from('legal_updates')
        .select('*, profiles(*)')
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => LegalUpdate.fromJson(json))
        .toList();
  }

  // 2. Foro (Publicaciones)
  Future<List<ForumPost>> getForumPosts() async {
    final response = await _supabase
        .from('forum_posts')
        .select('*, profiles(*)')
        .order('created_at', ascending: false);

    return (response as List).map((json) => ForumPost.fromJson(json)).toList();
  }

  Future<ForumPost> createForumPost(String title, String content,
      {List<String> tags = const [], bool isUrgent = false}) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Inicia sesión para poder publicar');

    final response = await _supabase
        .from('forum_posts')
        .insert({
          'title': title,
          'content': content,
          'user_id': userId,
          'tags': tags,
          'is_urgent': isUrgent,
        })
        .select('*, profiles(*)')
        .single();

    return ForumPost.fromJson(response);
  }

  // 3. Foro (Comentarios)
  Future<List<ForumComment>> getCommentsForPost(String postId) async {
    final response = await _supabase
        .from('forum_comments')
        .select('*, profiles(*)')
        .eq('post_id', postId)
        .order('created_at', ascending: true);

    return (response as List)
        .map((json) => ForumComment.fromJson(json))
        .toList();
  }

  Future<ForumComment> createComment(String postId, String content) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Inicia sesión para comentar');

    final response = await _supabase
        .from('forum_comments')
        .insert({
          'post_id': postId,
          'content': content,
          'user_id': userId,
        })
        .select('*, profiles(*)')
        .single();

    return ForumComment.fromJson(response);
  }

  // 4. Directorio de Mentores / Sesiones
  Future<List<Mentor>> getMentors() async {
    final response = await _supabase.from('mentors').select('*, profiles(*)');

    return (response as List).map((json) => Mentor.fromJson(json)).toList();
  }

  Future<List<MentorshipSession>> getMentorshipSessions() async {
    final now = DateTime.now().toIso8601String();
    final response = await _supabase
        .from('mentorship_sessions')
        .select('*, profiles:profiles!mentorship_sessions_mentor_id_fkey(*)')
        .or('expires_at.is.null,expires_at.gt.$now')
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => MentorshipSession.fromJson(json))
        .toList();
  }

  Future<List<MentorshipSession>> getEnrolledSessions() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabase
        .from('mentorship_enrollments')
        .select(
            'mentorship_sessions(*, profiles:profiles!mentorship_sessions_mentor_id_fkey(*))')
        .eq('user_id', userId);

    return (response as List)
        .map((json) => MentorshipSession.fromJson(json['mentorship_sessions']))
        .toList();
  }

  Future<void> enrollInSession(String sessionId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Inicia sesión para inscribirte');

    await _supabase.from('mentorship_enrollments').insert({
      'session_id': sessionId,
      'user_id': userId,
    });
  }

  Future<MentorshipSession> createMentorshipSession({
    required String title,
    required String description,
    required String specialty,
    required double price,
    required int availableSlots,
    DateTime? expiresAt,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Inicia sesión para poder crear una mentoría');
    }

    final response = await _supabase
        .from('mentorship_sessions')
        .insert({
          'mentor_id': userId,
          'title': title,
          'description': description,
          'specialty': specialty,
          'price': price,
          'available_slots': availableSlots,
          'expires_at': expiresAt?.toIso8601String(),
        })
        .select('*, profiles:profiles!mentorship_sessions_mentor_id_fkey(*)')
        .single();

    return MentorshipSession.fromJson(response);
  }

  // 5. Códigos y Artículos
  Future<List<LegalCode>> getLegalCodes() async {
    final response = await _supabase
        .from('legal_codes')
        .select('*, article_count:legal_articles(count)')
        .order('name', ascending: true);

    return (response as List).map((json) {
      final data = Map<String, dynamic>.from(json);
      if (data['article_count'] is List &&
          (data['article_count'] as List).isNotEmpty) {
        data['article_count'] = data['article_count'][0]['count'];
      } else {
        data['article_count'] = 0;
      }
      return LegalCode.fromJson(data);
    }).toList();
  }

  Future<List<LegalArticle>> getArticlesByCode(String codeId) async {
    final response = await _supabase
        .from('legal_articles')
        .select('*, legal_codes(*)')
        .eq('code_id', codeId)
        .order('number', ascending: true);

    return (response as List)
        .map((json) => LegalArticle.fromJson(json))
        .toList();
  }

  Future<LegalArticle?> getFeaturedArticle() async {
    final response = await _supabase
        .from('legal_articles')
        .select('*, legal_codes(*)')
        .limit(1)
        .maybeSingle();

    if (response == null) return null;
    return LegalArticle.fromJson(response);
  }
}
