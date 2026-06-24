import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/database_provider.dart';
import '../../widgets/common_widgets.dart';

class GlobalSearchView extends ConsumerStatefulWidget {
  const GlobalSearchView({super.key});

  @override
  ConsumerState<GlobalSearchView> createState() => _GlobalSearchViewState();
}

class _GlobalSearchViewState extends ConsumerState<GlobalSearchView> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        title: Hero(
          tag: 'search_bar',
          child: Material(
            type: MaterialType.transparency,
            child: LawTextField(
              label: 'Buscar artículos, foros, eventos...',
              icon: Icons.search,
              controller: _searchController,
              focusNode: _focusNode,
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancelar', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _searchQuery.isEmpty ? _buildSuggestions(context) : _buildResults(context),
    );
  }

  Widget _buildSuggestions(BuildContext context) {
    final tagsAsync = ref.watch(popularTagsProvider);
    final publicationsAsync = ref.watch(publicationsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        tagsAsync.when(
          data: (tags) {
            if (tags.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Búsquedas Populares',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: tags.take(8).map((tag) => _buildChip(tag, colorScheme)).toList(),
                ),
                const SizedBox(height: 32),
              ],
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        const Text(
          'Publicaciones Recientes',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        publicationsAsync.when(
          data: (pubs) {
            if (pubs.isEmpty) return const Text('No hay sugerencias.');
            return Column(
              children: pubs.take(4).map((pub) {
                IconData icon;
                Color iconColor;
                switch (pub.contentType) {
                  case 'noticia':
                    icon = Icons.newspaper;
                    iconColor = Colors.orange;
                    break;
                  case 'evento':
                  case 'convocatoria':
                    icon = Icons.event;
                    iconColor = Colors.green;
                    break;
                  case 'reforma':
                    icon = Icons.gavel;
                    iconColor = Colors.blue;
                    break;
                  default:
                    icon = Icons.article;
                    iconColor = colorScheme.primary;
                }

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  title: Text(pub.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(pub.category, style: TextStyle(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7), fontSize: 13)),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () {
                    context.push('/alerts/detail/${pub.id}');
                  },
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildChip(String label, ColorScheme colorScheme) {
    return ActionChip(
      label: Text(label),
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: colorScheme.primary,
      ),
      backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.3),
      side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.2)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: () {
        _searchController.text = label;
        setState(() => _searchQuery = label);
      },
    );
  }

  Widget _buildResults(BuildContext context) {
    // Aquí podrías filtrar las publicaciones, foros o artículos en base a _searchQuery
    // Por ahora dejaremos un placeholder estético
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: colorScheme.outline.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            'Buscando: "$_searchQuery"',
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'La búsqueda global completa se conectará pronto.',
            style: TextStyle(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7), fontSize: 14),
          ),
        ],
      ),
    );
  }
}
