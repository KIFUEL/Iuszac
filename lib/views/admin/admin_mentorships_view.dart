import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/database_provider.dart';
import '../../models/mentorship_session.dart';
import '../../widgets/common_widgets.dart';

class AdminMentorshipsView extends ConsumerWidget {
  const AdminMentorshipsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mentorshipsAsync = ref.watch(adminMentorshipSessionsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Mentorías', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(adminMentorshipSessionsProvider);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: mentorshipsAsync.when(
        data: (sessions) {
          if (sessions.isEmpty) {
            return const Center(
              child: Text('No hay mentorías publicadas.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              return _buildMentorshipCard(context, ref, session, colorScheme);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildMentorshipCard(BuildContext context, WidgetRef ref, MentorshipSession session, ColorScheme colorScheme) {
    final mentorName = session.mentor?.fullName ?? 'Desconocido';
    final isExpired = session.expiresAt != null ? session.expiresAt!.isBefore(DateTime.now()) : false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: LawCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header row: avatar, title, mentor name, badges ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: colorScheme.primaryContainer,
                  backgroundImage: session.mentor?.avatarUrl != null && session.mentor!.avatarUrl!.isNotEmpty 
                      ? NetworkImage(session.mentor!.avatarUrl!) 
                      : null,
                  child: session.mentor?.avatarUrl == null || session.mentor!.avatarUrl!.isEmpty
                      ? Text(
                          mentorName.isNotEmpty ? mentorName[0] : 'U',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              session.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                          if (isExpired)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.red.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: const Text(
                                'VENCIDA',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          if (!session.isActive)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.orange.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'PAUSADA',
                                style: TextStyle(
                                  color: Colors.orange.shade800,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$mentorName · ${session.specialty}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (session.isCommunityVerified)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(Icons.verified, color: Colors.blue, size: 24),
                  ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) async {
                    final dbService = ref.read(databaseServiceProvider);
                    try {
                      if (value == 'edit') {
                        context.push('/mentorship/edit/${session.id}');
                      } else if (value == 'toggle') {
                        await dbService.toggleMentorshipActive(session.id, !session.isActive);
                        ref.invalidate(adminMentorshipSessionsProvider);
                        ref.invalidate(mentorshipSessionsProvider);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(session.isActive ? 'Mentoría pausada' : 'Mentoría activada')),
                          );
                        }
                      } else if (value == 'delete') {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Eliminar mentoría'),
                            content: const Text('¿Estás seguro de que deseas eliminar esta mentoría? Esta acción no se puede deshacer.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
                              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar')),
                            ],
                          ),
                        );
                        
                        if (confirm == true) {
                          await dbService.deleteMentorshipSession(session.id);
                          ref.invalidate(adminMentorshipSessionsProvider);
                          ref.invalidate(mentorshipSessionsProvider);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Mentoría eliminada')),
                            );
                          }
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'toggle',
                      child: Row(
                        children: [
                          Icon(session.isActive ? Icons.pause : Icons.play_arrow, size: 20),
                          const SizedBox(width: 8),
                          Text(session.isActive ? 'Pausar' : 'Activar'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text('Eliminar', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- Rating row ---
            Row(
              children: [
                Icon(Icons.star_rounded, color: Colors.amber.shade700, size: 22),
                const SizedBox(width: 4),
                Text(
                  session.rating.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '(${session.reviewCount} reseñas)',
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // --- Schedule row ---
            Row(
              children: [
                Icon(Icons.access_time_outlined, size: 16, color: colorScheme.onSurface.withValues(alpha: 0.6)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    session.scheduleDisplay.isNotEmpty ? session.scheduleDisplay : 'Sin horario',
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            Divider(
              height: 28,
              color: Colors.grey.withValues(alpha: 0.2),
            ),

            // --- Price, slots, actions row ---
            Row(
              children: [
                // Price badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: session.price == 0
                        ? Colors.green.withValues(alpha: 0.12)
                        : colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: session.price == 0
                          ? Colors.green.withValues(alpha: 0.3)
                          : colorScheme.primary.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    session.price == 0 ? 'GRATIS' : '\$${session.price}',
                    style: TextStyle(
                      color: session.price == 0
                          ? Colors.green.shade700
                          : colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Available slots badge
                if (session.availableSlots > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.people_alt_outlined, size: 14, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text(
                          '${session.availableSlots} cupos',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                const Spacer(),
                // Ver más button
                SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/mentorship/${session.id}'),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: const Text(
                      'Ver más',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
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
