import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/legal_update.dart';
import '../models/forum_post.dart';
import '../models/forum_comment.dart';
import '../models/mentor.dart';

class DatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 1. Actualizaciones Legales (Reformas)
  Future<List<LegalUpdate>> getLegalUpdates() async {
    final response = await _supabase
        .from('legal_updates')
        .select('*, profiles(*)')
        .order('created_at', ascending: false);
    
    return (response as List).map((json) => LegalUpdate.fromJson(json)).toList();
  }

  // 2. Foro (Publicaciones)
  Future<List<ForumPost>> getForumPosts() async {
    final response = await _supabase
        .from('forum_posts')
        .select('*, profiles(*)')
        .order('created_at', ascending: false);

    return (response as List).map((json) => ForumPost.fromJson(json)).toList();
  }

  Future<ForumPost> createForumPost(String title, String content) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Inicia sesión para poder publicar');

    final response = await _supabase
        .from('forum_posts')
        .insert({
          'title': title,
          'content': content,
          'user_id': userId,
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

    return (response as List).map((json) => ForumComment.fromJson(json)).toList();
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

  // 4. Directorio de Mentores
  Future<List<Mentor>> getMentors() async {
    final response = await _supabase
        .from('mentors')
        .select('*, profiles(*)');

    return (response as List).map((json) => Mentor.fromJson(json)).toList();
  }
}
