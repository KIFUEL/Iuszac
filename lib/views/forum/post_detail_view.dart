import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/database_provider.dart';
import '../../models/forum_post.dart';
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
  String? _commentError;

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
      _commentError = null;
    });

    try {
      final dbService = ref.read(databaseServiceProvider);
      await dbService.createComment(widget.postId, text);
      
      // Limpia el input y recarga los comentarios
      _commentController.clear();
      ref.invalidate(forumCommentsProvider(widget.postId));
    } catch (e) {
      setState(() {
        _commentError = e.toString().replaceAll('Exception:', '').trim();
      });
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
    // Para mostrar los datos del post, podemos buscarlo de la lista que ya cargamos
    // o hacer un fetch. Una manera sencilla es obtenerlo del listado completo.
    final postsAsync = ref.watch(forumPostsProvider);
    final commentsAsync = ref.watch(forumCommentsProvider(widget.postId));

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
          // Buscar el post correspondiente en la lista de posts en caché
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

          return Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
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
                                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                    child: Text(
                                      postAuthor[0].toUpperCase(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.onPrimaryContainer,
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
                                          postDate,
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
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
                        const SizedBox(height: 24),
                        
                        // Sección de Respuestas
                        Text(
                          'Respuestas y Aportaciones',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        
                        // Listado de Comentarios
                        commentsAsync.when(
                          data: (comments) {
                            if (comments.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 24.0),
                                child: Center(
                                  child: Text(
                                    'Aún no hay respuestas. ¡Sé el primero en aportar!',
                                    style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
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
                                final commentAuthor = comment.author?.fullName ?? 'Colega';
                                final commentDate = DateFormat('dd/MM/yyyy HH:mm').format(comment.createdAt);

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: Card(
                                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: BorderSide(color: Colors.grey.withOpacity(0.05)),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 14,
                                                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                                                child: Text(
                                                  commentAuthor[0].toUpperCase(),
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                commentAuthor,
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                              ),
                                              const Spacer(),
                                              Text(
                                                commentDate,
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11, color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            comment.content,
                                            style: const TextStyle(height: 1.4),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          loading: () => const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 24.0),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          error: (err, stack) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24.0),
                            child: Center(
                              child: Text(
                                'Error al cargar respuestas: ${err.toString()}',
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Caja de Texto Inferior para comentar
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      border: Border(
                        top: BorderSide(color: Colors.grey.withOpacity(0.15)),
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_commentError != null) ...[
                            Text(
                              _commentError!,
                              style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                            ),
                            const SizedBox(height: 8),
                          ],
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _commentController,
                                  decoration: InputDecoration(
                                    hintText: 'Aporta tu opinión o fundamento legal...',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    filled: true,
                                    fillColor: Theme.of(context).colorScheme.surface,
                                  ),
                                  maxLines: null,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _isSubmitting
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : CircleAvatar(
                                      backgroundColor: Theme.of(context).colorScheme.primary,
                                      child: IconButton(
                                        icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                                        onPressed: _submitComment,
                                      ),
                                    ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: ${err.toString()}')),
      ),
    );
  }
}
