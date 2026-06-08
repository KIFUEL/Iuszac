import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/database_provider.dart';

class AdminModerationView extends ConsumerWidget {
  const AdminModerationView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {


    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Moderación de Contenido',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.forum_outlined), text: 'Publicaciones'),
              Tab(icon: Icon(Icons.comment_outlined), text: 'Comentarios'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPostsTab(context, ref),
            _buildCommentsTab(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsTab(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(forumPostsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(forumPostsProvider),
      child: postsAsync.when(
        data: (posts) {
          if (posts.isEmpty) {
            return _buildEmptyState(context, 'No hay publicaciones en el foro');
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(post.createdAt);
              final authorName = post.author?.fullName ?? 'Usuario';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Por: $authorName (${post.author?.label ?? 'Usuario'})',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            dateStr,
                            style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        post.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        post.content,
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '💬 ${post.replyCount} respuestas',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                          Row(
                            children: [
                              TextButton.icon(
                                onPressed: () => context.push('/forum/${post.id}'),
                                icon: const Icon(Icons.visibility, size: 16),
                                label: const Text('Ver', style: TextStyle(fontSize: 12)),
                              ),
                              const SizedBox(width: 8),
                              TextButton.icon(
                                onPressed: () => _confirmDeletePost(context, ref, post.id),
                                icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                                label: const Text('Eliminar', style: TextStyle(fontSize: 12, color: Colors.red)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text('Error al cargar publicaciones: $err', style: const TextStyle(color: Colors.red)),
          ),
        ),
      ),
    );
  }

  Widget _buildCommentsTab(BuildContext context, WidgetRef ref) {
    final commentsAsync = ref.watch(recentCommentsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(recentCommentsProvider),
      child: commentsAsync.when(
        data: (comments) {
          if (comments.isEmpty) {
            return _buildEmptyState(context, 'No hay comentarios recientes');
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: comments.length,
            itemBuilder: (context, index) {
              final comment = comments[index];
              final id = comment['id'] as String;
              final postId = comment['post_id'] as String;
              final content = comment['content'] as String;
              final createdAt = comment['created_at'] != null
                  ? DateTime.parse(comment['created_at'])
                  : DateTime.now();
              final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(createdAt);
              
              final authorProfile = comment['profiles'];
              final authorName = authorProfile != null ? authorProfile['full_name'] as String : 'Usuario';
              final authorLabel = authorProfile != null ? authorProfile['label'] as String? ?? 'Usuario' : 'Usuario';
              
              final postObj = comment['forum_posts'];
              final postTitle = postObj != null ? postObj['title'] as String : 'Publicación';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Por: $authorName ($authorLabel)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            dateStr,
                            style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'En: "$postTitle"',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onPrimaryContainer,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        content,
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () => context.push('/forum/$postId'),
                            icon: const Icon(Icons.visibility, size: 16),
                            label: const Text('Ver hilo', style: TextStyle(fontSize: 12)),
                          ),
                          const SizedBox(width: 8),
                          TextButton.icon(
                            onPressed: () => _confirmDeleteComment(context, ref, id),
                            icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                            label: const Text('Eliminar', style: TextStyle(fontSize: 12, color: Colors.red)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text('Error al cargar comentarios: $err', style: const TextStyle(color: Colors.red)),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 64, color: colorScheme.primary.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _confirmDeletePost(BuildContext context, WidgetRef ref, String postId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar publicación?'),
        content: const Text(
          'Esta acción es irreversible. Al eliminar la publicación, también se eliminarán todos sus comentarios asociados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await ref.read(databaseServiceProvider).deleteForumPost(postId);
                ref.invalidate(forumPostsProvider);
                ref.invalidate(recentCommentsProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Publicación eliminada correctamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al eliminar publicación: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteComment(BuildContext context, WidgetRef ref, String commentId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar comentario?'),
        content: const Text('Esta acción es irreversible y removerá el comentario del foro.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await ref.read(databaseServiceProvider).deleteForumComment(commentId);
                ref.invalidate(recentCommentsProvider);
                ref.invalidate(forumPostsProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Comentario eliminado correctamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al eliminar comentario: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
