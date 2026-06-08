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
              padding: const EdgeInsets.all(16.0),
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
      return const Center(child: Text('No hay sesiones disponibles.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) =>
          _buildSessionCard(context, filtered[index], isMyTab, currentUserId),
    );
  }

  Widget _buildSessionCard(BuildContext context, MentorshipSession session, bool isMyTab, String? currentUserId) {
    final colorScheme = Theme.of(context).colorScheme;
    final mentorName = session.mentor?.fullName ?? 'Mentor';
    final phone = session.mentor?.phoneWhatsapp;
    final hasPhone = phone != null && phone.trim().isNotEmpty;
    final isExpired = session.expiresAt != null && session.expiresAt!.isBefore(DateTime.now());

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: LawCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(mentorName.isNotEmpty ? mentorName[0] : 'U'),
                ),
                const SizedBox(width: 12),
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
                                  fontWeight: FontWeight.bold, fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isExpired)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: colorScheme.outlineVariant,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'VENCIDA',
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Text(
                        '$mentorName · ${session.specialty}',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (session.isCommunityVerified)
                  const Icon(Icons.verified, color: Colors.blue, size: 20),
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
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(session.rating.toString(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 12)),
                Text(' (${session.reviewCount} reseñas)',
                    style: const TextStyle(color: Colors.grey, fontSize: 11)),
                const Spacer(),
                const Icon(Icons.schedule, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  session.expiresAt != null 
                      ? 'Hasta: ${DateFormat('dd/MM').format(session.expiresAt!)}' 
                      : 'Proximamente',
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: session.price == 0
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    session.price == 0 ? 'GRATIS' : '\$${session.price}',
                    style: TextStyle(
                      color: session.price == 0
                          ? Colors.green
                          : Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (session.availableSlots > 0)
                  Text(
                    '${session.availableSlots} cupos',
                    style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 10),
                  ),
                const Spacer(),
                if (hasPhone && !isMyTab) ...[
                  IconButton(
                    icon: const Icon(Icons.chat, color: Colors.green, size: 20),
                    onPressed: () async {
                      final text = Uri.encodeComponent('Hola, me interesa tu mentoría: ${session.title}');
                      final url = Uri.parse('https://wa.me/$phone?text=$text');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    },
                    tooltip: 'WhatsApp al mentor',
                  ),
                  const SizedBox(width: 8),
                ],
                ElevatedButton(
                  onPressed: () => context.go('/mentorship/${session.id}'),
                  style: ElevatedButton.styleFrom(
                      visualDensity: VisualDensity.compact),
                  child: const Text('Ver más'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
