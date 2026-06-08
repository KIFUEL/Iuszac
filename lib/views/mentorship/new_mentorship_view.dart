import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/database_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common_widgets.dart';

class NewMentorshipView extends ConsumerStatefulWidget {
  final String? sessionId;

  const NewMentorshipView({super.key, this.sessionId});

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
  DateTime? _selectedSessionDate;
  DateTime? _selectedExpiryDate;

  bool _isLoading = false;
  bool _isInit = true;
  String? _errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit && widget.sessionId != null) {
      _loadSessionData();
      _isInit = false;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _specialtyController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _slotsController.dispose();
    super.dispose();
  }

  Future<void> _loadSessionData() async {
    setState(() => _isLoading = true);
    try {
      final dbService = ref.read(databaseServiceProvider);
      final sessions = await dbService.getMentorshipSessions();
      final session = sessions.firstWhere((s) => s.id == widget.sessionId);
      
      _titleController.text = session.title;
      _specialtyController.text = session.specialty;
      _descriptionController.text = session.description ?? '';
      _priceController.text = session.price.toStringAsFixed(0);
      _slotsController.text = session.availableSlots.toString();
      _selectedSessionDate = session.sessionDate;
      _selectedExpiryDate = session.expiresAt;
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar sesión: $e';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectSessionDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedSessionDate ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Fecha de impartición de la sesión',
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedSessionDate != null
            ? TimeOfDay.fromDateTime(_selectedSessionDate!)
            : const TimeOfDay(hour: 10, minute: 0),
        helpText: 'Hora de la sesión',
      );

      if (pickedTime != null) {
        setState(() {
          _selectedSessionDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          // By default, make expiresAt equal to sessionDate if not set
          _selectedExpiryDate ??= _selectedSessionDate;
        });
      }
    }
  }

  Future<void> _selectExpiryDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedExpiryDate ?? now.add(const Duration(days: 7)),
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
    if (_selectedSessionDate == null) {
      setState(() => _errorMessage = 'Por favor selecciona la fecha de la sesión');
      return;
    }
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
      
      if (widget.sessionId != null) {
        await dbService.updateMentorshipSession(
          sessionId: widget.sessionId!,
          title: _titleController.text.trim(),
          specialty: _specialtyController.text.trim(),
          description: _descriptionController.text.trim(),
          price: double.parse(_priceController.text),
          availableSlots: int.parse(_slotsController.text),
          sessionDate: _selectedSessionDate!,
          expiresAt: _selectedExpiryDate,
        );
      } else {
        await dbService.createMentorshipSession(
          title: _titleController.text.trim(),
          specialty: _specialtyController.text.trim(),
          description: _descriptionController.text.trim(),
          price: double.parse(_priceController.text),
          availableSlots: int.parse(_slotsController.text),
          sessionDate: _selectedSessionDate!,
          expiresAt: _selectedExpiryDate,
        );
      }

      ref.invalidate(mentorshipSessionsProvider);
      
      final currentUserId = ref.read(currentUserProvider)?.id;
      if (currentUserId != null) {
        ref.invalidate(myMentorshipSessionsProvider(currentUserId));
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.sessionId != null
                ? 'Sesión de mentoría actualizada exitosamente'
                : 'Sesión de mentoría creada exitosamente'),
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
    final profile = ref.watch(userProfileProvider).value;
    final hasWhatsapp = profile?.phoneWhatsapp != null && profile!.phoneWhatsapp!.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sessionId != null ? 'Editar Mentoría' : 'Ofrecer Mentoría'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/mentorship'),
        ),
      ),
      body: _isLoading && widget.sessionId != null
          ? const Center(child: CircularProgressIndicator())
          : Center(
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
                          widget.sessionId != null ? 'Edita los detalles de tu sesión' : 'Comparte tu experiencia',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.sessionId != null
                              ? 'Mantén informada a tu audiencia sobre cambios en la fecha, temario o costos.'
                              : 'Crea una sesión de mentoría para ayudar a otros miembros de la comunidad legal.',
                          style: const TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // WhatsApp Warning Banner
                        if (!hasWhatsapp)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.amber.shade700.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.warning_amber_rounded, color: Colors.amber.shade700),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: InkWell(
                                    onTap: () => context.go('/profile'),
                                    child: RichText(
                                      text: TextSpan(
                                        style: const TextStyle(fontSize: 12, color: Colors.black87),
                                        children: [
                                          const TextSpan(text: 'No tienes registrado tu número de WhatsApp. '),
                                          TextSpan(
                                            text: 'Configurar perfil',
                                            style: TextStyle(
                                              color: colorScheme.primary,
                                              fontWeight: FontWeight.bold,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        LawTextField(
                          label: 'Título de la Sesión',
                          icon: Icons.school_outlined,
                          controller: _titleController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return 'Requerido';
                            if (value.trim().length < 5) return 'Mínimo 5 caracteres';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        LawTextField(
                          label: 'Especialidad (ej: Derecho Civil)',
                          icon: Icons.category_outlined,
                          controller: _specialtyController,
                          validator: (value) => value == null || value.trim().isEmpty ? 'Requerido' : null,
                        ),
                        const SizedBox(height: 16),

                        // Selector de Fecha de la Sesión
                        InkWell(
                          onTap: _selectSessionDate,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today_outlined, color: colorScheme.primary),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _selectedSessionDate == null 
                                        ? 'Fecha y Hora de la sesión' 
                                        : 'Fecha de sesión: ${DateFormat('dd/MM/yyyy HH:mm').format(_selectedSessionDate!)}',
                                    style: TextStyle(
                                      color: _selectedSessionDate == null ? Colors.grey.shade700 : colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.access_time_outlined, color: Colors.grey),
                              ],
                            ),
                          ),
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
                                      color: _selectedExpiryDate == null ? Colors.grey.shade700 : colorScheme.onSurface,
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
                                  final price = double.tryParse(value);
                                  if (price == null || price < 0) return 'Precio inválido';
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
                                  final slots = int.tryParse(value);
                                  if (slots == null || slots < 1) return 'Cupos mínimos 1';
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
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return 'Requerido';
                            if (value.trim().length < 20) return 'Mínimo 20 caracteres';
                            return null;
                          },
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
                          label: widget.sessionId != null ? 'Guardar Cambios' : 'Publicar Mentoría',
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
