import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';
import '../models/legal_update.dart';
import '../models/forum_post.dart';
import '../models/forum_comment.dart';
import '../models/mentor.dart';

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
final forumCommentsProvider = FutureProvider.family<List<ForumComment>, String>((ref, postId) async {
  final dbService = ref.watch(databaseServiceProvider);
  return await dbService.getCommentsForPost(postId);
});

// Proveedor para obtener la lista de mentores
final mentorsProvider = FutureProvider<List<Mentor>>((ref) async {
  final dbService = ref.watch(databaseServiceProvider);
  return await dbService.getMentors();
});
