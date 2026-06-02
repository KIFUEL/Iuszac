import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/database_provider.dart';
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
    } catch (e) {
      // Manejar error de publicación
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(forumPostsProvider);
    final commentsAsync = ref.watch(forumCommentsProvider(widget.postId));
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hilo de Discusión'),
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
            return const Center(child: Text('El post no existe.'));
          }

          final postDate = DateFormat('dd/MM/yyyy HH:mm').format(post.createdAt);
          final postAuthor = post.author?.fullName ?? 'Usuario';
          final postSemester = post.author?.semesterDegree ?? 'N/A';

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    // Tarjeta Principal del Post
                    LawCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: colorScheme.primaryContainer,
                                child: Text(
                                  postAuthor[0].toUpperCase(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(postAuthor, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text(
                                      '$postSemester · $postDate',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              if (post.isUrgent)
                                const Icon(Icons.warning_amber_rounded, color: Colors.red),
                            ],
                          ),
                          const SizedBox(height: 20),
                          if (post.tags.isNotEmpty) ...[
                            Wrap(
                              spacing: 8,
                              children: post.tags.map((tag) => Chip(
                                label: Text(tag, style: const TextStyle(fontSize: 10)),
                                visualDensity: VisualDensity.compact,
                              )).toList(),
                            ),
                            const SizedBox(height: 12),
                          ],
                          Text(
                            post.title,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            post.content,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    Text(
                      'Respuestas',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    // Listado de Comentarios
                    commentsAsync.when(
                      data: (comments) {
                        if (comments.isEmpty) {
                          return const Center(child: Padding(
                            padding: EdgeInsets.all(40.0),
                            child: Text('Sin respuestas aún.', style: TextStyle(color: Colors.grey)),
                          ));
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: comments.length,
                          itemBuilder: (context, index) {
                            final comment = comments[index];
                            return _buildCommentCard(context, comment);
                          },
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Text('Error: $err'),
                    ),
                  ],
                ),
              ),

              // Input Inferior
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.1))),
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
                          ? const CircularProgressIndicator()
                          : FloatingActionButton.small(
                              onPressed: _submitComment,
                              child: const Icon(Icons.send_rounded),
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

  Widget _buildCommentCard(BuildContext context, ForumComment comment) {
    final colorScheme = Theme.of(context).colorScheme;
    final authorName = comment.author?.fullName ?? 'Colega';
    final date = DateFormat('dd/MM/yyyy HH:mm').format(comment.createdAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Card(
        elevation: 0,
        color: comment.isSolution 
            ? Colors.green.withValues(alpha: 0.05) 
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: comment.isSolution ? Colors.green.withValues(alpha: 0.3) : Colors.transparent,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (comment.isSolution)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'SOLUCIÓN ACEPTADA',
                        style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: colorScheme.secondaryContainer,
                    child: Text(authorName[0], style: const TextStyle(fontSize: 10)),
                  ),
                  const SizedBox(width: 8),
                  Text(authorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const Spacer(),
                  Text(date, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 12),
              Text(comment.content, style: const TextStyle(height: 1.4)),
              const SizedBox(height: 8),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.thumb_up_alt_outlined, size: 14),
                    label: const Text('Útil', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
