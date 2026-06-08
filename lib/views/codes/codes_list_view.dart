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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Códigos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Column(
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

              // Divider separating search from results
              Divider(
                height: 1,
                color: colorScheme.outline.withValues(alpha: 0.15),
              ),

              Expanded(
                child: codesAsync.when(
                  data: (codes) {
                    final filteredCodes = codes
                        .where((c) => c.name.toLowerCase().contains(_searchQuery))
                        .toList();

                    if (filteredCodes.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 64,
                              color: colorScheme.outline.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No se encontraron códigos.',
                              style: TextStyle(
                                fontSize: 16,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Intenta con otro término de búsqueda',
                              style: TextStyle(
                                fontSize: 13,
                                color: colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        // 2 columns on tablets (width >= 500)
                        if (constraints.maxWidth >= 500) {
                          return GridView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 2.2,
                            ),
                            itemCount: filteredCodes.length,
                            itemBuilder: (context, index) {
                              final code = filteredCodes[index];
                              return _buildCodeTile(context, code);
                            },
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                          itemCount: filteredCodes.length,
                          itemBuilder: (context, index) {
                            final code = filteredCodes[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: _buildCodeTile(context, code),
                            );
                          },
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
        ),
      ),
    );
  }

  Widget _buildCodeTile(BuildContext context, LegalCode code) {
    final colorScheme = Theme.of(context).colorScheme;

    final statusColor = code.status == 'Vigente' ? Colors.green : Colors.blue;

    return InkWell(
      onTap: () => context.push('/codes/${code.id}?name=${Uri.encodeComponent(code.name)}'),
      borderRadius: BorderRadius.circular(20),
      child: LawCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Gavel icon: 26px icon inside 48px circle
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.gavel_rounded,
                size: 26,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    code.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${code.articleCount ?? 0} artículos disponibles',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  // Status badge - more prominent with border
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      code.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // "Ver artículos" button instead of chevron
            SizedBox(
              height: 40,
              child: OutlinedButton.icon(
                onPressed: () => context.push('/codes/${code.id}?name=${Uri.encodeComponent(code.name)}'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                  side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.4)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                icon: Icon(Icons.chevron_right, size: 18, color: colorScheme.primary),
                label: const Text('Ver'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
