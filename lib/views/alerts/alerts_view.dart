import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/database_provider.dart';
import '../../models/legal_update.dart';
import '../../widgets/common_widgets.dart';

class AlertsView extends ConsumerWidget {
  const AlertsView({super.key});

  /// Responsive horizontal padding – wider on tablets/desktop
  double _responsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 900) return 48;
    if (width >= 600) return 32;
    return 16;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(legalUpdatesProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final hPad = _responsivePadding(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Alertas de Reforma',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () => context.push('/profile/settings'),
            icon: const Icon(Icons.settings_outlined),
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
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
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPad),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.notifications_off_outlined,
                          size: 48,
                          color: colorScheme.outline.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'No hay alertas recientes',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Las reformas y actualizaciones legales aparecerán aquí.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
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
              padding: EdgeInsets.all(hPad),
              itemCount: groupedAlerts.length,
              itemBuilder: (context, index) {
                final dateLabel = groupedAlerts.keys.elementAt(index);
                final dayAlerts = groupedAlerts[dateLabel]!;

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDateHeader(context, dateLabel),
                        const SizedBox(height: 16),
                        ...dayAlerts.map((alert) => _buildAlertCard(context, alert)),
                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Error: $err',
                style: const TextStyle(fontSize: 14, height: 1.5),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateHeader(BuildContext context, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        // Accent bar
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: colorScheme.secondary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Icon(
          Icons.calendar_today_rounded,
          size: 16,
          color: colorScheme.primary,
        ),
        const SizedBox(width: 6),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Divider(
            thickness: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }

  Widget _buildAlertCard(BuildContext context, LegalUpdate alert) {
    final colorScheme = Theme.of(context).colorScheme;
    final isNew = DateTime.now().difference(alert.createdAt).inHours < 24;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: LawCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title row with NEW badge ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    alert.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                ),
                if (isNew)
                  Container(
                    margin: const EdgeInsets.only(left: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.error,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'NUEVO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 10),

            // ── Content body ──
            Text(
              alert.content,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                fontSize: 14,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 14),

            // ── Divider ──
            Divider(
              height: 1,
              thickness: 0.5,
              color: colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),

            const SizedBox(height: 14),

            // ── Category + time + action button ──
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    alert.category.toUpperCase(),
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  Icons.access_time_rounded,
                  size: 14,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat('HH:mm').format(alert.createdAt),
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () {
                    context.push('/alerts/detail/${alert.id}');
                  },
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text(
                    'Ver cambios',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    side: BorderSide(color: colorScheme.primary, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    minimumSize: const Size(0, 48),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
