import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/database_provider.dart';
import '../../models/legal_update.dart';
import '../../widgets/common_widgets.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  void _showDetailBottomSheet(BuildContext context, LegalUpdate update) {
    final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(update.createdAt);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.all(24.0),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
            maxWidth: 600, // Ancho máximo centrado en escritorio
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Chip(
                    label: Text(
                      update.category.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onTertiaryContainer,
                      ),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
                  ),
                  const Spacer(),
                  Text(
                    formattedDate,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                update.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (update.author != null)
                Text(
                  'Publicado por: ${update.author!.fullName}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                ),
              const Divider(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    update.content,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updatesAsync = ref.watch(legalUpdatesProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Actualizaciones'),
            actions: [
              IconButton(
                onPressed: () => ref.invalidate(legalUpdatesProvider),
                icon: const Icon(Icons.refresh_rounded),
              ),
              const SizedBox(width: 8),
            ],
          ),
          updatesAsync.when(
            data: (updates) {
              if (updates.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.feed_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No hay actualizaciones publicadas aún.',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final update = updates[index];
                      final timeAgo = DateFormat('dd/MM/yyyy').format(update.createdAt);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: InkWell(
                          onTap: () => _showDetailBottomSheet(context, update),
                          borderRadius: BorderRadius.circular(20),
                          child: LawCard(
                            padding: EdgeInsets.zero,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 140,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primaryContainer,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                    image: update.imageUrl != null
                                        ? DecorationImage(
                                            image: NetworkImage(update.imageUrl!),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: update.imageUrl == null
                                      ? Icon(
                                          Icons.gavel_rounded,
                                          size: 48,
                                          color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.5),
                                        )
                                      : null,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Chip(
                                            label: Text(
                                              update.category.toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Theme.of(context).colorScheme.onTertiaryContainer,
                                              ),
                                            ),
                                            backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
                                            visualDensity: VisualDensity.compact,
                                          ),
                                          const Spacer(),
                                          Text(timeAgo, style: Theme.of(context).textTheme.bodySmall),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        update.title,
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        update.content,
                                        style: Theme.of(context).textTheme.bodyMedium,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          TextButton(
                                            onPressed: () => _showDetailBottomSheet(context, update),
                                            child: const Text('Leer más'),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: updates.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
            error: (err, stack) => SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'Error al cargar actualizaciones: ${err.toString()}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
