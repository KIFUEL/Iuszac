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
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        actions: [
          IconButton(
            onPressed: () => context.go('/profile/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) return const Center(child: Text('Inicia sesión para ver tu perfil'));

          final fullName = '${profile.fullName} ${profile.lastName ?? ''}'.trim();
          final initials = (profile.fullName.isNotEmpty ? profile.fullName[0] : 'U').toUpperCase();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Avatar e iniciales
                CircleAvatar(
                  radius: 50,
                  backgroundColor: colorScheme.primary,
                  child: Text(
                    initials,
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Nombre y Rol
                Text(
                  fullName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${profile.role} · ${profile.institution ?? 'Sin institución'}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    if (profile.role == 'Docente' || profile.role == 'Investigador')
                      const Padding(
                        padding: EdgeInsets.only(left: 8.0),
                        child: Icon(Icons.verified, color: Colors.blue, size: 16),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Badge Membresía
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'Miembro Pro'.toUpperCase(),
                    style: TextStyle(
                      color: colorScheme.secondary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Estadísticas
                Row(
                  children: [
                    _buildStatCard('8', 'Artículos', Icons.bookmark_outline),
                    _buildStatCard('24', 'Aportes', Icons.forum_outlined),
                    _buildStatCard('3', 'Mentorías', Icons.school_outlined),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Opciones
                _buildMenuTile(context, 'Notificaciones push', Icons.notifications_active_outlined),
                _buildMenuTile(context, 'Artículos guardados', Icons.collections_bookmark_outlined),
                _buildMenuTile(context, 'Privacidad y seguridad', Icons.security_outlined),
                _buildMenuTile(context, 'Ayuda y soporte', Icons.help_outline_rounded),
                
                const SizedBox(height: 40),
                
                LawButton(
                  label: 'Cerrar Sesión',
                  backgroundColor: colorScheme.error,
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Cerrar Sesión'),
                        content: const Text('¿Estás seguro de que deseas salir?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Salir')),
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
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Expanded(
      child: LawCard(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Icon(icon, size: 20, color: Colors.grey),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile(BuildContext context, String title, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      trailing: const Icon(Icons.chevron_right, size: 18),
      onTap: () {},
    );
  }
}
