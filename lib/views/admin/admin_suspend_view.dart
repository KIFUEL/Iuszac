import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/database_provider.dart';
import '../../models/profile.dart';
import '../../widgets/common_widgets.dart';

class AdminSuspendView extends ConsumerStatefulWidget {
  final String userId;

  const AdminSuspendView({super.key, required this.userId});

  @override
  ConsumerState<AdminSuspendView> createState() => _AdminSuspendViewState();
}

class _AdminSuspendViewState extends ConsumerState<AdminSuspendView> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  
  int _selectedDurationDays = 7; // default 7 days
  DateTime _suspendedUntil = DateTime.now().add(const Duration(days: 7));
  bool _isCustomDate = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _calculateSuspensionDate();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _calculateSuspensionDate() {
    if (!_isCustomDate) {
      setState(() {
        _suspendedUntil = DateTime.now().add(Duration(days: _selectedDurationDays));
      });
    }
  }

  Future<void> _selectCustomDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _suspendedUntil.isAfter(DateTime.now()) ? _suspendedUntil : DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)), // max 5 years
    );
    if (picked != null) {
      setState(() {
        _suspendedUntil = DateTime(picked.year, picked.month, picked.day, 23, 59, 59);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(allUsersProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Suspender Usuario',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: usersAsync.when(
        data: (users) {
          final user = users.firstWhere(
            (u) => u.id == widget.userId,
            orElse: () => throw Exception('Usuario no encontrado'),
          );

          final now = DateTime.now();
          final isCurrentlySuspended = user.isSuspended && (user.suspendedUntil == null || user.suspendedUntil!.isAfter(now));

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User details summary card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detalles del Usuario',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${user.fullName} ${user.lastName ?? ''}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rol: ${user.userType.toUpperCase()} · ${user.label ?? 'Sin etiqueta'}',
                          style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                        ),
                        if (isCurrentlySuspended) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: colorScheme.error, size: 16),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Actualmente suspendido hasta el ${DateFormat('dd/MM/yyyy HH:mm').format(user.suspendedUntil!)}',
                                  style: TextStyle(
                                    color: colorScheme.error,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Duration selector
                  Text(
                    'Duración de la suspensión',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: colorScheme.primary),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildDurationChip(1, '1 día'),
                      _buildDurationChip(3, '3 días'),
                      _buildDurationChip(7, '7 días'),
                      _buildDurationChip(15, '15 días'),
                      _buildDurationChip(30, '30 días'),
                      ChoiceChip(
                        label: const Text('Personalizado'),
                        selected: _isCustomDate,
                        onSelected: (selected) {
                          setState(() {
                            _isCustomDate = selected;
                            if (selected) {
                              _suspendedUntil = DateTime.now().add(const Duration(days: 1));
                            } else {
                              _calculateSuspensionDate();
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Display suspension end date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Fecha de finalización:',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('dd \'de\' MMMM \'de\' yyyy, HH:mm \'hrs\'', 'es').format(_suspendedUntil),
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: colorScheme.secondary),
                          ),
                        ],
                      ),
                      if (_isCustomDate)
                        OutlinedButton.icon(
                          onPressed: () => _selectCustomDate(context),
                          icon: const Icon(Icons.calendar_today, size: 16),
                          label: const Text('Elegir'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Suspension reason field
                  Text(
                    'Motivo de la suspensión',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: colorScheme.primary),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _reasonController,
                    maxLines: 4,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Por favor ingresa un motivo';
                      }
                      if (val.trim().length < 10) {
                        return 'El motivo debe tener al menos 10 caracteres';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Explica el motivo (ej. publicación de contenido ofensivo en el foro). Este motivo será visible para el usuario.',
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Submit and lift suspension buttons
                  Row(
                    children: [
                      Expanded(
                        child: LawButton(
                          label: 'Aplicar Suspensión',
                          isLoading: _isLoading,
                          backgroundColor: colorScheme.error,
                          onPressed: () => _confirmApplySuspension(context, user),
                        ),
                      ),
                      if (isCurrentlySuspended) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: LawButton(
                            label: 'Levantar Suspensión',
                            isLoading: _isLoading,
                            isPrimary: false,
                            backgroundColor: colorScheme.outline,
                            onPressed: () => _liftSuspension(context, user),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text('Error: $err', style: const TextStyle(color: Colors.red)),
          ),
        ),
      ),
    );
  }

  Widget _buildDurationChip(int days, String label) {
    return ChoiceChip(
      label: Text(label),
      selected: !_isCustomDate && _selectedDurationDays == days,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _isCustomDate = false;
            _selectedDurationDays = days;
            _calculateSuspensionDate();
          });
        }
      },
    );
  }

  void _confirmApplySuspension(BuildContext context, Profile user) {
    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Aplicar suspensión?'),
        content: Text(
          'El usuario ${user.fullName} no podrá acceder a su cuenta hasta la fecha seleccionada. Se guardará la sesión y el motivo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              _applySuspension(user);
            },
            child: const Text(
              'Suspender',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _applySuspension(Profile user) async {
    setState(() => _isLoading = true);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    try {
      final dbService = ref.read(databaseServiceProvider);
      await dbService.suspendUser(
        user.id,
        _suspendedUntil,
        _reasonController.text.trim(),
      );

      // Invalidate profiles list
      ref.invalidate(allUsersProvider);

      messenger.showSnackBar(
        SnackBar(
          content: Text('Usuario ${user.fullName} suspendido correctamente.'),
          backgroundColor: Colors.green,
        ),
      );
      router.pop(); // return to user management
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Error al suspender: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _liftSuspension(BuildContext context, Profile user) async {
    setState(() => _isLoading = true);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    try {
      final dbService = ref.read(databaseServiceProvider);
      await dbService.liftSuspension(user.id);
      ref.invalidate(allUsersProvider);

      messenger.showSnackBar(
        SnackBar(
          content: Text('Suspensión de ${user.fullName} levantada correctamente.'),
          backgroundColor: Colors.green,
        ),
      );
      router.pop();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Error al levantar suspensión: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
