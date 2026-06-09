import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/database_provider.dart';
import '../../widgets/common_widgets.dart';

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
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_off_outlined, size: 64, color: colorScheme.outline),
                  const SizedBox(height: 16),
                  Text(
                    'Inicia sesión para ver tu perfil',
                    style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            );
          }

          final fullName = '${profile.fullName} ${profile.lastName ?? ''}'.trim();
          final initials = (profile.fullName.isNotEmpty ? profile.fullName[0] : 'U').toUpperCase();

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                stretch: true,
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
                          const SizedBox(height: 10),
                          // Píldora de Nivel de Acceso (Usuario / Mentor / Admin)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  profile.isAdmin 
                                      ? Icons.admin_panel_settings_rounded 
                                      : (profile.canMentor ? Icons.school_rounded : Icons.person_rounded),
                                  size: 16, 
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  profile.isAdmin 
                                      ? 'ADMINISTRADOR' 
                                      : (profile.canMentor ? 'MENTOR' : 'USUARIO'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
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
                          const SizedBox(height: 14),
                          Text(
                            fullName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8, // Espacio horizontal entre elementos
                            runSpacing: 8, // Espacio vertical si bajan de línea
                            children: [
                              // Píldora de Ocupación
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(
                                  (profile.label ?? 'Usuario').toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ),
                              // Texto de Institución
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    profile.institution ?? 'Sin institución',
                                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                                  ),
                                  if (profile.label == 'Docente' || profile.label == 'Investigador') ...[
                                    const SizedBox(width: 6),
                                    const Icon(Icons.verified, color: Colors.white, size: 16),
                                  ],
                                ],
                              ),
                              // Píldora de Mentor (Estrellas)
                              if (profile.canMentor)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${profile.rating} (${profile.reviewCount})',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                profile.bio!,
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 14,
                                  height: 1.5,
                                ),
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
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Estadísticas REALES desde Supabase ────────
                          statsAsync.when(
                            data: (stats) => Container(
                              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return Row(
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
                                  );
                                },
                              ),
                            ),
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (_, __) => const SizedBox(),
                          ),

                          const SizedBox(height: 24),

                          // ── Visual divider between stats and menu ──────
                          Divider(
                            color: colorScheme.outline.withValues(alpha: 0.12),
                            height: 1,
                          ),

                          const SizedBox(height: 24),

                          // ── Opciones de Perfil ─────────────────────────
                          _buildSectionLabel(context, 'Configuración', Icons.settings_outlined),
                          const SizedBox(height: 12),
                          _buildMenuCard(context, [
                            _MenuTileData(
                              'Notificaciones',
                              Icons.notifications_active_outlined,
                              onTap: () => context.go('/profile/notifications'),
                            ),
                            _MenuTileData(
                              'Editar Perfil',
                              Icons.edit_outlined,
                              onTap: () => context.go('/profile/edit'),
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
                              onTap: () => context.go('/profile/security'),
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
                            icon: Icons.logout_rounded,
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
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.08)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: colorScheme.onPrimaryContainer),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
          height: 22,
          decoration: BoxDecoration(
            color: colorScheme.secondary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, size: 18, color: colorScheme.primary),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
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
      padding: const EdgeInsets.symmetric(vertical: 4),
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
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 56),
                child: ListTile(
                minVerticalPadding: 0,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, size: 20, color: colorScheme.primary),
                ),
                title: Text(
                  item.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                trailing: Icon(Icons.chevron_right, size: 20, color: colorScheme.outline),
                onTap: item.onTap,
              ),
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


}

class _MenuTileData {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  const _MenuTileData(this.title, this.icon, {this.onTap});
}
