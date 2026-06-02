import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/database_provider.dart';
import '../../models/legal_code.dart';
import '../../widgets/common_widgets.dart';

class CodesListView extends ConsumerStatefulWidget {
  const CodesListView({super.key});

  @override
  ConsumerState<CodesListView> createState() => _CodesListViewState();
}

class _CodesListViewState extends ConsumerState<CodesListView> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final codesAsync = ref.watch(legalCodesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Códigos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Column(
        children: [
          // Buscador Inline
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: LawTextField(
              label: 'Buscar código...',
              icon: Icons.search,
              controller: _searchController,
              onChanged: (val) {
                setState(() => _searchQuery = val.toLowerCase());
              },
            ),
          ),

          Expanded(
            child: codesAsync.when(
              data: (codes) {
                final filteredCodes = codes
                    .where((c) => c.name.toLowerCase().contains(_searchQuery))
                    .toList();

                if (filteredCodes.isEmpty) {
                  return const Center(child: Text('No se encontraron códigos.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredCodes.length,
                  itemBuilder: (context, index) {
                    final code = filteredCodes[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _buildCodeTile(context, code),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeTile(BuildContext context, LegalCode code) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () {
        // Navegar a detalle (cuando esté implementado)
      },
      borderRadius: BorderRadius.circular(20),
      child: LawCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.gavel_rounded,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    code.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${code.articleCount ?? 0} artículos disponibles',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: code.status == 'Vigente'
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    code.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: code.status == 'Vigente' ? Colors.green : Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
