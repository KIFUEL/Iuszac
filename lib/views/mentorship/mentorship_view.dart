import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/database_provider.dart';
import '../../models/mentorship_session.dart';
import '../../widgets/common_widgets.dart';

class MentorshipView extends ConsumerStatefulWidget {
  const MentorshipView({super.key});

  @override
  ConsumerState<MentorshipView> createState() => _MentorshipViewState();
}

class _MentorshipViewState extends ConsumerState<MentorshipView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(mentorshipSessionsProvider);
    final enrolledAsync = ref.watch(enrolledSessionsProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mentorías'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Todas'),
            Tab(text: 'Mías'),
            Tab(text: 'Participo'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              ref.invalidate(mentorshipSessionsProvider);
              ref.invalidate(enrolledSessionsProvider);
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
              label: 'Buscar materia o mentor...',
              icon: Icons.search,
              controller: _searchController,
              onChanged: (val) =>
                  setState(() => _searchQuery = val.toLowerCase()),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab: Todas
                sessionsAsync.when(
                  data: (sessions) => _buildSessionList(sessions),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: Text('Error: $err')),
                ),
                // Tab: Mías
                sessionsAsync.when(
                  data: (sessions) {
                    final mySessions = sessions
                        .where((s) => s.mentorId == user?.id)
                        .toList();
                    return _buildSessionList(mySessions);
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: Text('Error: $err')),
                ),
                // Tab: Donde participo
                enrolledAsync.when(
                  data: (sessions) => _buildSessionList(sessions),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: Text('Error: $err')),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/mentorship/new'),
        child: const Icon(Icons.add_task_rounded),
      ),
    );
  }

  Widget _buildSessionList(List<MentorshipSession> sessions) {
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
          _buildSessionCard(context, filtered[index]),
    );
  }

  Widget _buildSessionCard(BuildContext context, MentorshipSession session) {
    final colorScheme = Theme.of(context).colorScheme;
    final mentorName = session.mentor?.fullName ?? 'Mentor';

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
                      Text(
                        session.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
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
