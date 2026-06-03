import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common_widgets.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
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
              // ── Encabezado con gradiente ──────────────────────────────
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                stretch: true,
                actions: [
                  IconButton(
                    onPressed: () => context.go('/profile/settings'),
                    icon: const Icon(Icons.settings_outlined),
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
                          // Avatar con borde blanco
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
                                '${profile.role} · ${profile.institution ?? 'Sin institución'}',
                                style: const TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                              if (profile.role == 'Docente' || profile.role == 'Investigador') ...[
                                const SizedBox(width: 6),
                                const Icon(Icons.verified, color: Colors.white, size: 15),
                              ],
                            ],
                          ),
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
                      // Badge Membresía
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

                      // ── Estadísticas ──────────────────────────────────
                      Row(
                        children: [
                          _buildStatCard(context, '8', 'Artículos', Icons.bookmark_outline),
                          const SizedBox(width: 10),
                          _buildStatCard(context, '24', 'Aportes', Icons.forum_outlined),
                          const SizedBox(width: 10),
                          _buildStatCard(context, '3', 'Mentorías', Icons.school_outlined),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // ── Sección de opciones ────────────────────────────
                      Text(
                        'Configuración',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                      ),
                      const SizedBox(height: 8),
                      _buildMenuCard(context, const [
                        _MenuTileData('Notificaciones push', Icons.notifications_active_outlined),
                        _MenuTileData('Artículos guardados', Icons.collections_bookmark_outlined),
                        _MenuTileData('Privacidad y seguridad', Icons.security_outlined),
                        _MenuTileData('Ayuda y soporte', Icons.help_outline_rounded),
                      ]),

                      const SizedBox(height: 32),

                      // ── Cerrar Sesión ──────────────────────────────────
                      LawButton(
                        label: 'Cerrar Sesión',
                        backgroundColor: colorScheme.error,
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Cerrar Sesión'),
                              content: const Text('¿Estás seguro de que deseas salir?'),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancelar'),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(context, true),
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
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

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
                onTap: () {},
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
  const _MenuTileData(this.title, this.icon);
}
