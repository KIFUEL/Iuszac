import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common_widgets.dart';

class RegisterView extends ConsumerStatefulWidget {
  const RegisterView({super.key});

  @override
  ConsumerState<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends ConsumerState<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _institutionController = TextEditingController();

  String? _selectedRole;
  String? _selectedSemester;
  bool _acceptTerms = false;
  bool _subscribeAlerts = true;

  bool _isLoading = false;
  String? _errorMessage;

  final List<String> _roles = [
    'Estudiante',
    'Abogado postulante',
    'Docente',
    'Investigador'
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
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _institutionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      setState(() => _errorMessage = 'Debes aceptar los términos y condiciones');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      await authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _nameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        role: _selectedRole,
        institution: _institutionController.text.trim(),
        semesterDegree: _selectedSemester,
        subscribeAlerts: _subscribeAlerts,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Registro exitoso. Revisa tu correo de confirmación o inicia sesión.'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/login');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception:', '').trim();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro IusZac'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/splash'),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Crea tu cuenta profesional',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Sección 1: Datos Personales
                  _buildSectionTitle('Datos Personales'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: LawTextField(
                          label: 'Nombre',
                          icon: Icons.person_outline,
                          controller: _nameController,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Requerido'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: LawTextField(
                          label: 'Apellido',
                          icon: Icons.person_outline,
                          controller: _lastNameController,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Requerido'
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LawTextField(
                    label: 'Correo Electrónico',
                    icon: Icons.email_outlined,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Requerido';
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value.trim())) {
                        return 'Email inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  LawTextField(
                    label: 'Contraseña',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    controller: _passwordController,
                    validator: (value) => value == null || value.length < 8
                        ? 'Mínimo 8 caracteres'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  LawTextField(
                    label: 'Confirmar Contraseña',
                    icon: Icons.lock_clock_outlined,
                    isPassword: true,
                    controller: _confirmPasswordController,
                    validator: (value) => value != _passwordController.text
                        ? 'No coinciden'
                        : null,
                  ),
                  const SizedBox(height: 32),

                  // Sección 2: Contexto Académico/Profesional
                  _buildSectionTitle('Contexto Profesional'),
                  const SizedBox(height: 16),
                  LawDropdown<String>(
                    label: 'Rol',
                    icon: Icons.work_outline,
                    items: _roles
                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                    value: _selectedRole,
                    onChanged: (val) => setState(() => _selectedRole = val),
                    validator: (val) => val == null ? 'Selecciona un rol' : null,
                  ),
                  const SizedBox(height: 16),
                  LawTextField(
                    label: 'Institución (Opcional)',
                    icon: Icons.school_outlined,
                    controller: _institutionController,
                  ),
                  const SizedBox(height: 16),
                  LawDropdown<String>(
                    label: 'Semestre / Grado (Opcional)',
                    icon: Icons.grade_outlined,
                    items: _semesters
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    value: _selectedSemester,
                    onChanged: (val) => setState(() => _selectedSemester = val),
                  ),
                  const SizedBox(height: 24),

                  // Checkboxes
                  CheckboxListTile(
                    title: const Text('Acepto los términos y condiciones'),
                    value: _acceptTerms,
                    onChanged: (val) => setState(() => _acceptTerms = val ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  CheckboxListTile(
                    title: const Text('Recibir alertas de reforma por correo'),
                    value: _subscribeAlerts,
                    onChanged: (val) =>
                        setState(() => _subscribeAlerts = val ?? true),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: colorScheme.error, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],

                  const SizedBox(height: 32),
                  LawButton(
                    label: 'Crear cuenta',
                    isLoading: _isLoading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('¿Ya tienes cuenta? '),
                      GestureDetector(
                        onTap: () => context.go('/login'),
                        child: Text(
                          'Inicia sesión',
                          style: TextStyle(
                            color: colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            color: Colors.grey,
          ),
        ),
        const Divider(),
      ],
    );
  }
}
