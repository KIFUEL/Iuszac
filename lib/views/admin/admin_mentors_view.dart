import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/database_provider.dart';
import '../../models/profile.dart';
import '../../widgets/common_widgets.dart';

class AdminMentorsView extends ConsumerStatefulWidget {
  const AdminMentorsView({super.key});

  @override
  ConsumerState<AdminMentorsView> createState() => _AdminMentorsViewState();
}

class _AdminMentorsViewState extends ConsumerState<AdminMentorsView> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(allUsersProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gestión de Mentores',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(allUsersProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: LawTextField(
              label: 'Buscar usuario por nombre o correo',
              icon: Icons.search,
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim().toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: usersAsync.when(
              data: (users) {
                // Filter users based on query
                final filteredUsers = users.where((u) {
                  final nameMatch = u.fullName.toLowerCase().contains(_searchQuery) ||
                      (u.lastName?.toLowerCase().contains(_searchQuery) ?? false);
                  // We can't access email directly from profiles table unless we have it stored or if we match by institution/bio
                  final bioMatch = u.bio?.toLowerCase().contains(_searchQuery) ?? false;
                  final instMatch = u.institution?.toLowerCase().contains(_searchQuery) ?? false;
                  return nameMatch || bioMatch || instMatch;
                }).toList();

                final mentors = filteredUsers.where((u) => u.userType == 'mentor').toList();
                final nonMentors = filteredUsers.where((u) => u.userType == 'user').toList();

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  children: [
                    if (mentors.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Mentores Actuales (${mentors.length})',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                      ...mentors.map((user) => _buildUserCard(context, user, true)),
                      const SizedBox(height: 16),
                    ],
                    if (nonMentors.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Promover Usuario / Otros (${nonMentors.length})',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      ...nonMentors.map((user) => _buildUserCard(context, user, false)),
                    ],
                    if (filteredUsers.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text(
                            'No se encontraron usuarios.',
                            style: TextStyle(color: colorScheme.onSurfaceVariant),
                          ),
                        ),
                      ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text('Error al cargar usuarios: $err', style: const TextStyle(color: Colors.red)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, Profile user, bool isMentor) {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final isSuspended = user.isSuspended && (user.suspendedUntil == null || user.suspendedUntil!.isAfter(now));

    String suspensionRemaining = '';
    if (isSuspended && user.suspendedUntil != null) {
      final diff = user.suspendedUntil!.difference(now);
      if (diff.inDays > 0) {
        suspensionRemaining = '${diff.inDays}d restantes';
      } else if (diff.inHours > 0) {
        suspensionRemaining = '${diff.inHours}h restantes';
      } else {
        suspensionRemaining = '${diff.inMinutes}m restantes';
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: isMentor ? colorScheme.primary : colorScheme.outlineVariant,
              foregroundColor: isMentor ? colorScheme.onPrimary : colorScheme.onSurface,
              radius: 24,
              child: Text(user.fullName.substring(0, 1).toUpperCase()),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${user.fullName} ${user.lastName ?? ''}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      if (isSuspended)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'SUSPENDIDO ${suspensionRemaining.isNotEmpty ? '($suspensionRemaining)' : ''}',
                            style: TextStyle(
                              color: colorScheme.onErrorContainer,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.label ?? 'Sin etiqueta profesional',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                    ),
                  ),
                  if (user.institution != null && user.institution!.isNotEmpty)
                    Text(
                      user.institution!,
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (isMentor)
                  ElevatedButton(
                    onPressed: () => _showRoleDialog(context, user, false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.error.withValues(alpha: 0.1),
                      foregroundColor: colorScheme.error,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: const Text('Revocar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  )
                else
                  ElevatedButton(
                    onPressed: () => _showRoleDialog(context, user, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                      foregroundColor: colorScheme.primary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: const Text('Hacer Mentor', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'suspend') {
                  context.push('/admin/suspend/${user.id}');
                } else if (value == 'unsuspend') {
                  _liftSuspension(user.id);
                }
              },
              itemBuilder: (context) => [
                if (!isSuspended)
                  const PopupMenuItem(
                    value: 'suspend',
                    child: Row(
                      children: [
                        Icon(Icons.block, color: Colors.red, size: 18),
                        SizedBox(width: 8),
                        Text('Suspender usuario'),
                      ],
                    ),
                  )
                else
                  const PopupMenuItem(
                    value: 'unsuspend',
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline, color: Colors.green, size: 18),
                        SizedBox(width: 8),
                        Text('Levantar suspensión'),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRoleDialog(BuildContext context, Profile user, bool makeMentor) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(makeMentor ? '¿Promover a Mentor?' : '¿Revocar rol de Mentor?'),
        content: Text(
          makeMentor
              ? 'El usuario ${user.fullName} podrá publicar, editar y eliminar sus propias sesiones de mentoría.'
              : 'El usuario ${user.fullName} perderá la capacidad de gestionar sesiones de mentoría.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                final dbService = ref.read(databaseServiceProvider);
                await dbService.updateUserType(user.id, makeMentor ? 'mentor' : 'user');
                ref.invalidate(allUsersProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(makeMentor ? 'Usuario promovido a Mentor' : 'Rol de Mentor revocado'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al cambiar rol: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(
              makeMentor ? 'Aceptar' : 'Revocar',
              style: TextStyle(color: makeMentor ? colorScheme.primary : colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _liftSuspension(String userId) async {
    try {
      final dbService = ref.read(databaseServiceProvider);
      await dbService.liftSuspension(userId);
      ref.invalidate(allUsersProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La suspensión del usuario ha sido levantada.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al levantar suspensión: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
