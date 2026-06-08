import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/database_provider.dart';
import '../../models/legal_update.dart';
import '../../widgets/common_widgets.dart';

class AlertsView extends ConsumerWidget {
  const AlertsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(legalUpdatesProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertas de Reforma'),
        actions: [
          IconButton(
            onPressed: () => context.push('/profile/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(legalUpdatesProvider),
        child: alertsAsync.when(
          data: (alerts) {
            if (alerts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_off_outlined, size: 64, color: colorScheme.outline),
                    const SizedBox(height: 16),
                    Text(
                      'No hay alertas recientes.',
                      style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            }

            // Agrupar por fecha
            final Map<String, List<LegalUpdate>> groupedAlerts = {};
            for (var alert in alerts) {
              final dateStr = DateFormat('dd/MM/yyyy').format(alert.createdAt);
              final today = DateFormat('dd/MM/yyyy').format(DateTime.now());
              final label = (dateStr == today) ? 'Hoy' : dateStr;

              if (!groupedAlerts.containsKey(label)) {
                groupedAlerts[label] = [];
              }
              groupedAlerts[label]!.add(alert);
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: groupedAlerts.length,
              itemBuilder: (context, index) {
                final dateLabel = groupedAlerts.keys.elementAt(index);
                final dayAlerts = groupedAlerts[dateLabel]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDateHeader(context, dateLabel),
                    const SizedBox(height: 12),
                    ...dayAlerts.map((alert) => _buildAlertCard(context, alert)),
                    const SizedBox(height: 24),
                  ],
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  Widget _buildDateHeader(BuildContext context, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildAlertCard(BuildContext context, LegalUpdate alert) {
    final colorScheme = Theme.of(context).colorScheme;
    final isNew = DateTime.now().difference(alert.createdAt).inHours < 24;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: LawCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    alert.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                if (isNew)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorScheme.error,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              alert.content,
              style: TextStyle(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8), fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    alert.category.toUpperCase(),
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('HH:mm').format(alert.createdAt),
                  style: TextStyle(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6), fontSize: 11),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    context.push('/alerts/detail/${alert.id}');
                  },
                  child: const Text('Ver cambios'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
