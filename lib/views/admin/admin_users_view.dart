import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/database_provider.dart';
import '../../models/profile.dart';
import '../../widgets/common_widgets.dart';
import 'admin_suspend_view.dart';

class AdminUsersView extends ConsumerStatefulWidget {
  const AdminUsersView({super.key});

  @override
  ConsumerState<AdminUsersView> createState() => _AdminUsersViewState();
}

class _AdminUsersViewState extends ConsumerState<AdminUsersView> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _filter = 'Todos'; // 'Todos', 'Con Permisos', 'Suspendidos'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openPermissionsSheet(BuildContext context, Profile user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: _PermissionsBottomSheet(user: user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(allUsersProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gestión de Usuarios',
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
            child: Column(
              children: [
                LawTextField(
                  label: 'Buscar usuario...',
                  icon: Icons.search,
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.trim().toLowerCase();
                    });
                  },
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Todos'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Con Permisos'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Suspendidos'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: usersAsync.when(
              data: (users) {
                var filteredUsers = users.where((u) {
                  final nameMatch = u.fullName.toLowerCase().contains(_searchQuery) ||
                      (u.lastName?.toLowerCase().contains(_searchQuery) ?? false);
                  final bioMatch = u.bio?.toLowerCase().contains(_searchQuery) ?? false;
                  final instMatch = u.institution?.toLowerCase().contains(_searchQuery) ?? false;
                  return nameMatch || bioMatch || instMatch;
                }).toList();

                if (_filter == 'Con Permisos') {
                  filteredUsers = filteredUsers.where((u) => u.isAdmin || u.canMentor || u.canPublish || u.canModerate).toList();
                } else if (_filter == 'Suspendidos') {
                  filteredUsers = filteredUsers.where((u) => u.isActivelySuspended).toList();
                }

                if (filteredUsers.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(
                        'No se encontraron usuarios.',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    return _buildUserCard(context, filteredUsers[index]);
                  },
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

  Widget _buildFilterChip(String label) {
    final selected = _filter == label;
    final colorScheme = Theme.of(context).colorScheme;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (val) {
        if (val) {
          setState(() {
            _filter = label;
          });
        }
      },
      selectedColor: colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: selected ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, Profile user) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSuspended = user.isActivelySuspended;

    String suspensionRemaining = '';
    if (isSuspended && user.suspendedUntil != null) {
      final diff = user.suspendedUntil!.difference(DateTime.now());
      if (diff.inDays > 0) {
        suspensionRemaining = '${diff.inDays}d';
      } else if (diff.inHours > 0) {
        suspensionRemaining = '${diff.inHours}h';
      } else {
        suspensionRemaining = '${diff.inMinutes}m';
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: user.isAdmin ? colorScheme.primary : colorScheme.outlineVariant,
                  foregroundColor: user.isAdmin ? colorScheme.onPrimary : colorScheme.onSurface,
                  radius: 24,
                  backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty 
                      ? NetworkImage(user.avatarUrl!) 
                      : null,
                  child: user.avatarUrl == null || user.avatarUrl!.isEmpty
                      ? Text(user.fullName.isNotEmpty ? user.fullName.substring(0, 1).toUpperCase() : 'U')
                      : null,
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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isSuspended)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: colorScheme.error,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'SUSPENDIDO $suspensionRemaining',
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${user.isAdmin ? 'Administrador' : 'Usuario'} · ${user.label ?? 'Sin etiqueta'}',
                        style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 8),
                      // Chips de permisos
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          if (user.isAdmin)
                            _buildPermissionChip('👑 Admin', colorScheme.primary),
                          if (user.canMentor)
                            _buildPermissionChip('🎓 Mentor', Colors.blue),
                          if (user.canPublish)
                            _buildPermissionChip('📰 Editor', Colors.orange),
                          if (user.canModerate)
                            _buildPermissionChip('🛡 Moderador', Colors.purple),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _openPermissionsSheet(context, user),
                  icon: const Icon(Icons.tune_rounded, size: 18),
                  label: const Text('Permisos'),
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.3),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _PermissionsBottomSheet extends ConsumerStatefulWidget {
  final Profile user;
  const _PermissionsBottomSheet({required this.user});

  @override
  ConsumerState<_PermissionsBottomSheet> createState() => _PermissionsBottomSheetState();
}

class _PermissionsBottomSheetState extends ConsumerState<_PermissionsBottomSheet> {
  late bool _isAdmin;
  late bool _canMentor;
  late bool _canPublish;
  late bool _canModerate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isAdmin = widget.user.isAdmin;
    _canMentor = widget.user.canMentor;
    _canPublish = widget.user.canPublish;
    _canModerate = widget.user.canModerate;
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    try {
      final dbService = ref.read(databaseServiceProvider);
      await dbService.updateUserPermissions(
        widget.user.id,
        _canMentor,
        _canPublish,
        _canModerate,
      );
      
      // Update the user_type for Admin status
      await dbService.updateProfile(
        userId: widget.user.id,
        userType: _isAdmin ? 'admin' : 'user',
      );

      ref.invalidate(allUsersProvider);
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permisos actualizados correctamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Editar Permisos',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.primary),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.pop(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.user.fullName} ${widget.user.lastName ?? ''}',
            style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          SwitchListTile(
            title: const Text('👑 Administrador General'),
            subtitle: const Text('Otorga todos los permisos por defecto'),
            value: _isAdmin,
            onChanged: (val) => setState(() => _isAdmin = val),
            activeTrackColor: colorScheme.primary,
          ),
          const Divider(),
          if (_isAdmin)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: colorScheme.onPrimaryContainer),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Este usuario es un administrador general y tiene todos los permisos por defecto.',
                      style: TextStyle(color: colorScheme.onPrimaryContainer, fontSize: 13),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            SwitchListTile(
              title: const Text('🎓 Puede publicar mentorías'),
              subtitle: const Text('Permite crear sesiones y recibir estudiantes'),
              value: _canMentor,
              onChanged: (val) => setState(() => _canMentor = val),
              activeTrackColor: Colors.blue.withValues(alpha: 0.5),
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('📰 Puede publicar noticias'),
              subtitle: const Text('Da acceso al panel de redacción de reformas'),
              value: _canPublish,
              onChanged: (val) => setState(() => _canPublish = val),
              activeTrackColor: Colors.orange.withValues(alpha: 0.5),
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('🛡 Puede moderar contenido'),
              subtitle: const Text('Permite eliminar posts y comentarios en foros'),
              value: _canModerate,
              onChanged: (val) => setState(() => _canModerate = val),
              activeTrackColor: Colors.purple.withValues(alpha: 0.5),
            ),
          ],
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonal(
                  onPressed: () {
                    context.pop();
                    showDialog(
                      context: context,
                      builder: (ctx) => Dialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        clipBehavior: Clip.antiAlias,
                        child: SizedBox(
                          width: 500,
                          height: MediaQuery.of(context).size.height * 0.8,
                          child: AdminSuspendView(userId: widget.user.id),
                        ),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.errorContainer,
                    foregroundColor: colorScheme.onErrorContainer,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Suspender', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: widget.user.isAdmin || _isLoading ? null : () => _saveChanges(),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Guardar Cambios', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
