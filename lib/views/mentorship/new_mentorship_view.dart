import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/database_provider.dart';
import '../../widgets/common_widgets.dart';

class NewMentorshipView extends ConsumerStatefulWidget {
  const NewMentorshipView({super.key});

  @override
  ConsumerState<NewMentorshipView> createState() => _NewMentorshipViewState();
}

class _NewMentorshipViewState extends ConsumerState<NewMentorshipView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController(text: '0');
  final _slotsController = TextEditingController(text: '10');
  DateTime? _selectedExpiryDate;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _titleController.dispose();
    _specialtyController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _slotsController.dispose();
    super.dispose();
  }

  Future<void> _selectExpiryDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      helpText: '¿Hasta cuándo es válida esta mentoría?',
    );

    if (picked != null) {
      setState(() => _selectedExpiryDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedExpiryDate == null) {
      setState(() => _errorMessage = 'Por favor selecciona una fecha de vigencia');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dbService = ref.read(databaseServiceProvider);
      await dbService.createMentorshipSession(
        title: _titleController.text.trim(),
        specialty: _specialtyController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text),
        availableSlots: int.parse(_slotsController.text),
        expiresAt: _selectedExpiryDate,
      );

      ref.invalidate(mentorshipSessionsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sesión de mentoría creada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/mentorship');
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
        title: const Text('Ofrecer Mentoría'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/mentorship'),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Comparte tu experiencia',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Crea una sesión de mentoría para ayudar a otros miembros de la comunidad legal.',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  
                  LawTextField(
                    label: 'Título de la Sesión',
                    icon: Icons.school_outlined,
                    controller: _titleController,
                    validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),

                  LawTextField(
                    label: 'Especialidad (ej: Derecho Civil)',
                    icon: Icons.category_outlined,
                    controller: _specialtyController,
                    validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),

                  // Selector de Fecha de Vigencia
                  InkWell(
                    onTap: _selectExpiryDate,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.event_available, color: colorScheme.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _selectedExpiryDate == null 
                                  ? 'Fecha límite de la mentoría' 
                                  : 'Válido hasta: ${DateFormat('dd/MM/yyyy').format(_selectedExpiryDate!)}',
                              style: TextStyle(
                                color: _selectedExpiryDate == null ? Colors.grey.shade700 : Colors.black,
                              ),
                            ),
                          ),
                          const Icon(Icons.calendar_month, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: LawTextField(
                          label: 'Precio (MXN)',
                          icon: Icons.attach_money,
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Requerido';
                            if (double.tryParse(value) == null) return 'Número inválido';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: LawTextField(
                          label: 'Cupos',
                          icon: Icons.group_outlined,
                          controller: _slotsController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Requerido';
                            if (int.tryParse(value) == null) return 'Número inválido';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: 'Descripción de la sesión',
                      prefixIcon: const Icon(Icons.description_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: colorScheme.surface,
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 24),

                  if (_errorMessage != null) ...[
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: colorScheme.error, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                  ],

                  LawButton(
                    label: 'Publicar Mentoría',
                    isLoading: _isLoading,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
