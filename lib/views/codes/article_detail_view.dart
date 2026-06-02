import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/database_provider.dart';

class ArticleDetailView extends ConsumerWidget {
  final String articleId;

  const ArticleDetailView({super.key, required this.articleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articleAsync = ref.watch(articleDetailProvider(articleId));
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              // Guardar artículo
            },
            icon: const Icon(Icons.bookmark_border_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: articleAsync.when(
        data: (article) {
          if (article == null) {
            return const Center(child: Text('Artículo no encontrado.'));
          }

          final reformDate = article.lastReformDate != null
              ? DateFormat('dd/MM/yyyy').format(article.lastReformDate!)
              : 'N/A';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Identificador (Badge)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${article.number} · ${article.code?.name ?? ''}'
                        .toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Título
                Text(
                  article.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 12),

                // Metadatos de reforma
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      'Última reforma: $reformDate',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
                if (article.sourceOfficial != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Fuente: ${article.sourceOfficial}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],

                const Divider(height: 40),

                // Alerta de reforma reciente
                if (article.hasRecentReform) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: Colors.orange, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'REFORMA RECIENTE',
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        if (article.summaryReform != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            article.summaryReform!,
                            style: const TextStyle(fontSize: 13, height: 1.4),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Texto del artículo
                Text(
                  'Texto Vigente',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                _buildFormattedContent(article.content),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildFormattedContent(String content) {
    final keywords = ['pena', 'sanción', 'prisión', 'multa', 'años', 'delito'];
    final words = content.split(' ');

    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 16,
          height: 1.6,
        ),
        children: words.map((word) {
          final cleanWord = word.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
          final isKeyword = keywords.contains(cleanWord);

          return TextSpan(
            text: '$word ',
            style: TextStyle(
              fontWeight: isKeyword ? FontWeight.bold : FontWeight.normal,
              color: isKeyword ? Colors.black : Colors.black87,
            ),
          );
        }).toList(),
      ),
    );
  }
}
