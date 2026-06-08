import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../models/profile.dart';
import '../../widgets/common_widgets.dart';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  // Estado local de los toggles, inicializados desde el perfil
  bool? _notifReforma;
  bool? _notifEmail;
  bool? _notifForo;
  bool? _notifMentoria;
  bool _isSaving = false;

  void _initFromProfile(Profile profile) {
    _notifReforma ??= profile.notifAlertsReforma;
    _notifEmail ??= profile.notifEmailResumen;
    _notifForo ??= profile.notifForo;
    _notifMentoria ??= profile.notifMentoria;
  }

  Future<void> _savePreferences(Profile profile) async {
    setState(() => _isSaving = true);
    try {
      final dbService = ref.read(profileUpdateProvider);
      await dbService.updateNotificationPreferences(
        userId: profile.id,
        notifAlertsReforma: _notifReforma ?? profile.notifAlertsReforma,
        notifEmailResumen: _notifEmail ?? profile.notifEmailResumen,
        notifForo: _notifForo ?? profile.notifForo,
        notifMentoria: _notifMentoria ?? profile.notifMentoria,
      );
      // Invalidar el perfil para que el provider lo recargue con los nuevos valores
      ref.invalidate(userProfileProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Preferencias guardadas correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _changePassword() async {
    final email = ref.read(currentUserProvider)?.email;
    if (email == null) return;

    final authService = ref.read(authServiceProvider);
    await authService.resetPassword(email);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Se envió un correo de recuperación a $email'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final currentUser = ref.watch(currentUserProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
      ),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('No se encontró el perfil'));
          }

          // Inicializar localmente una sola vez con los valores del perfil
          _initFromProfile(profile);

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // ── Notificaciones ────────────────────────────────────
              _buildSectionTitle(context, 'Notificaciones', Icons.notifications_outlined),
              const SizedBox(height: 8),
              _buildNotifCard(context, [
                _SwitchTileData(
                  title: 'Alertas de Reforma',
                  subtitle: 'Notificación push por nuevas actualizaciones legales',
                  value: _notifReforma ?? profile.notifAlertsReforma,
                  onChanged: (val) => setState(() => _notifReforma = val),
                ),
                _SwitchTileData(
                  title: 'Resumen Semanal',
                  subtitle: 'Recibe las alertas de reforma en tu correo cada semana',
                  value: _notifEmail ?? profile.notifEmailResumen,
                  onChanged: (val) => setState(() => _notifEmail = val),
                ),
                _SwitchTileData(
                  title: 'Actividad en Foro',
                  subtitle: 'Cuando alguien responde a tu hilo de discusión',
                  value: _notifForo ?? profile.notifForo,
                  onChanged: (val) => setState(() => _notifForo = val),
                ),
                _SwitchTileData(
                  title: 'Recordatorios de Mentoría',
                  subtitle: 'Push 1 hora antes del inicio de tu sesión',
                  value: _notifMentoria ?? profile.notifMentoria,
                  onChanged: (val) => setState(() => _notifMentoria = val),
                ),
              ]),

              const SizedBox(height: 16),

              // Botón de guardar notificaciones
              LawButton(
                label: 'Guardar Preferencias',
                isLoading: _isSaving,
                onPressed: () => _savePreferences(profile),
              ),

              const SizedBox(height: 32),

              // ── Cuenta y Seguridad ─────────────────────────────────
              _buildSectionTitle(context, 'Cuenta y Seguridad', Icons.security_outlined),
              const SizedBox(height: 8),
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
                      onTap: _changePassword,
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

              const SizedBox(height: 48),

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
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(width: 4, height: 18, decoration: BoxDecoration(color: colorScheme.primary, borderRadius: BorderRadius.circular(2))),
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

  Widget _buildNotifCard(BuildContext context, List<_SwitchTileData> items) {
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
              SwitchListTile(
                title: Text(item.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                subtitle: Text(item.subtitle, style: const TextStyle(fontSize: 11)),
                value: item.value,
                onChanged: item.onChanged,
                activeThumbColor: colorScheme.primary,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              ),
              if (i < items.length - 1)
                Divider(height: 1, indent: 16, color: colorScheme.outline.withValues(alpha: 0.08)),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context, profile) {
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
}

class _SwitchTileData {
  final String title;
  final String subtitle;
  final bool value;
  final void Function(bool) onChanged;

  const _SwitchTileData({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
}
