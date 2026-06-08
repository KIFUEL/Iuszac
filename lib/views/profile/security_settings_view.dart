import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../models/profile.dart';

class SecuritySettingsView extends ConsumerWidget {
  const SecuritySettingsView({super.key});

  Future<void> _changePassword(BuildContext context, WidgetRef ref) async {
    final email = ref.read(currentUserProvider)?.email;
    if (email == null) return;

    final authService = ref.read(authServiceProvider);
    await authService.resetPassword(email);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Se envió un correo de recuperación a $email'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _confirmDeleteAccount(BuildContext context, Profile profile) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: colorScheme.error),
            const SizedBox(width: 8),
            const Text('Eliminar cuenta'),
          ],
        ),
        content: const Text(
          '¿Estás seguro? Esta acción eliminará permanentemente tu cuenta y todos tus datos. No se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Aquí se llamaría al endpoint de eliminación de cuenta
            },
            style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
            child: const Text('Eliminar definitivamente'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final currentUser = ref.watch(currentUserProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seguridad y Privacidad', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/profile'),
        ),
      ),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('No se encontró el perfil'));
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                children: [
                  const Text(
                    'Administra las credenciales de tu cuenta y la seguridad de tus datos.',
                    style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.4),
                  ),
                  const SizedBox(height: 24),

                  // ── Cuenta y Seguridad ─────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colorScheme.outline.withValues(alpha: 0.08)),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.password_outlined, size: 18, color: colorScheme.primary),
                          ),
                          title: const Text('Cambiar Contraseña', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          subtitle: const Text('Te enviaremos un correo de recuperación', style: TextStyle(fontSize: 11)),
                          trailing: Icon(Icons.chevron_right, size: 18, color: colorScheme.outline),
                          onTap: () => _changePassword(context, ref),
                        ),
                        Divider(height: 1, indent: 56, color: colorScheme.outline.withValues(alpha: 0.08)),
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.email_outlined, size: 18, color: colorScheme.primary),
                          ),
                          title: const Text('Correo Electrónico', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          subtitle: Text(
                            currentUser?.email ?? 'No disponible',
                            style: TextStyle(fontSize: 11, color: colorScheme.secondary),
                          ),
                          trailing: Icon(Icons.lock_outline, size: 16, color: colorScheme.outline),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Zona de peligro ────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colorScheme.error.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: colorScheme.error, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Zona de Peligro',
                              style: TextStyle(
                                color: colorScheme.error,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Esta acción es irreversible. Se borrarán todos tus marcadores, publicaciones en el foro y aportes.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _confirmDeleteAccount(context, profile),
                            icon: Icon(Icons.delete_forever_outlined, color: colorScheme.error),
                            label: Text(
                              'Eliminar mi cuenta definitivamente',
                              style: TextStyle(color: colorScheme.error, fontWeight: FontWeight.bold),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: colorScheme.error.withValues(alpha: 0.5)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
