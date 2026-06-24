import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/database_provider.dart';
import 'reform_detail_view.dart';
import 'news_detail_view.dart';
import 'event_detail_view.dart';

class ContentDetailWrapper extends ConsumerWidget {
  final String updateId;

  const ContentDetailWrapper({super.key, required this.updateId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(publicationsProvider);
    final draftsAsync = ref.watch(myDraftsProvider);
    final scheduledAsync = ref.watch(scheduledUpdatesProvider);

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
        body: const Center(child: Text('Publicación no encontrada.')),
      );
    }

    try {
      final update = allUpdates.firstWhere((a) => a.id == updateId);
      
      if (update.contentType == 'reforma') {
        return ReformDetailView(alertId: updateId);
      } else if (update.contentType == 'evento' || update.contentType == 'convocatoria') {
        return EventDetailView(updateId: updateId);
      } else {
        return NewsDetailView(updateId: updateId);
      }
    } catch (e, st) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle')),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Error en wrapper.\nError: $e\nStack: $st'),
          ),
        ),
      );
    }
  }
}
