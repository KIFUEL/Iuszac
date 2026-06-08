import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/database_provider.dart';
import '../../models/mentorship_session.dart';

class MentorshipDetailView extends ConsumerWidget {
  final String sessionId;

  const MentorshipDetailView({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(mentorshipSessionsProvider);
    final enrolledAsync = ref.watch(enrolledSessionsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final enrolledSessions = enrolledAsync.value ?? [];
    final isEnrolled = enrolledSessions.any((s) => s.id == sessionId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Mentoría'),
      ),
      body: sessionsAsync.when(
        data: (sessions) {
          MentorshipSession? session;
          try {
            session = sessions.firstWhere((s) => s.id == sessionId);
          } catch (_) {
            session = null;
          }

          if (session == null) {
            return const Center(child: Text('Sesión no encontrada.'));
          }

          final mentorName = session.mentor?.fullName ?? 'Mentor';
          final phone = session.mentor?.phoneWhatsapp;
          final hasPhone = phone != null && phone.trim().isNotEmpty;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: colorScheme.primaryContainer,
                      child: Text(mentorName[0], style: const TextStyle(fontSize: 24)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.title,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '$mentorName · ${session.mentor?.institution ?? 'UAZ Derecho'}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Rating
                Row(
                  children: [
                    ...List.generate(5, (index) => Icon(
                      index < session!.rating.floor() ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 20,
                    )),
                    const SizedBox(width: 8),
                    Text(
                      '${session.rating} (${session.reviewCount} reseñas)',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Divider(height: 48),
                
                // Descripción
                const Text(
                  'Descripción de la sesión',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Text(
                  session.description ?? 'Sin descripción disponible.',
                  style: const TextStyle(height: 1.5, color: Colors.black87),
                ),
                if (session.expiresAt != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, color: Colors.orange, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Válido hasta el ${DateFormat('dd/MM/yyyy').format(session.expiresAt!)}',
                        style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 32),
                
                // Detalles de Costo y Cupo
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Costo por sesión', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text(
                          session.price == 0 ? 'Gratis' : '\$${session.price} MXN',
                          style: TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold,
                            color: session.price == 0 ? Colors.green : colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Cupos restantes', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text(
                          '${session.availableSlots} lugares',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                // Botón Acción Inscripción
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isEnrolled 
                        ? null 
                        : (session.availableSlots > 0 
                            ? () async {
                                try {
                                  await ref.read(databaseServiceProvider).enrollInSession(session!.id);
                                  ref.invalidate(enrolledSessionsProvider);
                                  ref.invalidate(mentorshipSessionsProvider);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('¡Te has inscrito exitosamente! 🎉'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error al inscribirse: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              }
                            : null),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      isEnrolled 
                          ? 'Ya estás inscrito' 
                          : (session.availableSlots > 0 ? 'Inscribirme ahora' : 'Sin cupos disponibles'),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),

                // Botón Acción WhatsApp
                if (hasPhone) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.chat, color: Colors.green),
                      label: const Text(
                        'Contactar por WhatsApp',
                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.green, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        final text = Uri.encodeComponent('Hola, me interesa tu mentoría: ${session!.title}');
                        final url = Uri.parse('https://wa.me/$phone?text=$text');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('No se pudo abrir WhatsApp')),
                            );
                          }
                        }
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 40),
                
                // Reseñas (Sección simple)
                const Text(
                  'Reseñas de participantes',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 16),
                if (session.reviewCount == 0)
                  const Text('Aún no hay reseñas para esta sesión.', style: TextStyle(color: Colors.grey, fontSize: 13))
                else
                  _buildReviewTile('Juan Pérez', 'Excelente mentor, me ayudó mucho con mis dudas de derecho procesal.', 5),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildReviewTile(String name, String comment, int rating) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const Spacer(),
            ...List.generate(5, (index) => Icon(
              Icons.star,
              color: index < rating ? Colors.amber : Colors.grey.shade300,
              size: 14,
            )),
          ],
        ),
        const SizedBox(height: 4),
        Text(comment, style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4)),
        const Divider(height: 32),
      ],
    );
  }
}
