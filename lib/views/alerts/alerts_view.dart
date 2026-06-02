import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/database_provider.dart';
import '../../models/legal_update.dart';
import '../../widgets/common_widgets.dart';

class AlertsView extends ConsumerWidget {
  const AlertsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(legalUpdatesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertas de Reforma'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: alertsAsync.when(
        data: (alerts) {
          if (alerts.isEmpty) {
            return const Center(child: Text('No hay alertas recientes.'));
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
                  _buildDateHeader(dateLabel),
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
    );
  }

  Widget _buildDateHeader(String label) {
    return Row(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildAlertCard(BuildContext context, LegalUpdate alert) {
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
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (isNew)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
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
              style: const TextStyle(color: Colors.grey, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('HH:mm').format(alert.createdAt),
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
                TextButton(
                  onPressed: () {
                    // Navegar a comparativo
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
