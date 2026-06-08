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

class _ForumViewState extends ConsumerState<ForumView> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(forumPostsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Foros'),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(forumPostsProvider),
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Motivational gradient banner header
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'Comparte tu caso. Aprende del colectivo.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onPrimaryContainer,
                fontStyle: FontStyle.italic,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: LawTextField(
              label: 'Buscar por hashtag (ej: #penal)',
              icon: Icons.tag,
              controller: _searchController,
              onChanged: (val) {
                setState(() => _searchQuery = val.toLowerCase().trim());
              },
            ),
          ),
          Expanded(
            child: postsAsync.when(
              data: (posts) {
                if (posts.isEmpty) {
                  return const Center(child: Text('No hay publicaciones.'));
                }

                final filteredPosts = posts.where((p) {
                  if (_searchQuery.isEmpty) return true;
                  final searchTag = _searchQuery.startsWith('#')
                      ? _searchQuery.substring(1)
                      : _searchQuery;

                  final matchesTag = p.tags.any((tag) =>
                      tag.toLowerCase().contains(searchTag));
                  final matchesTitle =
                      p.title.toLowerCase().contains(_searchQuery);

                  return matchesTag || matchesTitle;
                }).toList();

                if (filteredPosts.isEmpty) {
                  return const Center(child: Text('No se encontraron resultados.'));
                }

                return _buildPostList(filteredPosts);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
      // Gradient FAB using a decorated container
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => context.go('/forum/new'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.edit_note_rounded, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildPostList(List<ForumPost> posts) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          // Left-side accent border using a Stack
          child: Stack(
            children: [
              LawCard(
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Author avatar with gradient background
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                colorScheme.primaryContainer,
                                colorScheme.secondaryContainer,
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              authorName[0].toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: colorScheme.onPrimaryContainer,
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
                                authorName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              Text(
                                '$semester · $formattedDate',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        if (post.isClosed)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'CERRADO',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                        else if (post.isUrgent)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'URGENTE',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (post.tags.isNotEmpty) ...[
                      Wrap(
                        spacing: 6,
                        children: post.tags
                            .map((tag) => Text(
                                  '#$tag',
                                  style: TextStyle(
                                      color: colorScheme.primary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      post.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      post.content,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Subtle divider above 'Discutir caso' row
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(height: 1, thickness: 0.6),
                    ),
                    Row(
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            size: 16, color: colorScheme.primary),
                        const SizedBox(width: 6),
                        Text(
                          '${post.replyCount} respuestas',
                          style: TextStyle(
                              color: colorScheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_forward_ios,
                            size: 12, color: Colors.grey),
                      ],
                    ),
                  ],
                ),
              ),
              // Left-side accent border (4px wide, primaryContainer color)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
