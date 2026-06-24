import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/database_provider.dart';

class ReformDetailView extends ConsumerWidget {
  final String alertId;

  const ReformDetailView({super.key, required this.alertId});

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
      final alert = allUpdates.firstWhere((a) => a.id == alertId);
      final publishDate = DateFormat('dd/MM/yyyy').format(alert.createdAt);

          final hasComparison = (alert.oldContent != null && alert.oldContent!.trim().isNotEmpty) ||
              (alert.newContent != null && alert.newContent!.trim().isNotEmpty);
          return Scaffold(
            appBar: AppBar(
              title: const Text('Detalle de Publicación'),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Chip Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    alert.category.toUpperCase(),
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  alert.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 24),

                if (alert.imageUrl != null && alert.imageUrl!.trim().isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      alert.imageUrl!,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                if (hasComparison) ...[
                  // Texto Anterior
                  if (alert.oldContent != null && alert.oldContent!.trim().isNotEmpty) ...[
                    const Text(
                      'TEXTO ANTERIOR',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.15)),
                      ),
                      child: Text(
                        alert.oldContent!,
                        style: const TextStyle(
                          color: Colors.red,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Texto Nuevo
                  if (alert.newContent != null && alert.newContent!.trim().isNotEmpty) ...[
                    const Text(
                      'TEXTO NUEVO / VIGENTE',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.withValues(alpha: 0.15)),
                      ),
                      child: Text(
                        alert.newContent!,
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ] else ...[
                  // General content display
                  const Text(
                    'DETALLES DE LA PUBLICACIÓN',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                    ),
                    child: QuillContentViewer(content: alert.content),
                  ),
                ],

                const Divider(height: 48),

                // Metadatos
                _buildMetadataRow(Icons.account_balance, 'Fuente Oficial',
                    'Periódico Oficial del Estado / Diario Oficial'),
                const SizedBox(height: 12),
                _buildMetadataRow(
                    Icons.event, 'Fecha de Publicación', publishDate),

                if (alert.sourceUrl != null && alert.sourceUrl!.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          final uri = Uri.parse(alert.sourceUrl!);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        } catch (_) {}
                      },
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Ver Documento Original'),
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
        );
    } catch (e) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle')),
        body: const Center(child: Text('Publicación no encontrada.')),
      );
    }
  }

  Widget _buildMetadataRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}

class QuillContentViewer extends StatefulWidget {
  final String content;

  const QuillContentViewer({super.key, required this.content});

  @override
  State<QuillContentViewer> createState() => _QuillContentViewerState();
}

class _QuillContentViewerState extends State<QuillContentViewer> {
  late quill.QuillController _controller;
  bool _isJson = false;

  @override
  void initState() {
    super.initState();
    try {
      final decoded = jsonDecode(widget.content);
      if (decoded is List) {
        _controller = quill.QuillController(
          document: quill.Document.fromJson(decoded),
          selection: const TextSelection.collapsed(offset: 0),
        );
        _controller.readOnly = true;
        _isJson = true;
      } else {
        _controller = quill.QuillController.basic();
      }
    } catch (_) {
      _controller = quill.QuillController.basic();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isJson) {
      return Text(
        widget.content,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 14,
          height: 1.6,
        ),
      );
    }

    return quill.QuillEditor.basic(
      controller: _controller,
      config: const quill.QuillEditorConfig(
        showCursor: false,
      ),
    );
  }
}
