import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/database_provider.dart';
import '../../models/mentorship_session.dart';

class MentorshipDetailView extends ConsumerWidget {
  final String sessionId;

  const MentorshipDetailView({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(mentorshipSessionsProvider);
    final colorScheme = Theme.of(context).colorScheme;

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
                const SizedBox(height: 32),
                
                // Calendario / Horarios
                const Text(
                  'Próximas Fechas',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                _buildScheduleTile(Icons.calendar_today, 'Lunes, 15 de Junio', '18:00 - 19:30'),
                _buildScheduleTile(Icons.calendar_today, 'Miércoles, 17 de Junio', '18:00 - 19:30'),
                
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
                
                // Botón Acción
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: session.availableSlots > 0 ? () {} : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      session.availableSlots > 0 ? 'Inscribirme ahora' : 'Lista de espera',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
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

  Widget _buildScheduleTile(IconData icon, String day, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 16),
          Expanded(child: Text(day, style: const TextStyle(fontWeight: FontWeight.w600))),
          Text(time, style: const TextStyle(color: Colors.grey)),
        ],
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
