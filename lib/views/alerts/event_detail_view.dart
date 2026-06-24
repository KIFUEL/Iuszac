import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/database_provider.dart';
import 'reform_detail_view.dart'; // Para reutilizar QuillContentViewer

class EventDetailView extends ConsumerWidget {
  final String updateId;

  const EventDetailView({super.key, required this.updateId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(publicationsProvider);
    final draftsAsync = ref.watch(myDraftsProvider);
    final scheduledAsync = ref.watch(scheduledUpdatesProvider);
    final colorScheme = Theme.of(context).colorScheme;

    if (alertsAsync.isLoading || draftsAsync.isLoading || scheduledAsync.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cargando...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final allUpdates = [
      ...alertsAsync.value ?? [],
      ...draftsAsync.value ?? [],
      ...scheduledAsync.value ?? [],
    ];

    if (allUpdates.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle')),
        body: const Center(child: Text('No hay información disponible.')),
      );
    }

    try {
      final update = allUpdates.firstWhere((a) => a.id == updateId);

      return Scaffold(
        appBar: AppBar(
          title: Text(update.contentType == 'evento' ? 'Evento' : 'Convocatoria'),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        update.category.toUpperCase(),
                        style: TextStyle(
                          color: colorScheme.onPrimaryContainer,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Title
                    Text(
                      update.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    
                    if (update.imageUrl != null && update.imageUrl!.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => Scaffold(
                                backgroundColor: Colors.black,
                                appBar: AppBar(
                                  backgroundColor: Colors.black,
                                  iconTheme: const IconThemeData(color: Colors.white),
                                ),
                                body: Center(
                                  child: InteractiveViewer(
                                    panEnabled: true,
                                    minScale: 0.5,
                                    maxScale: 4.0,
                                    child: Image.network(
                                      update.imageUrl!,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            update.imageUrl!,
                            width: double.infinity,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: double.infinity,
                              height: 250,
                              color: colorScheme.surfaceContainerHighest,
                              child: const Icon(Icons.event, size: 50, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ],

                    if (update.tags.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: update.tags.map<Widget>((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorScheme.secondaryContainer.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '#$tag',
                              style: TextStyle(
                                fontSize: 11,
                                color: colorScheme.onSecondaryContainer,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Info Cards
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
                      ),
                      child: Column(
                        children: [
                          if (update.eventStart != null)
                            _buildInfoRow(context, Icons.calendar_today, 'Inicio', DateFormat('dd/MM/yyyy HH:mm').format(update.eventStart!)),
                          if (update.eventEnd != null)
                            _buildInfoRow(context, Icons.event_busy, 'Fin', DateFormat('dd/MM/yyyy HH:mm').format(update.eventEnd!)),
                          if (update.deadline != null)
                            _buildInfoRow(context, Icons.timer, 'Fecha Límite', DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(update.deadline!))),
                          if (update.eventLocation != null && update.eventLocation!.isNotEmpty)
                            _buildInfoRow(context, Icons.location_on, 'Ubicación', update.eventLocation!),
                          if (update.eventCost != null && update.eventCost!.isNotEmpty)
                            _buildInfoRow(context, Icons.attach_money, 'Costo', update.eventCost!),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),

                    // Content
                    QuillContentViewer(content: update.content),

                    if (update.eventLink != null && update.eventLink!.isNotEmpty) ...[
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // En una app real usar url_launcher
                          },
                          icon: const Icon(Icons.link),
                          label: const Text('Ir al enlace de registro'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e, st) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle')),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Evento no encontrado.\nError: $e\nStack: $st'),
          ),
        ),
      );
    }
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
