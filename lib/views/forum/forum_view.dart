import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/database_provider.dart';
import '../../models/forum_post.dart';
import '../../widgets/common_widgets.dart';

class ForumView extends ConsumerStatefulWidget {
  const ForumView({super.key});

  @override
  ConsumerState<ForumView> createState() => _ForumViewState();
}

class _ForumViewState extends ConsumerState<ForumView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(forumPostsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Foro de Dudas — Derecho UAZ'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Recientes'),
            Tab(text: 'Sin respuesta'),
            Tab(text: '#Constitucional'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(forumPostsProvider),
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: postsAsync.when(
        data: (posts) {
          if (posts.isEmpty) {
            return const Center(child: Text('No hay publicaciones.'));
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildPostList(posts), // Recientes
              _buildPostList(posts.where((p) => p.replyCount == 0).toList()), // Sin respuesta
              _buildPostList(posts.where((p) => p.tags.contains('Constitucional')).toList()), // Por materia
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/forum/new'),
        child: const Icon(Icons.edit_note_rounded),
      ),
    );
  }

  Widget _buildPostList(List<ForumPost> posts) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return _buildPostCard(context, posts[index]);
      },
    );
  }

  Widget _buildPostCard(BuildContext context, ForumPost post) {
    final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(post.createdAt);
    final authorName = post.author?.fullName ?? 'Usuario';
    final semester = post.author?.semesterDegree ?? 'N/A';
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.go('/forum/${post.id}'),
        borderRadius: BorderRadius.circular(20),
        child: LawCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: colorScheme.secondaryContainer,
                    child: Text(
                      authorName[0].toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authorName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Text(
                          '$semester · $formattedDate',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  if (post.isUrgent)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'URGENTE',
                        style: TextStyle(color: Colors.red, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (post.tags.isNotEmpty) ...[
                Wrap(
                  spacing: 6,
                  children: post.tags.map((tag) => Text(
                    '#$tag',
                    style: TextStyle(color: colorScheme.primary, fontSize: 11, fontWeight: FontWeight.bold),
                  )).toList(),
                ),
                const SizedBox(height: 8),
              ],
              Text(
                post.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 8),
              Text(
                post.content,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Icon(Icons.chat_bubble_outline, size: 16, color: colorScheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    '${post.replyCount} respuestas',
                    style: TextStyle(color: colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
