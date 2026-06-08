import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common_widgets.dart';
import '../../models/profile.dart';

class NotificationSettingsView extends ConsumerStatefulWidget {
  const NotificationSettingsView({super.key});

  @override
  ConsumerState<NotificationSettingsView> createState() => _NotificationSettingsViewState();
}

class _NotificationSettingsViewState extends ConsumerState<NotificationSettingsView> {
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
      ref.invalidate(userProfileProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Preferencias de notificación guardadas correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/profile');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones', style: TextStyle(fontWeight: FontWeight.bold)),
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

          _initFromProfile(profile);

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                children: [
                  const Text(
                    'Configura cómo deseas recibir tus avisos y resúmenes de reformas.',
                    style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.4),
                  ),
                  const SizedBox(height: 24),
                  
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colorScheme.outline.withValues(alpha: 0.08)),
                    ),
                    child: Column(
                      children: [
                        _buildSwitchTile(
                          title: 'Alertas de Reforma',
                          subtitle: 'Notificación push por nuevas actualizaciones legales',
                          value: _notifReforma ?? profile.notifAlertsReforma,
                          onChanged: (val) => setState(() => _notifReforma = val),
                        ),
                        Divider(height: 1, indent: 16, color: colorScheme.outline.withValues(alpha: 0.08)),
                        _buildSwitchTile(
                          title: 'Resumen Semanal',
                          subtitle: 'Recibe las alertas de reforma en tu correo cada semana',
                          value: _notifEmail ?? profile.notifEmailResumen,
                          onChanged: (val) => setState(() => _notifEmail = val),
                        ),
                        Divider(height: 1, indent: 16, color: colorScheme.outline.withValues(alpha: 0.08)),
                        _buildSwitchTile(
                          title: 'Actividad en Foro',
                          subtitle: 'Cuando alguien responde a tu hilo de discusión',
                          value: _notifForo ?? profile.notifForo,
                          onChanged: (val) => setState(() => _notifForo = val),
                        ),
                        Divider(height: 1, indent: 16, color: colorScheme.outline.withValues(alpha: 0.08)),
                        _buildSwitchTile(
                          title: 'Recordatorios de Mentoría',
                          subtitle: 'Push 1 hora antes del inicio de tu sesión',
                          value: _notifMentoria ?? profile.notifMentoria,
                          onChanged: (val) => setState(() => _notifMentoria = val),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  LawButton(
                    label: 'Guardar Preferencias',
                    isLoading: _isSaving,
                    onPressed: () => _savePreferences(profile),
                  ),
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

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required void Function(bool) onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
      value: value,
      onChanged: onChanged,
      activeThumbColor: colorScheme.primary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
