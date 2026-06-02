import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  String _selectedCommunity = 'Todos';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(mentorshipSessionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mentorías'),
        actions: [
          IconButton(
            onPressed: () => ref.invalidate(mentorshipSessionsProvider),
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Buscador y Filtro
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                LawTextField(
                  label: 'Buscar materia o mentor...',
                  icon: Icons.search,
                  controller: _searchController,
                  onChanged: (val) =>
                      setState(() => _searchQuery = val.toLowerCase()),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Todos'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Apoyo UAZ'),
                      const SizedBox(width: 8),
                      _buildFilterChip('ApoyoZac'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: sessionsAsync.when(
              data: (sessions) {
                final filtered = sessions.where((s) {
                  final matchesSearch =
                      s.title.toLowerCase().contains(_searchQuery) ||
                          s.specialty.toLowerCase().contains(_searchQuery);
                  final matchesComm = _selectedCommunity == 'Todos' ||
                      (_selectedCommunity == 'Apoyo UAZ' &&
                          s.isCommunityVerified);
                  return matchesSearch && matchesComm;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                      child: Text('No se encontraron sesiones.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) =>
                      _buildSessionCard(context, filtered[index]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
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

  Widget _buildFilterChip(String label) {
    return FilterChip(
      label: Text(label),
      selected: _selectedCommunity == label,
      onSelected: (val) {
        if (val) setState(() => _selectedCommunity = label);
      },
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
                  child: Text(mentorName[0]),
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
                const Text('Lun-Vie 18:00',
                    style: TextStyle(color: Colors.grey, fontSize: 11)),
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
                  onPressed: () {
                    // Navegar a detalle
                  },
                  style: ElevatedButton.styleFrom(
                      visualDensity: VisualDensity.compact),
                  child: const Text('Unirme'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
