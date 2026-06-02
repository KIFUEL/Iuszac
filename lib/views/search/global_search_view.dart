import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

  final List<String> _recentSearches = [
    'Art. 14',
    'Código Penal Zacatecas',
    'Reforma Laboral',
    'Ley de Amparo'
  ];

  final List<Map<String, String>> _popularArticles = [
    {'title': 'Art. 14', 'subtitle': 'Constitución Política'},
    {'title': 'Art. 250', 'subtitle': 'Código Penal Zacatecas'},
    {'title': 'Art. 61', 'subtitle': 'Ley de Amparo'},
  ];

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
        automaticallyImplyLeading: false,
        title: LawTextField(
          label: 'Buscar...',
          icon: Icons.search,
          controller: _searchController,
          focusNode: _focusNode,
          onChanged: (val) => setState(() => _searchQuery = val.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => context.go('/'),
            child: const Text('Cancelar'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _searchQuery.isEmpty ? _buildSuggestions() : _buildResults(),
    );
  }

  Widget _buildSuggestions() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        if (_recentSearches.isNotEmpty) ...[
          const Text(
            'Búsquedas Recientes',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: _recentSearches.map((s) => _buildChip(s)).toList(),
          ),
          const SizedBox(height: 32),
        ],
        const Text(
          'Artículos Populares',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        ..._popularArticles.map((a) => ListTile(
              leading: const Icon(Icons.trending_up, color: Colors.blue),
              title: Text(a['title']!),
              subtitle: Text(a['subtitle']!),
              onTap: () {},
            )),
      ],
    );
  }

  Widget _buildChip(String label) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onDeleted: () {
        setState(() => _recentSearches.remove(label));
      },
    );
  }

  Widget _buildResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.description_outlined)),
          title: Text('Art. ${index + 100} - Ejemplo de resultado'),
          subtitle: const Text('Código Civil del Estado de Zacatecas'),
          trailing: index == 1
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'REFORMA',
                    style: TextStyle(
                        color: Colors.orange,
                        fontSize: 9,
                        fontWeight: FontWeight.bold),
                  ),
                )
              : const Icon(Icons.chevron_right),
          onTap: () {},
        );
      },
    );
  }
}
