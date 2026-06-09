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
  final List<String> _selectedDays = [];
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
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
      _selectedExpiryDate = session.expiresAt;

      if (session.schedule != null) {
        final days = session.schedule!['days'] as List<dynamic>?;
        if (days != null) {
          _selectedDays.clear();
          _selectedDays.addAll(days.map((d) => d.toString()));
        }
        
        final startTimeStr = session.schedule!['startTime'] as String?;
        if (startTimeStr != null) {
          final parts = startTimeStr.split(':');
          if (parts.length == 2) {
            _startTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
          }
        }
        
        final endTimeStr = session.schedule!['endTime'] as String?;
        if (endTimeStr != null) {
          final parts = endTimeStr.split(':');
          if (parts.length == 2) {
            _endTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
          }
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar sesión: $e';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectStartTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _startTime ?? const TimeOfDay(hour: 16, minute: 0),
      helpText: 'Hora de inicio de la sesión',
    );
    if (pickedTime != null) {
      setState(() {
        _startTime = pickedTime;
        _endTime ??= TimeOfDay(hour: (pickedTime.hour + 2) % 24, minute: pickedTime.minute);
      });
    }
  }

  Future<void> _selectEndTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _endTime ?? const TimeOfDay(hour: 18, minute: 0),
      helpText: 'Hora de fin de la sesión',
    );
    if (pickedTime != null) {
      setState(() => _endTime = pickedTime);
    }
  }

  Future<void> _selectExpiryDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedExpiryDate ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      helpText: '¿Hasta cuándo está disponible esta oferta?',
    );

    if (picked != null) {
      setState(() => _selectedExpiryDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDays.isEmpty) {
      setState(() => _errorMessage = 'Por favor selecciona al menos un día para el horario');
      return;
    }
    if (_startTime == null || _endTime == null) {
      setState(() => _errorMessage = 'Por favor define la hora de inicio y fin del horario');
      return;
    }
    if (_selectedExpiryDate == null) {
      setState(() => _errorMessage = 'Por favor selecciona una fecha límite de disponibilidad');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final scheduleMap = {
      'days': _selectedDays,
      'startTime': '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}',
      'endTime': '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}',
    };

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
          schedule: scheduleMap,
          expiresAt: _selectedExpiryDate,
        );
      } else {
        await dbService.createMentorshipSession(
          title: _titleController.text.trim(),
          specialty: _specialtyController.text.trim(),
          description: _descriptionController.text.trim(),
          price: double.parse(_priceController.text),
          availableSlots: int.parse(_slotsController.text),
          schedule: scheduleMap,
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

                        // Días de la semana
                        Text(
                          'Días de la semana para la mentoría',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            {'full': 'Lunes', 'short': 'Lun'},
                            {'full': 'Martes', 'short': 'Mar'},
                            {'full': 'Miércoles', 'short': 'Mié'},
                            {'full': 'Jueves', 'short': 'Jue'},
                            {'full': 'Viernes', 'short': 'Vie'},
                            {'full': 'Sábado', 'short': 'Sáb'},
                            {'full': 'Domingo', 'short': 'Dom'},
                          ].map((day) {
                            final full = day['full']!;
                            final short = day['short']!;
                            final isSelected = _selectedDays.contains(full);
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (isSelected) {
                                        _selectedDays.remove(full);
                                      } else {
                                        _selectedDays.add(full);
                                      }
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    height: 42,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: isSelected 
                                          ? colorScheme.primary 
                                          : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isSelected 
                                            ? colorScheme.primary 
                                            : colorScheme.outline.withValues(alpha: 0.2),
                                      ),
                                    ),
                                    child: Text(
                                      short,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),

                        // Horario de inicio y fin
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: _selectStartTime,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade400),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.access_time, color: colorScheme.primary),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _startTime == null
                                              ? 'Hora Inicio'
                                              : 'Inicio: ${_startTime!.format(context)}',
                                          style: TextStyle(
                                            color: _startTime == null ? Colors.grey.shade700 : colorScheme.onSurface,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: InkWell(
                                onTap: _selectEndTime,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade400),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.access_time_filled, color: colorScheme.primary),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _endTime == null
                                              ? 'Hora Fin'
                                              : 'Fin: ${_endTime!.format(context)}',
                                          style: TextStyle(
                                            color: _endTime == null ? Colors.grey.shade700 : colorScheme.onSurface,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
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
                            labelStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6)),
                            prefixIcon: Icon(Icons.description_outlined, color: colorScheme.primary),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.25)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
                            ),
                            filled: true,
                            fillColor: Theme.of(context).inputDecorationTheme.fillColor,
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
