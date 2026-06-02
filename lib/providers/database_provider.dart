import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/database_service.dart';
import '../models/legal_update.dart';
import '../models/forum_post.dart';
import '../models/forum_comment.dart';
import '../models/mentor.dart';
import '../models/legal_code.dart';
import '../models/legal_article.dart';
import '../models/mentorship_session.dart';

// Proveedor para instanciar el servicio de Base de Datos
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

// Proveedor para obtener la lista de Reformas / Actualizaciones Legales
final legalUpdatesProvider = FutureProvider<List<LegalUpdate>>((ref) async {
  final dbService = ref.watch(databaseServiceProvider);
  return await dbService.getLegalUpdates();
});

// Proveedor para obtener la lista de Hilos de Discusión del Foro
final forumPostsProvider = FutureProvider<List<ForumPost>>((ref) async {
  final dbService = ref.watch(databaseServiceProvider);
  return await dbService.getForumPosts();
});

// Proveedor para obtener los comentarios de un hilo específico
final forumCommentsProvider =
    FutureProvider.family<List<ForumComment>, String>((ref, postId) async {
  final dbService = ref.watch(databaseServiceProvider);
  return await dbService.getCommentsForPost(postId);
});

// Proveedor para obtener la lista de mentores
final mentorsProvider = FutureProvider<List<Mentor>>((ref) async {
  final dbService = ref.watch(databaseServiceProvider);
  return await dbService.getMentors();
});

// Proveedor para obtener la lista de sesiones de mentoría
final mentorshipSessionsProvider =
    FutureProvider<List<MentorshipSession>>((ref) async {
  final dbService = ref.watch(databaseServiceProvider);
  return await dbService.getMentorshipSessions();
});

// Proveedor para obtener las sesiones donde participa el usuario
final enrolledSessionsProvider =
    FutureProvider<List<MentorshipSession>>((ref) async {
  final dbService = ref.watch(databaseServiceProvider);
  return await dbService.getEnrolledSessions();
});

// Proveedor para obtener los códigos legales
final legalCodesProvider = FutureProvider<List<LegalCode>>((ref) async {
  final dbService = ref.watch(databaseServiceProvider);
  return await dbService.getLegalCodes();
});

// Proveedor para obtener el artículo destacado
final featuredArticleProvider = FutureProvider<LegalArticle?>((ref) async {
  final dbService = ref.watch(databaseServiceProvider);
  return await dbService.getFeaturedArticle();
});

// Proveedor para obtener un artículo por su ID
final articleDetailProvider =
    FutureProvider.family<LegalArticle?, String>((ref, articleId) async {
  final response = await Supabase.instance.client
      .from('legal_articles')
      .select('*, legal_codes(*)')
      .eq('id', articleId)
      .maybeSingle();

  if (response == null) return null;
  return LegalArticle.fromJson(response);
});
