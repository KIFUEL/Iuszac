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
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 700;
    final horizontalPadding = isWide ? 32.0 : 16.0;

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
            margin: EdgeInsets.fromLTRB(horizontalPadding, 10, horizontalPadding, 0),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
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
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
                height: 1.4,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(horizontalPadding, 14, horizontalPadding, 6),
            child: LawTextField(
              label: 'Buscar por hashtag (ej: #penal)',
              icon: Icons.tag,
              controller: _searchController,
              onChanged: (val) {
                setState(() => _searchQuery = val.toLowerCase().trim());
              },
            ),
          ),
          // Separator between search and results
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Divider(
              height: 20,
              thickness: 1,
              color: colorScheme.outlineVariant.withValues(alpha: 0.4),
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

                return _buildPostList(filteredPosts, isWide, horizontalPadding);
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

  Widget _buildPostList(List<ForumPost> posts, bool isWide, double horizontalPadding) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 10),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final card = _buildPostCard(context, posts[index]);
        if (isWide) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: card,
            ),
          );
        }
        return card;
      },
    );
  }

  Widget _buildPostCard(BuildContext context, ForumPost post) {
    final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(post.createdAt);
    final authorName = post.author?.fullName ?? 'Usuario';
    final semester = post.author?.semesterDegree ?? 'N/A';
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: InkWell(
        onTap: () => context.go('/forum/${post.id}'),
        borderRadius: BorderRadius.circular(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          // Left-side accent border using a Stack
          child: Stack(
            children: [
              LawCard(
                padding: const EdgeInsets.fromLTRB(22, 18, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Author avatar with gradient background — 40x40
                        Container(
                          width: 40,
                          height: 40,
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
                                fontSize: 16,
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
                                    fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$semester · $formattedDate',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (post.isClosed)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'CERRADO',
                              style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3),
                            ),
                          )
                        else if (post.isUrgent)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'URGENTE',
                              style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (post.tags.isNotEmpty) ...[
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: post.tags
                            .map((tag) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: colorScheme.primary.withValues(alpha: 0.18)),
                                  ),
                                  child: Text(
                                    '#$tag',
                                    style: TextStyle(
                                        color: colorScheme.primary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Text(
                      post.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17, height: 1.3),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      post.content,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Visible divider above 'Discutir caso' row
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Divider(
                        height: 1,
                        thickness: 1,
                        color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    Row(
                      children: [
                        // Reply count badge — larger & more prominent
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: colorScheme.secondary.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.chat_bubble_outline, size: 18, color: colorScheme.secondary),
                              const SizedBox(width: 8),
                              Text(
                                '${post.replyCount} respuestas',
                                style: TextStyle(
                                    color: colorScheme.secondary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // 'Discutir caso' button — minimum 48px height, larger text+icon
                        Material(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                          elevation: 2,
                          shadowColor: colorScheme.primary.withValues(alpha: 0.3),
                          child: InkWell(
                            onTap: () => context.go('/forum/${post.id}'),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              constraints: const BoxConstraints(minHeight: 48),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.forum_outlined, size: 20, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'Discutir caso',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
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
