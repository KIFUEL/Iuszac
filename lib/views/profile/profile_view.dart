import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/database_provider.dart';
import '../../widgets/common_widgets.dart';
import '../../models/profile.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final statsAsync = ref.watch(profileStatsProvider);
    final authService = ref.watch(authServiceProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('Inicia sesión para ver tu perfil'));
          }

          final fullName = '${profile.fullName} ${profile.lastName ?? ''}'.trim();
          final initials = (profile.fullName.isNotEmpty ? profile.fullName[0] : 'U').toUpperCase();

          return CustomScrollView(
            slivers: [
              // ── Hero Header con gradiente ─────────────────────────
              SliverAppBar(
                expandedHeight: 240,
                pinned: true,
                stretch: true,
                actions: [
                  IconButton(
                    tooltip: 'Ajustes',
                    onPressed: () => context.go('/profile/settings'),
                    icon: const Icon(Icons.settings_outlined),
                  ),
                  IconButton(
                    tooltip: 'Editar perfil',
                    onPressed: () => _showEditProfileDialog(context, ref, profile),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.primary,
                          colorScheme.primary.withValues(alpha: 0.75),
                          colorScheme.secondary.withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 46,
                              backgroundColor: colorScheme.primaryContainer,
                              child: Text(
                                initials,
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            fullName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${profile.label ?? 'Usuario'} · ${profile.institution ?? 'Sin institución'}',
                                style: const TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                              if (profile.label == 'Docente' || profile.label == 'Investigador') ...[
                                const SizedBox(width: 6),
                                const Icon(Icons.verified, color: Colors.white, size: 15),
                              ],
                            ],
                          ),
                          if (profile.userType != 'user') ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: profile.userType == 'admin' ? Colors.red : Colors.amber.shade700,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                profile.userType == 'admin' ? 'ADMINISTRADOR' : 'MENTOR',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                          if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                profile.bio!,
                                style: const TextStyle(color: Colors.white60, fontSize: 12),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Badge Membresía ─────────────────────────────
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                colorScheme.secondary.withValues(alpha: 0.15),
                                colorScheme.secondary.withValues(alpha: 0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.workspace_premium, size: 14, color: colorScheme.secondary),
                              const SizedBox(width: 6),
                              Text(
                                'MIEMBRO PRO',
                                style: TextStyle(
                                  color: colorScheme.secondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Estadísticas REALES desde Supabase ────────
                      statsAsync.when(
                        data: (stats) => Row(
                          children: [
                            _buildStatCard(
                              context,
                              '${stats['aportes'] ?? 0}',
                              'Aportes',
                              Icons.forum_outlined,
                            ),
                            const SizedBox(width: 10),
                            _buildStatCard(
                              context,
                              '${stats['mentorias'] ?? 0}',
                              'Mentorías',
                              Icons.school_outlined,
                            ),
                          ],
                        ),
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (_, __) => const SizedBox(),
                      ),

                      const SizedBox(height: 28),



                      // ── Opciones de Perfil ─────────────────────────
                      _buildSectionLabel(context, 'Configuración', Icons.settings_outlined),
                      const SizedBox(height: 10),
                      _buildMenuCard(context, [
                        _MenuTileData(
                          'Notificaciones',
                          Icons.notifications_active_outlined,
                          onTap: () => context.go('/profile/settings'),
                        ),
                        _MenuTileData(
                          'Editar Perfil',
                          Icons.edit_outlined,
                          onTap: () => _showEditProfileDialog(context, ref, profile),
                        ),
                        if (profile.role == 'admin')
                          _MenuTileData(
                            'Panel de Administración',
                            Icons.admin_panel_settings_outlined,
                            onTap: () => context.push('/admin'),
                          ),
                        _MenuTileData(
                          'Privacidad y seguridad',
                          Icons.security_outlined,
                          onTap: () => context.go('/profile/settings'),
                        ),
                        _MenuTileData(
                          'Ayuda y soporte',
                          Icons.help_outline_rounded,
                          onTap: () {},
                        ),
                      ]),

                      const SizedBox(height: 32),

                      // ── Cerrar Sesión ──────────────────────────────
                      LawButton(
                        label: 'Cerrar Sesión',
                        backgroundColor: colorScheme.error,
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Cerrar Sesión'),
                              content: const Text('¿Estás seguro de que deseas salir?'),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancelar'),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
                                  child: const Text('Salir'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await authService.signOut();
                          }
                        },
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  // ── Estadística individual ─────────────────────────────────────────────────
  Widget _buildStatCard(BuildContext context, String value, String label, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.08)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: colorScheme.onPrimaryContainer),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  // ── Encabezado de sección ──────────────────────────────────────────────────
  Widget _buildSectionLabel(BuildContext context, String title, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, size: 16, color: colorScheme.primary),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  // ── Menú agrupado ──────────────────────────────────────────────────────────
  Widget _buildMenuCard(BuildContext context, List<_MenuTileData> items) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, size: 18, color: colorScheme.primary),
                ),
                title: Text(item.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                trailing: Icon(Icons.chevron_right, size: 18, color: colorScheme.outline),
                onTap: item.onTap,
              ),
              if (i < items.length - 1)
                Divider(
                  height: 1,
                  indent: 56,
                  color: colorScheme.outline.withValues(alpha: 0.08),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ── Dialog de edición de perfil ────────────────────────────────────────────
  void _showEditProfileDialog(BuildContext context, WidgetRef ref, Profile profile) {
    final nameCtrl = TextEditingController(text: profile.fullName);
    final lastNameCtrl = TextEditingController(text: profile.lastName ?? '');
    final bioCtrl = TextEditingController(text: profile.bio ?? '');
    final institutionCtrl = TextEditingController(text: profile.institution ?? '');
    final semesterCtrl = TextEditingController(text: profile.semesterDegree ?? '');
    final phoneCtrl = TextEditingController(text: profile.phoneWhatsapp ?? '');
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final colorScheme = Theme.of(ctx).colorScheme;
          return DraggableScrollableSheet(
            initialChildSize: 0.85,
            maxChildSize: 0.95,
            minChildSize: 0.5,
            builder: (_, scrollCtrl) => Container(
              decoration: BoxDecoration(
                color: Theme.of(ctx).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colorScheme.outline.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                    child: Row(
                      children: [
                        Text(
                          'Editar Perfil',
                          style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView(
                      controller: scrollCtrl,
                      padding: EdgeInsets.fromLTRB(
                        24,
                        20,
                        24,
                        MediaQuery.of(ctx).viewInsets.bottom + 24,
                      ),
                      children: [
                        LawTextField(
                          label: 'Nombre(s)',
                          icon: Icons.person_outline,
                          controller: nameCtrl,
                        ),
                        const SizedBox(height: 16),
                        LawTextField(
                          label: 'Apellidos',
                          icon: Icons.badge_outlined,
                          controller: lastNameCtrl,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: bioCtrl,
                          maxLines: 3,
                          maxLength: 200,
                          decoration: InputDecoration(
                            labelText: 'Biografía breve',
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(bottom: 48),
                              child: Icon(Icons.notes_outlined),
                            ),
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: colorScheme.surface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LawTextField(
                          label: 'Institución',
                          icon: Icons.school_outlined,
                          controller: institutionCtrl,
                        ),
                        const SizedBox(height: 16),
                        LawTextField(
                          label: 'Semestre / Grado',
                          icon: Icons.menu_book_outlined,
                          controller: semesterCtrl,
                        ),
                        if (profile.userType == 'mentor' || profile.userType == 'admin') ...[
                          const SizedBox(height: 16),
                          LawTextField(
                            label: 'Celular WhatsApp',
                            icon: Icons.phone_android,
                            controller: phoneCtrl,
                            keyboardType: TextInputType.phone,
                          ),
                        ],
                        const SizedBox(height: 28),
                        LawButton(
                          label: 'Guardar Cambios',
                          isLoading: isSaving,
                          onPressed: () async {
                            setModalState(() => isSaving = true);
                            try {
                              final dbService = ref.read(profileUpdateProvider);
                              await dbService.updateProfile(
                                userId: profile.id,
                                fullName: nameCtrl.text.trim(),
                                lastName: lastNameCtrl.text.trim(),
                                bio: bioCtrl.text.trim(),
                                institution: institutionCtrl.text.trim(),
                                semesterDegree: semesterCtrl.text.trim(),
                                phoneWhatsapp: (profile.userType == 'mentor' || profile.userType == 'admin') ? phoneCtrl.text.trim() : null,
                              );
                              ref.invalidate(userProfileProvider);
                              ref.invalidate(profileStatsProvider);
                              if (ctx.mounted) {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Perfil actualizado correctamente'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (ctx.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            } finally {
                              if (ctx.mounted) setModalState(() => isSaving = false);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MenuTileData {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  const _MenuTileData(this.title, this.icon, {this.onTap});
}
