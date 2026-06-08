import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/auth_provider.dart';
import '../../providers/database_provider.dart';
import '../../models/mentorship_session.dart';
import '../../widgets/common_widgets.dart';

class MentorshipView extends ConsumerStatefulWidget {
  const MentorshipView({super.key});

  @override
  ConsumerState<MentorshipView> createState() => _MentorshipViewState();
}

class _MentorshipViewState extends ConsumerState<MentorshipView> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _deleteSession(MentorshipSession session, String mentorId) async {
    try {
      final dbService = ref.read(databaseServiceProvider);
      await dbService.deleteMentorshipSession(session.id);
      ref.invalidate(mentorshipSessionsProvider);
      ref.invalidate(myMentorshipSessionsProvider(mentorId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sesión de mentoría eliminada.'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _confirmDeleteSession(BuildContext context, MentorshipSession session, String mentorId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar sesión de mentoría?'),
        content: const Text('Esta acción es irreversible y removerá la sesión.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteSession(session, mentorId);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(mentorshipSessionsProvider);
    final enrolledAsync = ref.watch(enrolledSessionsProvider);
    final profile = ref.watch(userProfileProvider).value;
    final colorScheme = Theme.of(context).colorScheme;

    final isMentor = profile?.userType == 'mentor';

    return DefaultTabController(
      length: isMentor ? 3 : 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mentorías'),
          bottom: TabBar(
            tabs: [
              const Tab(text: 'Todas'),
              if (isMentor) const Tab(text: 'Mías'),
              const Tab(text: 'Me inscribí'),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {
                ref.invalidate(mentorshipSessionsProvider);
                ref.invalidate(enrolledSessionsProvider);
                if (profile != null) {
                  ref.invalidate(myMentorshipSessionsProvider(profile.id));
                }
              },
              icon: const Icon(Icons.refresh_rounded),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: LawTextField(
                label: 'Buscar materia o especialidad...',
                icon: Icons.search,
                controller: _searchController,
                onChanged: (val) =>
                    setState(() => _searchQuery = val.toLowerCase()),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Tab: Todas
                  sessionsAsync.when(
                    data: (sessions) => _buildSessionList(sessions, false, profile?.id),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Center(child: Text('Error: $err')),
                  ),
                  // Tab: Mías
                  if (isMentor)
                    ref.watch(myMentorshipSessionsProvider(profile!.id)).when(
                      data: (sessions) => _buildSessionList(sessions, true, profile.id),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Center(child: Text('Error: $err')),
                    ),
                  // Tab: Me inscribí
                  enrolledAsync.when(
                    data: (sessions) => _buildSessionList(sessions, false, profile?.id),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Center(child: Text('Error: $err')),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: isMentor
            ? Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, colorScheme.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: FloatingActionButton(
                  onPressed: () => context.go('/mentorship/new'),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  child: const Icon(Icons.add_task_rounded, color: Colors.white),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildSessionList(List<MentorshipSession> sessions, bool isMyTab, String? currentUserId) {
    final filtered = sessions.where((s) {
      return s.title.toLowerCase().contains(_searchQuery) ||
          s.specialty.toLowerCase().contains(_searchQuery);
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.school_outlined,
                size: 64,
                color: Colors.grey.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 16),
              Text(
                'No hay sesiones disponibles',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Intenta buscar con otros términos o revisa más tarde.',
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth > 700
            ? (constraints.maxWidth - 700) / 2 + 16
            : 16.0;

        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
          itemCount: filtered.length,
          itemBuilder: (context, index) =>
              _buildSessionCard(context, filtered[index], isMyTab, currentUserId),
        );
      },
    );
  }

  Widget _buildSessionCard(BuildContext context, MentorshipSession session, bool isMyTab, String? currentUserId) {
    final colorScheme = Theme.of(context).colorScheme;
    final mentorName = session.mentor?.fullName ?? 'Mentor';
    final phone = session.mentor?.phoneWhatsapp;
    final hasPhone = phone != null && phone.trim().isNotEmpty;
    final isExpired = session.sessionDate.isBefore(DateTime.now());

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: LawCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header row: avatar, title, mentor name, badges ---
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(
                    mentorName.isNotEmpty ? mentorName[0] : 'U',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
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
                if (isMyTab && !isExpired && currentUserId != null)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'edit') {
                        context.go('/mentorship/edit/${session.id}');
                      } else if (value == 'delete') {
                        _confirmDeleteSession(context, session, currentUserId);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Editar'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Eliminar', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // --- Rating & schedule row ---
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
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  'Sesión: ${DateFormat('dd/MM HH:mm').format(session.sessionDate)}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
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
                // WhatsApp button with background circle
                if (hasPhone && !isMyTab) ...[
                  Material(
                    color: Colors.green.withValues(alpha: 0.1),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () async {
                        final text = Uri.encodeComponent('Hola, me interesa tu mentoría: ${session.title}');
                        final url = Uri.parse('https://wa.me/$phone?text=$text');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(Icons.chat_rounded, color: Colors.green, size: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
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
