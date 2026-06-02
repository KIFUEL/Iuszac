import 'package:flutter/material.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _notifReforma = true;
  bool _notifEmail = true;
  bool _notifForo = true;
  bool _notifMentoria = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSectionTitle('Notificaciones'),
          SwitchListTile(
            title:
                const Text('Alertas de Reforma', style: TextStyle(fontSize: 15)),
            subtitle: const Text('Push por nuevas actualizaciones legales',
                style: TextStyle(fontSize: 12)),
            value: _notifReforma,
            onChanged: (val) => setState(() => _notifReforma = val),
          ),
          SwitchListTile(
            title:
                const Text('Resumen Semanal', style: TextStyle(fontSize: 15)),
            subtitle: const Text('Alertas de reforma a tu correo',
                style: TextStyle(fontSize: 12)),
            value: _notifEmail,
            onChanged: (val) => setState(() => _notifEmail = val),
          ),
          SwitchListTile(
            title:
                const Text('Actividad en Foro', style: TextStyle(fontSize: 15)),
            subtitle: const Text('Cuando alguien responde a tu hilo',
                style: TextStyle(fontSize: 12)),
            value: _notifForo,
            onChanged: (val) => setState(() => _notifForo = val),
          ),
          SwitchListTile(
            title: const Text('Recordatorios de Mentoría',
                style: TextStyle(fontSize: 15)),
            subtitle: const Text('Push 1 hora antes de la sesión',
                style: TextStyle(fontSize: 12)),
            value: _notifMentoria,
            onChanged: (val) => setState(() => _notifMentoria = val),
          ),

          const SizedBox(height: 32),
          _buildSectionTitle('Cuenta y Seguridad'),
          ListTile(
            title: const Text('Cambiar Contraseña'),
            leading: const Icon(Icons.password_outlined),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Correo Electrónico'),
            subtitle: const Text('usuario@ejemplo.com'),
            leading: const Icon(Icons.email_outlined),
            trailing: const Icon(Icons.edit_outlined, size: 18),
            onTap: () {},
          ),

          const SizedBox(height: 48),
          const Divider(),
          const SizedBox(height: 16),

          TextButton.icon(
            onPressed: () {
              // Confirmación de eliminación
            },
            icon: Icon(Icons.delete_outline, color: colorScheme.error),
            label: Text(
              'Eliminar mi cuenta definitivamente',
              style: TextStyle(
                  color: colorScheme.error, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Esta acción es irreversible. Se borrarán todos tus marcadores y aportes.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8, top: 16),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}
