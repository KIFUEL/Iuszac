import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/database_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/forum_post.dart';
import '../../models/forum_comment.dart';

class PostDetailView extends ConsumerStatefulWidget {
  final String postId;

  const PostDetailView({super.key, required this.postId});

  @override
  ConsumerState<PostDetailView> createState() => _PostDetailViewState();
}

class _PostDetailViewState extends ConsumerState<PostDetailView> {
  final _commentController = TextEditingController();
  bool _isSubmitting = false;
  final Set<String> _usefulComments = {};

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isSubmitting = true;
    });

    final messenger = ScaffoldMessenger.of(context);
    try {
      final dbService = ref.read(databaseServiceProvider);
      await dbService.createComment(widget.postId, text);
      _commentController.clear();
      ref.invalidate(forumCommentsProvider(widget.postId));
      ref.invalidate(forumPostsProvider);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error al comentar: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _closePost(String postId) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final dbService = ref.read(databaseServiceProvider);
      await dbService.closeForumPost(postId);
      ref.invalidate(forumPostsProvider);
      messenger.showSnackBar(
        const SnackBar(content: Text('El hilo ha sido cerrado por el autor.'), backgroundColor: Colors.green),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error al cerrar hilo: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deletePost(String postId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar publicación?'),
        content: const Text('Esta acción es irreversible y eliminará todos sus comentarios.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    try {
      final dbService = ref.read(databaseServiceProvider);
      await dbService.deleteForumPost(postId);
      ref.invalidate(forumPostsProvider);
      messenger.showSnackBar(
        const SnackBar(content: Text('Publicación eliminada correctamente.'), backgroundColor: Colors.green),
      );
      router.go('/forum');
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error al eliminar: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showEditPostDialog(ForumPost post) {
    final titleController = TextEditingController(text: post.title);
    final contentController = TextEditingController(text: post.content);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar publicación'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              final title = titleController.text.trim();
              final content = contentController.text.trim();
              if (title.length < 5 || content.length < 10) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Ingresa títulos/descripciones válidas'), backgroundColor: Colors.orange),
                );
                return;
              }
              Navigator.pop(ctx);
              final messenger = ScaffoldMessenger.of(context);
              try {
                final dbService = ref.read(databaseServiceProvider);
                await dbService.updateForumPost(post.id, title, content, tags: post.tags, isUrgent: post.isUrgent);
                ref.invalidate(forumPostsProvider);
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text('Error al actualizar: $e'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showEditCommentDialog(ForumComment comment) {
    final contentController = TextEditingController(text: comment.content);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar comentario'),
        content: TextField(
          controller: contentController,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Comentario'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              final content = contentController.text.trim();
              if (content.isEmpty) return;
              Navigator.pop(ctx);
              final messenger = ScaffoldMessenger.of(context);
              try {
                final dbService = ref.read(databaseServiceProvider);
                await dbService.updateForumComment(comment.id, content);
                ref.invalidate(forumCommentsProvider(widget.postId));
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text('Error al actualizar: $e'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteComment(ForumComment comment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar comentario?'),
        content: const Text('Esta acción removerá tu comentario del foro.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      final dbService = ref.read(databaseServiceProvider);
      await dbService.deleteForumComment(comment.id);
      ref.invalidate(forumCommentsProvider(widget.postId));
      ref.invalidate(forumPostsProvider);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error al eliminar comentario: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _toggleCommentSolution(String commentId, bool currentStatus) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final dbService = ref.read(databaseServiceProvider);
      await dbService.setCommentSolutionStatus(commentId, !currentStatus);
      ref.invalidate(forumCommentsProvider(widget.postId));
      ref.invalidate(forumPostsProvider);
      messenger.showSnackBar(
        SnackBar(
          content: Text(!currentStatus ? 'Comentario aceptado como solución.' : 'Estado de solución removido.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error al cambiar solución: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showPostActionsBottomSheet(BuildContext context, ForumPost post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        final colorScheme = Theme.of(context).colorScheme;
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                24.0,
                20.0,
                24.0,
                20.0 + MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.outline.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Administrar Discusión',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  _buildLargeActionButton(
                    context,
                    icon: Icons.edit_outlined,
                    color: colorScheme.primary,
                    title: 'Editar Publicación',
                    subtitle: 'Modifica el título, contenido o etiquetas',
                    onTap: () {
                      Navigator.pop(ctx);
                      _showEditPostDialog(post);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildLargeActionButton(
                    context,
                    icon: Icons.lock_outline,
                    color: Colors.orange,
                    title: 'Cerrar Hilo de Discusión',
                    subtitle: 'Desactiva nuevas respuestas en este caso',
                    onTap: () {
                      Navigator.pop(ctx);
                      _closePost(post.id);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildLargeActionButton(
                    context,
                    icon: Icons.delete_outline_rounded,
                    color: Colors.redAccent,
                    title: 'Eliminar Caso',
                    subtitle: 'Borra definitivamente el hilo y respuestas',
                    onTap: () {
                      Navigator.pop(ctx);
                      _deletePost(post.id);
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCommentActionsBottomSheet(BuildContext context, ForumComment comment) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        final colorScheme = Theme.of(context).colorScheme;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outline.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Administrar Respuesta',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildLargeActionButton(
                context,
                icon: Icons.edit_note_outlined,
                color: colorScheme.primary,
                title: 'Editar Respuesta',
                subtitle: 'Corrige o actualiza tu aportación al caso',
                onTap: () {
                  Navigator.pop(ctx);
                  _showEditCommentDialog(comment);
                },
              ),
              const SizedBox(height: 12),
              _buildLargeActionButton(
                context,
                icon: Icons.delete_sweep_outlined,
                color: Colors.redAccent,
                title: 'Eliminar Respuesta',
                subtitle: 'Remueve permanentemente esta respuesta',
                onTap: () {
                  Navigator.pop(ctx);
                  _deleteComment(comment);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLargeActionButton(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: color.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      color: color.withValues(alpha: isDark ? 0.08 : 0.04),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRoleColor(String label, ColorScheme colorScheme) {
    final l = label.toLowerCase();
    if (l.contains('docente') || l.contains('mentor') || l.contains('profesor')) {
      return Colors.deepPurple;
    } else if (l.contains('admin') || l.contains('moderador')) {
      return Colors.amber.shade800;
    } else {
      return colorScheme.primary;
    }
  }

  Widget _buildUsefulButton(BuildContext context, String commentId) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLiked = _usefulComments.contains(commentId);
    
    return Container(
      decoration: BoxDecoration(
        color: isLiked
            ? colorScheme.primary.withValues(alpha: 0.12)
            : colorScheme.outline.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLiked
              ? colorScheme.primary.withValues(alpha: 0.3)
              : Colors.transparent,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              if (isLiked) {
                _usefulComments.remove(commentId);
              } else {
                _usefulComments.add(commentId);
              }
            });
            if (!isLiked) {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('¡Gracias por tu retroalimentación! Marcado como útil.'),
                  duration: Duration(seconds: 1),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isLiked ? Icons.thumb_up_rounded : Icons.thumb_up_alt_outlined,
                  size: 14,
                  color: isLiked ? colorScheme.primary : colorScheme.primary.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 8),
                Text(
                  isLiked ? 'Útil (1)' : 'Útil',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isLiked ? colorScheme.primary : colorScheme.primary.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(forumPostsProvider);
    final commentsAsync = ref.watch(forumCommentsProvider(widget.postId));
    final colorScheme = Theme.of(context).colorScheme;
    final currentUserId = ref.watch(userProfileProvider).value?.id;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Caso de Discusión'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/forum'),
        ),
      ),
      body: postsAsync.when(
        data: (posts) {
          ForumPost? post;
          try {
            post = posts.firstWhere((p) => p.id == widget.postId);
          } catch (_) {
            post = null;
          }

          if (post == null) {
            return const Center(child: Text('El post no existe o fue eliminado.'));
          }

          final postDate = DateFormat('dd MMM yyyy, hh:mm a').format(post.createdAt);
          final postAuthor = post.author?.fullName ?? 'Usuario';
          final postAuthorLabel = post.author?.label ?? 'Usuario';
          final postSemester = post.author?.semesterDegree ?? 'UAZ';
          final isAuthor = post.userId == currentUserId;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                  children: [
                    // ── Tarjeta Principal del Post ─────────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.08)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top urgent / state stripe banner
                          if (post.isUrgent)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                                gradient: LinearGradient(
                                  colors: [Colors.redAccent, Colors.orangeAccent],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.warning_amber_rounded, color: Colors.white, size: 16),
                                  SizedBox(width: 8),
                                  Text(
                                    'CASO URGENTE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else if (post.isClosed)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                                color: colorScheme.outline.withValues(alpha: 0.12),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.lock_outline, color: colorScheme.onSurfaceVariant, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    'DISCUSIÓN CERRADA',
                                    style: TextStyle(
                                      color: colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                                color: colorScheme.primary.withValues(alpha: 0.05),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.gavel_rounded, color: colorScheme.primary, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    'DEBATE ABIERTO',
                                    style: TextStyle(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            colorScheme.primary,
                                            colorScheme.secondary,
                                          ],
                                        ),
                                      ),
                                      child: CircleAvatar(
                                        radius: 22,
                                        backgroundColor: Colors.transparent,
                                        child: Text(
                                          postAuthor[0].toUpperCase(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  postAuthor,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              // Author Professional Role Badge
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: _getRoleColor(postAuthorLabel, colorScheme).withValues(alpha: 0.08),
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(color: _getRoleColor(postAuthorLabel, colorScheme).withValues(alpha: 0.2)),
                                                ),
                                                child: Text(
                                                  postAuthorLabel.toUpperCase(),
                                                  style: TextStyle(
                                                    color: _getRoleColor(postAuthorLabel, colorScheme),
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 0.3,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '$postSemester · $postDate',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isAuthor && !post.isClosed)
                                      IconButton(
                                        icon: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: colorScheme.outline.withValues(alpha: 0.05),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.settings, size: 20),
                                        ),
                                        onPressed: () => _showPostActionsBottomSheet(context, post!),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                
                                // Title
                                Text(
                                  post.title,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        height: 1.3,
                                        fontSize: 22,
                                      ),
                                ),
                                const SizedBox(height: 16),
                                
                                // Content blockquote section
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border(
                                      left: BorderSide(
                                        color: colorScheme.primary,
                                        width: 4.5,
                                      ),
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        child: Icon(
                                          Icons.format_quote_rounded,
                                          color: colorScheme.primary.withValues(alpha: 0.08),
                                          size: 48,
                                        ),
                                      ),
                                      Text(
                                        post.content,
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                              height: 1.6,
                                              fontSize: 15,
                                              color: colorScheme.onSurface.withValues(alpha: 0.95),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Tags list
                                if (post.tags.isNotEmpty) ...[
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: post.tags.map((tag) => Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: colorScheme.primaryContainer.withValues(alpha: 0.25),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.15)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.tag_rounded, size: 12, color: colorScheme.primary),
                                          const SizedBox(width: 4),
                                          Text(
                                            tag,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: colorScheme.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )).toList(),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Sección de Respuestas Header ───────────────────
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [colorScheme.primary, colorScheme.secondary],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Respuestas al Caso',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.15)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.forum_outlined, size: 12, color: colorScheme.secondary),
                              const SizedBox(width: 6),
                              Text(
                                '${post.replyCount} ${post.replyCount == 1 ? "aporte" : "aportes"}',
                                style: TextStyle(
                                  color: colorScheme.secondary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Listado de Comentarios
                    commentsAsync.when(
                      data: (comments) {
                        if (comments.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(40.0),
                              child: Column(
                                children: [
                                  Icon(Icons.forum_outlined, size: 48, color: colorScheme.outline.withValues(alpha: 0.5)),
                                  const SizedBox(height: 12),
                                  const Text('Sin respuestas aún. ¡Sé el primero!', style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: comments.length,
                          itemBuilder: (context, index) {
                            final comment = comments[index];
                            return _buildCommentCard(context, comment, post!.isClosed, currentUserId, isAuthor);
                          },
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Text('Error: $err'),
                    ),
                  ],
                ),
              ),

              // ── Input Inferior / Aviso de cerrado ──────────────────
              if (post.isClosed)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                    border: Border(
                      top: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1)),
                    ),
                  ),
                  child: SafeArea(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: colorScheme.error.withValues(alpha: 0.05),
                        border: Border.all(color: colorScheme.error.withValues(alpha: 0.15)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock_outline, color: colorScheme.error, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            'Este hilo ha sido cerrado por el autor',
                            style: TextStyle(
                              color: colorScheme.error,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border(
                      top: BorderSide(color: colorScheme.outline.withValues(alpha: 0.08)),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 15,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Icon(Icons.mode_comment_outlined, size: 20, color: colorScheme.primary.withValues(alpha: 0.7)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _commentController,
                                    decoration: const InputDecoration(
                                      hintText: 'Aporta una solución o respuesta al caso...',
                                      border: InputBorder.none,
                                      hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                                    ),
                                    style: const TextStyle(fontSize: 14),
                                    maxLines: null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _isSubmitting
                            ? const SizedBox(
                                height: 44,
                                width: 44,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : Container(
                                height: 44,
                                width: 44,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [colorScheme.primary, colorScheme.secondary],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: colorScheme.primary.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                                  onPressed: _submitComment,
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildCommentCard(BuildContext context, ForumComment comment, bool isPostClosed, String? currentUserId, bool isAuthorOfPost) {
    final colorScheme = Theme.of(context).colorScheme;
    final authorName = comment.author?.fullName ?? 'Colega';
    final authorLabel = comment.author?.label ?? 'Usuario';
    final date = DateFormat('dd/MM/yyyy HH:mm').format(comment.createdAt);
    final isCommentAuthor = comment.userId == currentUserId;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: comment.isSolution
              ? Colors.green.withValues(alpha: 0.05)
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: comment.isSolution
                ? Colors.green.withValues(alpha: 0.4)
                : colorScheme.outline.withValues(alpha: 0.06),
            width: comment.isSolution ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (comment.isSolution)
                Container(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_rounded, color: Colors.green, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'SOLUCIÓN ACEPTADA',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.secondary,
                          colorScheme.secondary.withValues(alpha: 0.6),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.transparent,
                      child: Text(
                        authorName[0].toUpperCase(),
                        style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            authorName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getRoleColor(authorLabel, colorScheme).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: _getRoleColor(authorLabel, colorScheme).withValues(alpha: 0.15)),
                          ),
                          child: Text(
                            authorLabel.toUpperCase(),
                            style: TextStyle(
                              color: _getRoleColor(authorLabel, colorScheme),
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(date, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  if (isCommentAuthor && !isPostClosed)
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colorScheme.outline.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.more_horiz, size: 16),
                      ),
                      onPressed: () => _showCommentActionsBottomSheet(context, comment),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                comment.content,
                style: TextStyle(
                  height: 1.6,
                  fontSize: 14,
                  color: colorScheme.onSurface.withValues(alpha: 0.95),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _buildUsefulButton(context, comment.id),
                  const Spacer(),
                  if (comment.isSolution && !isAuthorOfPost)
                    Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
                ],
              ),
              if (isAuthorOfPost && !isPostClosed) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => _toggleCommentSolution(comment.id, comment.isSolution),
                    icon: Icon(
                      comment.isSolution ? Icons.cancel_outlined : Icons.check_circle_outline_rounded,
                      size: 16,
                      color: comment.isSolution ? Colors.redAccent : Colors.green,
                    ),
                    label: Text(
                      comment.isSolution ? 'Quitar Solución Aceptada' : 'Aceptar como Solución',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: comment.isSolution ? Colors.redAccent : Colors.green,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      backgroundColor: comment.isSolution
                          ? Colors.redAccent.withValues(alpha: 0.08)
                          : Colors.green.withValues(alpha: 0.08),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: comment.isSolution ? Colors.redAccent.withValues(alpha: 0.2) : Colors.green.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
