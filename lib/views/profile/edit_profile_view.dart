import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/database_provider.dart';
import '../../widgets/common_widgets.dart';

class EditProfileView extends ConsumerStatefulWidget {
  const EditProfileView({super.key});

  @override
  ConsumerState<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends ConsumerState<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _bioCtrl;
  late TextEditingController _institutionCtrl;
  late TextEditingController _phoneCtrl;
  String? _selectedRole;
  String? _selectedSemester;
  bool _isSaving = false;
  bool _isInitialized = false;

  final List<String> _roles = [
    'Estudiante',
    'Docente',
    'Postulante',
    'Investigador',
    'Practicante'
  ];

  final List<String> _semesters = [
    '1ro semestre',
    '2do semestre',
    '3ro semestre',
    '4to semestre',
    '5to semestre',
    '6to semestre',
    '7mo semestre',
    '8vo semestre',
    '9no semestre',
    '10mo semestre',
    'Titulado',
    'Posgrado'
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _lastNameCtrl.dispose();
    _bioCtrl.dispose();
    _institutionCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _initFields(profile) {
    if (_isInitialized) return;
    _nameCtrl = TextEditingController(text: profile.fullName);
    _lastNameCtrl = TextEditingController(text: profile.lastName ?? '');
    _bioCtrl = TextEditingController(text: profile.bio ?? '');
    _institutionCtrl = TextEditingController(text: profile.institution ?? '');
    _phoneCtrl = TextEditingController(text: profile.phoneWhatsapp ?? '');

    // Inicializar dropdowns buscando concordancia en las listas
    if (profile.label != null && _roles.contains(profile.label)) {
      _selectedRole = profile.label;
    }
    if (profile.semesterDegree != null && _semesters.contains(profile.semesterDegree)) {
      _selectedSemester = profile.semesterDegree;
    }

    _isInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil', style: TextStyle(fontWeight: FontWeight.bold)),
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

          _initFields(profile);

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                  children: [
                    // Avatar/Initials representation
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: colorScheme.primary.withValues(alpha: 0.1), width: 4),
                        ),
                        child: CircleAvatar(
                          radius: 46,
                          backgroundColor: colorScheme.primaryContainer,
                          child: Text(
                            (profile.fullName.isNotEmpty ? profile.fullName[0] : 'U').toUpperCase(),
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Campo de Nombre
                    LawTextField(
                      label: 'Nombre(s)',
                      icon: Icons.person_outline,
                      controller: _nameCtrl,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor ingresa tu nombre';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Campo de Apellidos
                    LawTextField(
                      label: 'Apellidos',
                      icon: Icons.badge_outlined,
                      controller: _lastNameCtrl,
                    ),
                    const SizedBox(height: 16),

                    // Campo de Rol
                    LawDropdown<String>(
                      label: 'Rol / Ocupación',
                      icon: Icons.work_outline,
                      items: _roles
                          .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                          .toList(),
                      value: _selectedRole,
                      onChanged: (val) => setState(() => _selectedRole = val),
                      validator: (value) => value == null ? 'Por favor selecciona un rol' : null,
                    ),
                    const SizedBox(height: 16),

                    // Campo de Institución
                    LawTextField(
                      label: 'Institución',
                      icon: Icons.school_outlined,
                      controller: _institutionCtrl,
                    ),
                    const SizedBox(height: 16),

                    // Campo de Semestre / Grado
                    LawDropdown<String>(
                      label: 'Semestre / Grado',
                      icon: Icons.grade_outlined,
                      items: _semesters
                          .map((sem) => DropdownMenuItem(value: sem, child: Text(sem)))
                          .toList(),
                      value: _selectedSemester,
                      onChanged: (val) => setState(() => _selectedSemester = val),
                    ),
                    const SizedBox(height: 16),

                    // Campo de Celular WhatsApp
                    LawTextField(
                      label: 'Celular WhatsApp',
                      icon: Icons.phone_android,
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),

                    // Campo de Biografía breve
                    TextFormField(
                      controller: _bioCtrl,
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
                    const SizedBox(height: 28),

                    LawButton(
                      label: 'Guardar Cambios',
                      isLoading: _isSaving,
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;
                        setState(() => _isSaving = true);
                        final messenger = ScaffoldMessenger.of(context);
                        final router = GoRouter.of(context);
                        try {
                          final dbService = ref.read(profileUpdateProvider);
                          await dbService.updateProfile(
                            userId: profile.id,
                            fullName: _nameCtrl.text.trim(),
                            lastName: _lastNameCtrl.text.trim(),
                            bio: _bioCtrl.text.trim(),
                            institution: _institutionCtrl.text.trim(),
                            semesterDegree: _selectedSemester,
                            phoneWhatsapp: _phoneCtrl.text.trim(),
                            label: _selectedRole,
                          );
                          ref.invalidate(userProfileProvider);
                          ref.invalidate(profileStatsProvider);
                          if (mounted) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Perfil actualizado correctamente'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            router.go('/profile');
                          }
                        } catch (e) {
                          if (mounted) {
                            messenger.showSnackBar(
                              SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                            );
                          }
                        } finally {
                          if (mounted) setState(() => _isSaving = false);
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
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
