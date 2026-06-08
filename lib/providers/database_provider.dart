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
import '../models/saved_article.dart';
import '../models/profile.dart';
import 'auth_provider.dart';

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

// Proveedor para obtener los artículos de un código específico
final articlesByCodeProvider =
    FutureProvider.family<List<LegalArticle>, String>((ref, codeId) async {
  final dbService = ref.watch(databaseServiceProvider);
  return await dbService.getArticlesByCode(codeId);
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

// Proveedor para las estadísticas reales del perfil del usuario
final profileStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return {'saved': 0, 'aportes': 0, 'mentorias': 0};
  final dbService = ref.watch(databaseServiceProvider);
  return await dbService.getProfileStats(userId);
});

// Proveedor para los artículos guardados (bookmarks) del usuario
final savedArticlesProvider = FutureProvider<List<SavedArticle>>((ref) async {
  final dbService = ref.watch(databaseServiceProvider);
  return await dbService.getSavedArticles();
});

// Proveedor para verificar si un artículo específico está guardado
final isArticleSavedProvider =
    FutureProvider.family<bool, String>((ref, articleId) async {
  final dbService = ref.watch(databaseServiceProvider);
  return await dbService.isArticleSaved(articleId);
});

// Proveedor para obtener las mentorías de un mentor específico (incluye expiradas)
final myMentorshipSessionsProvider =
    FutureProvider.family<List<MentorshipSession>, String>((ref, mentorId) async {
  final dbService = ref.watch(databaseServiceProvider);
  return await dbService.getMentorshipSessionsByMentor(mentorId);
});

// Proveedor para obtener la lista de todos los usuarios (perfiles)
final allUsersProvider = FutureProvider<List<Profile>>((ref) async {
  final dbService = ref.watch(databaseServiceProvider);
  return await dbService.getAllUsers();
});

// Proveedor para obtener los mentores del sistema
final mentorUsersProvider = FutureProvider<List<Profile>>((ref) async {
  final users = await ref.watch(allUsersProvider.future);
  return users.where((u) => u.userType == 'mentor').toList();
});

// Proveedor para obtener los usuarios suspendidos
final suspendedUsersProvider = FutureProvider<List<Profile>>((ref) async {
  final users = await ref.watch(allUsersProvider.future);
  return users.where((u) => u.isSuspended && (u.suspendedUntil == null || u.suspendedUntil!.isAfter(DateTime.now()))).toList();
});

// Proveedor para verificar si el usuario autenticado actual está suspendido
final isSuspendedProvider = Provider<bool>((ref) {
  final profileAsync = ref.watch(userProfileProvider);
  return profileAsync.maybeWhen(
    data: (profile) {
      if (profile == null) return false;
      if (profile.isSuspended) {
        if (profile.suspendedUntil == null) return true;
        return profile.suspendedUntil!.isAfter(DateTime.now());
      }
      return false;
    },
    orElse: () => false,
  );
});

// Proveedor para obtener comentarios recientes con sus posts correspondientes
final recentCommentsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final dbService = ref.watch(databaseServiceProvider);
  return await dbService.getAllRecentCommentsWithPostTitle();
});

