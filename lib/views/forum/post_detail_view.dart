import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/database_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/forum_post.dart';
import '../../models/forum_comment.dart';
import '../../widgets/common_widgets.dart';

class PostDetailView extends ConsumerStatefulWidget {
  final String postId;

  const PostDetailView({super.key, required this.postId});

  @override
  ConsumerState<PostDetailView> createState() => _PostDetailViewState();
}

class _PostDetailViewState extends ConsumerState<PostDetailView> {
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

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

    try {
      final dbService = ref.read(databaseServiceProvider);
      await dbService.createComment(widget.postId, text);
      _commentController.clear();
      ref.invalidate(forumCommentsProvider(widget.postId));
      ref.invalidate(forumPostsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al comentar: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _closePost(String postId) async {
    try {
      final dbService = ref.read(databaseServiceProvider);
      await dbService.closeForumPost(postId);
      ref.invalidate(forumPostsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El hilo ha sido cerrado por el autor.'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cerrar hilo: $e'), backgroundColor: Colors.red),
        );
      }
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

    try {
      final dbService = ref.read(databaseServiceProvider);
      await dbService.deleteForumPost(postId);
      ref.invalidate(forumPostsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Publicación eliminada correctamente.'), backgroundColor: Colors.green),
        );
        context.go('/forum');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e'), backgroundColor: Colors.red),
        );
      }
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
              try {
                final dbService = ref.read(databaseServiceProvider);
                await dbService.updateForumPost(post.id, title, content, tags: post.tags, isUrgent: post.isUrgent);
                ref.invalidate(forumPostsProvider);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al actualizar: $e'), backgroundColor: Colors.red),
                  );
                }
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
              try {
                final dbService = ref.read(databaseServiceProvider);
                await dbService.updateForumComment(comment.id, content);
                ref.invalidate(forumCommentsProvider(widget.postId));
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al actualizar: $e'), backgroundColor: Colors.red),
                  );
                }
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

    try {
      final dbService = ref.read(databaseServiceProvider);
      await dbService.deleteForumComment(comment.id);
      ref.invalidate(forumCommentsProvider(widget.postId));
      ref.invalidate(forumPostsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar comentario: $e'), backgroundColor: Colors.red),
        );
      }
    }
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
        title: const Text('Hilo de Discusión'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/forum'),
        ),
        elevation: 0,
        scrolledUnderElevation: 1,
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

          final postDate = DateFormat('dd/MM/yyyy HH:mm').format(post.createdAt);
          final postAuthor = post.author?.fullName ?? 'Usuario';
          final postSemester = post.author?.semesterDegree ?? 'N/A';
          final isAuthor = post.userId == currentUserId;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    // ── Tarjeta Principal del Post ─────────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.08)),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Barra de acento si es urgente
                          if (post.isUrgent)
                            Container(
                              height: 4,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                gradient: LinearGradient(
                                  colors: [Colors.red, Colors.orangeAccent],
                                ),
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
                                        radius: 20,
                                        backgroundColor: Colors.transparent,
                                        child: Text(
                                          postAuthor[0].toUpperCase(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            postAuthor,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                          ),
                                          Text(
                                            '$postSemester · $postDate',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (post.isClosed)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                                        ),
                                        child: const Text(
                                          'CERRADO',
                                          style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    else if (post.isUrgent)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 14),
                                            SizedBox(width: 4),
                                            Text('URGENTE', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                    if (isAuthor && !post.isClosed)
                                      PopupMenuButton<String>(
                                        icon: const Icon(Icons.more_vert),
                                        onSelected: (value) {
                                          if (value == 'edit') {
                                            _showEditPostDialog(post!);
                                          } else if (value == 'close') {
                                            _closePost(post!.id);
                                          } else if (value == 'delete') {
                                            _deletePost(post!.id);
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                            value: 'edit',
                                            child: Row(
                                              children: [
                                                Icon(Icons.edit, size: 18),
                                                SizedBox(width: 8),
                                                Text('Editar'),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: 'close',
                                            child: Row(
                                              children: [
                                                Icon(Icons.lock_outline, size: 18),
                                                SizedBox(width: 8),
                                                Text('Cerrar hilo'),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(Icons.delete, color: Colors.red, size: 18),
                                                SizedBox(width: 8),
                                                Text('Eliminar', style: TextStyle(color: Colors.red)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                if (post.tags.isNotEmpty) ...[
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: post.tags.map((tag) => Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '#$tag',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: colorScheme.secondary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    )).toList(),
                                  ),
                                  const SizedBox(height: 14),
                                ],
                                Text(
                                  post.title,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        height: 1.3,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                Divider(height: 1, color: colorScheme.outline.withValues(alpha: 0.08)),
                                const SizedBox(height: 12),
                                Text(
                                  post.content,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Sección de Respuestas ──────────────────────────
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 18,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Respuestas',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Listado de Comentarios
                    commentsAsync.when(
                      data: (comments) {
                        if (comments.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(40.0),
                              child: Column(
                                children: [
                                  Icon(Icons.chat_bubble_outline_rounded, size: 48, color: colorScheme.outline),
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
                            return _buildCommentCard(context, comment, post!.isClosed, currentUserId);
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
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    border: Border(
                      top: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline, color: colorScheme.outline, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Este hilo ha sido cerrado por el autor',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border(
                      top: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1)),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Expanded(
                          child: LawTextField(
                            label: 'Escribe tu respuesta...',
                            icon: Icons.chat_bubble_outline,
                            controller: _commentController,
                          ),
                        ),
                        const SizedBox(width: 12),
                        _isSubmitting
                            ? const SizedBox(
                                height: 40,
                                width: 40,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Container(
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
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: FloatingActionButton.small(
                                  onPressed: _submitComment,
                                  elevation: 0,
                                  backgroundColor: Colors.transparent,
                                  child: const Icon(Icons.send_rounded, color: Colors.white),
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

  Widget _buildCommentCard(BuildContext context, ForumComment comment, bool isPostClosed, String? currentUserId) {
    final colorScheme = Theme.of(context).colorScheme;
    final authorName = comment.author?.fullName ?? 'Colega';
    final date = DateFormat('dd/MM/yyyy HH:mm').format(comment.createdAt);
    final isCommentAuthor = comment.userId == currentUserId;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        decoration: BoxDecoration(
          color: comment.isSolution
              ? Colors.green.withValues(alpha: 0.05)
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: comment.isSolution
                ? Colors.green.withValues(alpha: 0.3)
                : colorScheme.outline.withValues(alpha: 0.06),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (comment.isSolution)
                Container(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 14),
                      SizedBox(width: 6),
                      Text(
                        'SOLUCIÓN ACEPTADA',
                        style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
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
                    child: Text(
                      authorName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(date, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  if (isCommentAuthor && !isPostClosed)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, size: 16),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEditCommentDialog(comment);
                        } else if (value == 'delete') {
                          _deleteComment(comment);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 16),
                              SizedBox(width: 8),
                              Text('Editar'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red, size: 16),
                              SizedBox(width: 8),
                              Text('Eliminar', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                comment.content,
                style: const TextStyle(height: 1.5, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
