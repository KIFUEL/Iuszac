import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/database_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/mentorship_session.dart';
import '../../models/mentorship_review.dart';
import '../../widgets/common_widgets.dart';

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
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 64,
                      color: Colors.grey.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Sesión no encontrada',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Es posible que la sesión haya sido eliminada o no esté disponible.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final mentorName = session.mentor?.fullName ?? 'Mentor';
          final phone = session.mentor?.phoneWhatsapp;
          final hasPhone = phone != null && phone.trim().isNotEmpty;

          return LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding = constraints.maxWidth > 700
                  ? (constraints.maxWidth - 700) / 2 + 24
                  : 20.0;

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ======= SECTION: Header =======
                    LawCard(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 34,
                            backgroundColor: colorScheme.primaryContainer,
                            child: Text(
                              mentorName[0],
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  session!.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    if (session.isCommunityVerified) ...[
                                      const Icon(Icons.verified, color: Colors.blue, size: 18),
                                      const SizedBox(width: 4),
                                    ],
                                    Expanded(
                                      child: Text(
                                        '$mentorName · ${session.mentor?.institution ?? 'UAZ Derecho'}',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 14,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ======= SECTION: Rating =======
                    LawCard(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Row(
                        children: [
                          ...List.generate(5, (index) => Padding(
                            padding: const EdgeInsets.only(right: 2),
                            child: Icon(
                              index < session!.rating.floor() ? Icons.star_rounded : Icons.star_border_rounded,
                              color: Colors.amber.shade700,
                              size: 22,
                            ),
                          )),
                          const SizedBox(width: 10),
                          Text(
                            '${session.rating}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '(${session.reviewCount} reseñas)',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ======= SECTION: Description =======
                    LawCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader('Descripción de la sesión', colorScheme),
                          const SizedBox(height: 14),
                          Text(
                            session.description ?? 'Sin descripción disponible.',
                            style: TextStyle(
                              height: 1.6,
                              fontSize: 15,
                              color: colorScheme.onSurface.withValues(alpha: 0.87),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: colorScheme.primary.withValues(alpha: 0.15),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.calendar_month_outlined, color: colorScheme.primary, size: 22),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Horarios Programados',
                                      style: TextStyle(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                _buildScheduleList(session.schedule, colorScheme),
                              ],
                            ),
                          ),
                          if (session.expiresAt != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.orange.withValues(alpha: 0.25),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.timer_outlined, color: Colors.orange, size: 20),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Válido hasta el ${DateFormat('dd/MM/yyyy').format(session.expiresAt!)}',
                                    style: const TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ======= SECTION: Cost & Slots =======
                    LawCard(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Costo por sesión',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: session.price == 0
                                        ? Colors.green.withValues(alpha: 0.1)
                                        : colorScheme.primary.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    session.price == 0 ? 'Gratis' : '\$${session.price} MXN',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: session.price == 0 ? Colors.green.shade700 : colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 56,
                            color: Colors.grey.withValues(alpha: 0.2),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Cupos restantes',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.people_alt_outlined, size: 18, color: Colors.orange),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${session.availableSlots} lugares',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ======= SECTION: Action Buttons =======
                    // Inscribirme button
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton.icon(
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
                        icon: Icon(
                          isEnrolled
                              ? Icons.check_circle_rounded
                              : (session.availableSlots > 0 ? Icons.how_to_reg_rounded : Icons.block_rounded),
                          size: 24,
                        ),
                        label: Text(
                          isEnrolled
                              ? 'Ya estás inscrito'
                              : (session.availableSlots > 0 ? 'Inscribirme ahora' : 'Sin cupos disponibles'),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            letterSpacing: 0.3,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: isEnrolled
                              ? Colors.green.withValues(alpha: 0.15)
                              : Colors.grey.withValues(alpha: 0.12),
                          disabledForegroundColor: isEnrolled
                              ? Colors.green.shade700
                              : Colors.grey.shade600,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                      ),
                    ),

                    // WhatsApp button
                    if (hasPhone) ...[
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.chat_rounded, color: Colors.green, size: 24),
                          label: const Text(
                            'Contactar por WhatsApp',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.green, width: 2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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

                    const SizedBox(height: 32),

                    // ======= SECTION: Reviews =======
                    ref.watch(mentorshipReviewsProvider(session.id)).when(
                      data: (List<MentorshipReview> reviews) {
                        final currentUserId = ref.watch(userProfileProvider).value?.id;
                        final hasReviewed = reviews.any((r) => r.userId == currentUserId);
                        final showForm = isEnrolled && !hasReviewed;

                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.15),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader('Reseñas de participantes', colorScheme),
                              if (showForm) ...[
                                const SizedBox(height: 16),
                                _ReviewForm(sessionId: session!.id),
                              ],
                              const SizedBox(height: 16),
                              if (reviews.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.rate_review_outlined,
                                        size: 32,
                                        color: Colors.grey.withValues(alpha: 0.4),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Aún no hay reseñas para esta sesión. ¡Sé el primero en dejar una!',
                                          style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 14,
                                            height: 1.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: reviews.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final review = reviews[index];
                                    final reviewerName = review.user?.fullName ?? 'Usuario';
                                    return _buildReviewTile(
                                      context,
                                      reviewerName,
                                      review.comment ?? '',
                                      review.rating,
                                    );
                                  },
                                ),
                            ],
                          ),
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Center(child: Text('Error al cargar reseñas: $err')),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildScheduleList(dynamic schedule, ColorScheme colorScheme) {
    if (schedule == null) {
      return Text('Sin horario especificado', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13));
    }
    
    final Map<String, List<String>> grouped = {};
    if (schedule is List) {
      for (var item in schedule) {
        if (item is Map) {
          final day = item['day'] as String?;
          final start = item['startTime'] as String?;
          final end = item['endTime'] as String?;
          if (day != null && start != null && end != null) {
            grouped.putIfAbsent(day, () => []).add('$start - $end');
          }
        }
      }
    } else if (schedule is Map) {
      final days = schedule['days'] as List<dynamic>?;
      final start = schedule['startTime'] as String?;
      final end = schedule['endTime'] as String?;
      if (days != null && start != null && end != null) {
        for (var d in days) {
          grouped.putIfAbsent(d.toString(), () => []).add('$start - $end');
        }
      }
    }
    
    if (grouped.isEmpty) {
      return Text('Sin horario especificado', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13));
    }

    final daysOrder = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: daysOrder.where((d) => grouped.containsKey(d)).map((day) {
        final times = grouped[day]!;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 110,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
                ),
                child: Text(
                  day,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: times.map((t) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                    child: Row(
                      children: [
                        Icon(Icons.access_time, size: 16, color: colorScheme.onSurface.withValues(alpha: 0.6)),
                        const SizedBox(width: 8),
                        Text(
                          t,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionHeader(String title, ColorScheme colorScheme) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(
            color: colorScheme.secondary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewTile(BuildContext context, String name, String comment, int rating) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey.withValues(alpha: 0.15),
                child: Text(
                  name[0],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              ...List.generate(5, (index) => Icon(
                Icons.star_rounded,
                color: index < rating ? Colors.amber.shade700 : Colors.grey.shade300,
                size: 18,
              )),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            comment,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withValues(alpha: 0.87),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewForm extends ConsumerStatefulWidget {
  final String sessionId;

  const _ReviewForm({required this.sessionId});

  @override
  ConsumerState<_ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends ConsumerState<_ReviewForm> {
  final _commentController = TextEditingController();
  int _rating = 5;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor escribe un comentario para tu reseña.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final messenger = ScaffoldMessenger.of(context);
    try {
      final dbService = ref.read(databaseServiceProvider);
      await dbService.createMentorshipReview(
        sessionId: widget.sessionId,
        rating: _rating,
        comment: comment,
      );

      ref.invalidate(mentorshipReviewsProvider(widget.sessionId));
      ref.invalidate(mentorshipSessionsProvider);
      ref.invalidate(enrolledSessionsProvider);

      messenger.showSnackBar(
        const SnackBar(
          content: Text('¡Gracias por tu comentario! Reseña guardada con éxito.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Error al guardar reseña: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Calificar esta sesión',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(5, (index) {
              final starIndex = index + 1;
              return IconButton(
                onPressed: () {
                  setState(() {
                    _rating = starIndex;
                  });
                },
                icon: Icon(
                  starIndex <= _rating ? Icons.star_rounded : Icons.star_border_rounded,
                  color: Colors.amber.shade700,
                  size: 32,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              );
            }),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _commentController,
            maxLines: 2,
            maxLength: 150,
            decoration: InputDecoration(
              hintText: '¿Qué te pareció la mentoría y la explicación del mentor?',
              hintStyle: const TextStyle(fontSize: 13),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: LawButton(
              label: 'Enviar Reseña',
              isLoading: _isSubmitting,
              onPressed: _submitReview,
            ),
          ),
        ],
      ),
    );
  }
}
