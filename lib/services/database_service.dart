import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/legal_update.dart';
import '../models/forum_post.dart';
import '../models/forum_comment.dart';
import '../models/mentor.dart';
import '../models/legal_code.dart';
import '../models/legal_article.dart';
import '../models/mentorship_session.dart';
import '../models/saved_article.dart';


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

  Future<LegalUpdate> createLegalUpdate({
    required String title,
    required String content,
    required String category,
    String? imageUrl,
    String? articleId,
    String? oldContent,
    String? newContent,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Inicia sesión para poder crear una actualización');
    }

    final response = await _supabase
        .from('legal_updates')
        .insert({
          'title': title,
          'content': content,
          'category': category,
          'image_url': imageUrl,
          'author_id': userId,
          'article_id': articleId,
          'old_content': oldContent,
          'new_content': newContent,
        })
        .select('*, profiles(*)')
        .single();

    return LegalUpdate.fromJson(response);
  }

  // 2. Foro (Publicaciones)
  Future<List<ForumPost>> getForumPosts() async {
    final response = await _supabase
        .from('forum_posts')
        .select('*, profiles(*), forum_comments(id)')
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
        .select('*, profiles(*), forum_comments(id)')
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

  // ── 6. Perfil de Usuario ────────────────────────────────────────────────────

  /// Actualiza los datos editables del perfil (nombre, bio, institución, etc.)
  Future<void> updateProfile({
    required String userId,
    String? fullName,
    String? lastName,
    String? bio,
    String? institution,
    String? semesterDegree,
  }) async {
    final updates = <String, dynamic>{};
    if (fullName != null) updates['full_name'] = fullName;
    if (lastName != null) updates['last_name'] = lastName;
    if (bio != null) updates['bio'] = bio;
    if (institution != null) updates['institution'] = institution;
    if (semesterDegree != null) updates['semester_degree'] = semesterDegree;
    if (updates.isEmpty) return;

    await _supabase.from('profiles').update(updates).eq('id', userId);
  }

  /// Actualiza las preferencias de notificación del perfil
  Future<void> updateNotificationPreferences({
    required String userId,
    required bool notifAlertsReforma,
    required bool notifEmailResumen,
    required bool notifForo,
    required bool notifMentoria,
  }) async {
    await _supabase.from('profiles').update({
      'notif_alerts_reforma': notifAlertsReforma,
      'notif_email_resumen': notifEmailResumen,
      'notif_foro': notifForo,
      'notif_mentoria': notifMentoria,
    }).eq('id', userId);
  }

  /// Devuelve estadísticas reales del usuario: artículos guardados, aportes al foro, mentorías
  Future<Map<String, int>> getProfileStats(String userId) async {
    // Usamos count a través de la función .count() que devuelve PostgrestCountResponse
    final savedRes = await _supabase
        .from('saved_articles')
        .select()
        .eq('user_id', userId);

    final forumRes = await _supabase
        .from('forum_posts')
        .select()
        .eq('user_id', userId);

    final mentoriasRes = await _supabase
        .from('mentorship_enrollments')
        .select()
        .eq('user_id', userId);

    return {
      'saved': (savedRes as List).length,
      'aportes': (forumRes as List).length,
      'mentorias': (mentoriasRes as List).length,
    };
  }

  // ── 7. Artículos Guardados (Bookmarks) ────────────────────────────────────

  /// Obtiene los artículos guardados del usuario con la info del artículo
  Future<List<SavedArticle>> getSavedArticles() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabase
        .from('saved_articles')
        .select('*, legal_articles(*, legal_codes(*))')
        .eq('user_id', userId)
        .order('saved_at', ascending: false);

    return (response as List)
        .map((json) => SavedArticle.fromJson(json))
        .toList();
  }

  /// Guarda un artículo en los marcadores del usuario
  Future<void> saveArticle(String articleId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Inicia sesión para guardar artículos');

    await _supabase.from('saved_articles').upsert({
      'user_id': userId,
      'article_id': articleId,
      'saved_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id,article_id');
  }

  /// Elimina un artículo de los marcadores del usuario
  Future<void> unsaveArticle(String articleId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _supabase
        .from('saved_articles')
        .delete()
        .eq('user_id', userId)
        .eq('article_id', articleId);
  }

  /// Verifica si un artículo ya está guardado
  Future<bool> isArticleSaved(String articleId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return false;

    final response = await _supabase
        .from('saved_articles')
        .select('id')
        .eq('user_id', userId)
        .eq('article_id', articleId)
        .maybeSingle();

    return response != null;
  }

  /// Elimina una actualización legal/noticia por su ID
  Future<void> deleteLegalUpdate(String id) async {
    await _supabase.from('legal_updates').delete().eq('id', id);
  }
}

