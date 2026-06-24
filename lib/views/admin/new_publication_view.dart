import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import '../../providers/database_provider.dart';
import '../../widgets/common_widgets.dart';
import '../../models/publication.dart';
import '../../services/database_service.dart';

class NewPublicationView extends ConsumerStatefulWidget {
  final Publication? existingUpdate;
  const NewPublicationView({super.key, this.existingUpdate});

  @override
  ConsumerState<NewPublicationView> createState() => _NewPublicationViewState();
}

class _NewPublicationViewState extends ConsumerState<NewPublicationView> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers basicos
  final _titleController = TextEditingController();
  final _oldContentController = TextEditingController();
  final _newContentController = TextEditingController();
  final _sourceNameController = TextEditingController();
  final _sourceUrlController = TextEditingController();
  final _eventLocationController = TextEditingController();
  final _eventLinkController = TextEditingController();
  final _eventCostController = TextEditingController();
  final _tagsController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _issuingBodyController = TextEditingController();
  final _transitoryArticlesController = TextEditingController();

  late quill.QuillController _quillController;

  String _contentType = 'reforma'; // 'reforma', 'noticia', 'evento', 'convocatoria'
  String _status = 'published'; // 'draft', 'published', 'scheduled'
  String _category = 'Reforma';

  String _selectedIssuingBody = 'H. Congreso de la Unión';
  bool _isCustomIssuingBody = false;

  DateTime? _eventStart;
  DateTime? _eventEnd;
  DateTime? _deadline;
  DateTime? _scheduledDate;
  DateTime? _entryIntoForceDate;
  
  bool _isFeatured = false;
  DateTime? _featuredUntil;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingUpdate != null) {
      final eu = widget.existingUpdate!;
      _titleController.text = eu.title;
      _contentType = eu.contentType;
      _status = eu.status;
      _category = eu.category;
      _oldContentController.text = eu.oldContent ?? '';
      _newContentController.text = eu.newContent ?? '';
      _sourceNameController.text = eu.sourceName ?? '';
      _sourceUrlController.text = eu.sourceUrl ?? '';
      _eventLocationController.text = eu.eventLocation ?? '';
      _eventLinkController.text = eu.eventLink ?? '';
      _eventCostController.text = eu.eventCost ?? '';
      _tagsController.text = eu.tags.join(', ');
      _imageUrlController.text = eu.imageUrl ?? '';
      _issuingBodyController.text = eu.issuingBody ?? '';
      _transitoryArticlesController.text = eu.transitoryArticles ?? '';
      _eventStart = eu.eventStart;
      _eventEnd = eu.eventEnd;
      _deadline = eu.deadline != null ? DateTime.tryParse(eu.deadline!) : null;
      _scheduledDate = eu.publishedAt;
      _entryIntoForceDate = eu.entryIntoForce;
      _isFeatured = eu.isFeatured;
      _featuredUntil = eu.featuredUntil;
      
      try {
        final decoded = jsonDecode(eu.content);
        if (decoded is List) {
          _quillController = quill.QuillController(
            document: quill.Document.fromJson(decoded),
            selection: const TextSelection.collapsed(offset: 0),
          );
        } else {
          _quillController = quill.QuillController.basic();
        }
      } catch (_) {
        _quillController = quill.QuillController.basic();
      }
    } else {
      _quillController = quill.QuillController.basic();
      _issuingBodyController.text = _selectedIssuingBody;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _oldContentController.dispose();
    _newContentController.dispose();
    _sourceNameController.dispose();
    _sourceUrlController.dispose();
    _eventLocationController.dispose();
    _eventLinkController.dispose();
    _eventCostController.dispose();
    _tagsController.dispose();
    _imageUrlController.dispose();
    _issuingBodyController.dispose();
    _transitoryArticlesController.dispose();
    _quillController.dispose();
    super.dispose();
  }


  Future<void> _pickDateTime(BuildContext context, {required bool isStart, bool isDeadline = false, bool isScheduled = false, bool isEntryIntoForce = false}) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (date == null) return;
    if (!context.mounted) return;
    
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    final result = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      if (isScheduled) {
        _scheduledDate = result;
      } else if (isEntryIntoForce) {
        _entryIntoForceDate = result;
      } else if (isDeadline) {
        _deadline = result;
      } else if (isStart) {
        _eventStart = result;
      } else {
        _eventEnd = result;
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_status == 'scheduled' && _scheduledDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona una fecha y hora para programar la publicación'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_isFeatured && _featuredUntil == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona hasta cuándo destacar la publicación'), backgroundColor: Colors.red),
      );
      return;
    }

    // Obtener contenido de Quill como JSON string
    final contentJson = jsonEncode(_quillController.document.toDelta().toJson());

    setState(() => _isLoading = true);

    try {
      final dbService = ref.read(databaseServiceProvider);
      
      List<String> tags = _tagsController.text
          .split(',')
          .map((e) => e.replaceAll('#', '').trim())
          .where((e) => e.isNotEmpty)
          .toList();

      if (widget.existingUpdate != null) {
        await dbService.updatePublication(
          id: widget.existingUpdate!.id,
          title: _titleController.text.trim(),
          content: contentJson,
          category: _contentType == 'reforma' ? _category : (_contentType == 'noticia' ? 'Noticia' : (_contentType == 'evento' ? 'Evento' : 'Convocatoria')),
          status: _status,
          contentType: _contentType,
          tags: tags,
          imageUrl: _imageUrlController.text.isNotEmpty ? _imageUrlController.text.trim() : null,
          sourceName: _sourceNameController.text.isNotEmpty ? _sourceNameController.text.trim() : null,
          sourceUrl: _sourceUrlController.text.isNotEmpty ? _sourceUrlController.text.trim() : null,
          eventStart: _eventStart,
          eventEnd: _eventEnd,
          eventLocation: _eventLocationController.text.isNotEmpty ? _eventLocationController.text.trim() : null,
          eventLink: _eventLinkController.text.isNotEmpty ? _eventLinkController.text.trim() : null,
          eventCost: _eventCostController.text.isNotEmpty ? _eventCostController.text.trim() : null,
          deadline: _deadline?.toIso8601String(),
          publishedAt: _status == 'scheduled' ? _scheduledDate : (_status == 'published' ? DateTime.now() : null),
          oldContent: _contentType == 'reforma' && _oldContentController.text.isNotEmpty ? _oldContentController.text.trim() : null,
          newContent: _contentType == 'reforma' && _newContentController.text.isNotEmpty ? _newContentController.text.trim() : null,
          issuingBody: _contentType == 'reforma' && _issuingBodyController.text.isNotEmpty ? _issuingBodyController.text.trim() : null,
          entryIntoForce: _contentType == 'reforma' ? _entryIntoForceDate : null,
          transitoryArticles: _contentType == 'reforma' && _transitoryArticlesController.text.isNotEmpty ? _transitoryArticlesController.text.trim() : null,
          isFeatured: _isFeatured,
          featuredUntil: _featuredUntil,
        );
      } else {
        await dbService.createPublication(
          title: _titleController.text.trim(),
          content: contentJson,
          category: _contentType == 'reforma' ? _category : (_contentType == 'noticia' ? 'Noticia' : (_contentType == 'evento' ? 'Evento' : 'Convocatoria')),
          status: _status,
          contentType: _contentType,
          tags: tags,
          imageUrl: _imageUrlController.text.isNotEmpty ? _imageUrlController.text.trim() : null,
          sourceName: _sourceNameController.text.isNotEmpty ? _sourceNameController.text.trim() : null,
          sourceUrl: _sourceUrlController.text.isNotEmpty ? _sourceUrlController.text.trim() : null,
          eventStart: _eventStart,
          eventEnd: _eventEnd,
          eventLocation: _eventLocationController.text.isNotEmpty ? _eventLocationController.text.trim() : null,
          eventLink: _eventLinkController.text.isNotEmpty ? _eventLinkController.text.trim() : null,
          eventCost: _eventCostController.text.isNotEmpty ? _eventCostController.text.trim() : null,
          deadline: _deadline?.toIso8601String(),
          publishedAt: _status == 'scheduled' ? _scheduledDate : (_status == 'published' ? DateTime.now() : null),
          oldContent: _contentType == 'reforma' && _oldContentController.text.isNotEmpty ? _oldContentController.text.trim() : null,
          newContent: _contentType == 'reforma' && _newContentController.text.isNotEmpty ? _newContentController.text.trim() : null,
          issuingBody: _contentType == 'reforma' && _issuingBodyController.text.isNotEmpty ? _issuingBodyController.text.trim() : null,
          entryIntoForce: _contentType == 'reforma' ? _entryIntoForceDate : null,
          transitoryArticles: _contentType == 'reforma' && _transitoryArticlesController.text.isNotEmpty ? _transitoryArticlesController.text.trim() : null,
          isFeatured: _isFeatured,
          featuredUntil: _featuredUntil,
        );
      }

      ref.invalidate(publicationsProvider);
      ref.invalidate(myDraftsProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Guardado correctamente 🎉'), backgroundColor: Colors.green),
      );
      context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6)),
      prefixIcon: Icon(icon, size: 20, color: colorScheme.primary),
      filled: true,
      fillColor: Theme.of(context).inputDecorationTheme.fillColor,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.25)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingUpdate != null ? 'Editar Publicación' : 'Crear Publicación', style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Selector de Tipo y Estado
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _contentType,
                      decoration: _buildInputDecoration('Tipo de Contenido', Icons.article),
                      items: const [
                        DropdownMenuItem(value: 'reforma', child: Text('Reforma / Ley')),
                        DropdownMenuItem(value: 'noticia', child: Text('Noticia')),
                        DropdownMenuItem(value: 'evento', child: Text('Evento')),
                        DropdownMenuItem(value: 'convocatoria', child: Text('Convocatoria')),
                      ],
                      onChanged: (val) => setState(() {
                        _contentType = val!;
                        if (_contentType == 'reforma') {
                          _category = 'Reforma';
                        } else {
                          _category = 'Noticia';
                        }
                      }),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _status,
                      decoration: _buildInputDecoration('Estado', Icons.publish),
                      items: const [
                        DropdownMenuItem(value: 'published', child: Text('Publicar ahora')),
                        DropdownMenuItem(value: 'draft', child: Text('Borrador')),
                        DropdownMenuItem(value: 'scheduled', child: Text('Programar')),
                      ],
                      onChanged: (val) => setState(() {
                        _status = val!;
                        if (_status == 'scheduled' && _scheduledDate == null) {
                          _pickDateTime(context, isStart: false, isScheduled: true);
                        }
                      }),
                    ),
                  ),
                ],
              ),
              if (_status == 'scheduled') ...[
                const SizedBox(height: 16),
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  tileColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  leading: const Icon(Icons.schedule),
                  title: Text(_scheduledDate == null ? 'Seleccionar fecha y hora' : DateFormat('dd/MM/yyyy HH:mm').format(_scheduledDate!)),
                  trailing: const Icon(Icons.edit),
                  onTap: () => _pickDateTime(context, isStart: false, isScheduled: true),
                ),
              ],
              
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              // 2. Información Básica (Común)
              TextFormField(
                controller: _titleController,
                decoration: _buildInputDecoration('Título de la publicación', Icons.title),
                validator: (val) => val == null || val.isEmpty ? 'El título es obligatorio' : null,
              ),
              const SizedBox(height: 16),
              if (_contentType == 'reforma') ...[
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: _buildInputDecoration('Categoría', Icons.category),
                  items: const [
                    DropdownMenuItem(value: 'Reforma', child: Text('Reforma')),
                    DropdownMenuItem(value: 'Adición', child: Text('Adición')),
                    DropdownMenuItem(value: 'Derogación', child: Text('Derogación')),
                    DropdownMenuItem(value: 'Abrogación', child: Text('Abrogación')),
                    DropdownMenuItem(value: 'Corrección', child: Text('Corrección')),
                  ],
                  onChanged: (val) => setState(() => _category = val!),
                ),
                const SizedBox(height: 16),
              ],
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _tagsController,
                    decoration: _buildInputDecoration('Etiquetas (separadas por coma)', Icons.label),
                  ),
                  const SizedBox(height: 8),
                  ref.watch(popularTagsProvider).when(
                    data: (tags) => tags.isEmpty ? const SizedBox.shrink() : Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: tags.map((tag) => ActionChip(
                          label: Text('#$tag', style: const TextStyle(fontSize: 12)),
                          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          onPressed: () {
                            final current = _tagsController.text.trim();
                            if (current.isEmpty) {
                              _tagsController.text = tag;
                            } else {
                              final tagsList = current.split(',').map((e) => e.trim()).toList();
                              if (!tagsList.contains(tag)) {
                                _tagsController.text = '$current, $tag';
                              }
                            }
                          },
                        )).toList(),
                      ),
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: _buildInputDecoration('URL de Imagen de Portada (Opcional)', Icons.image),
              ),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _imageUrlController,
                builder: (context, value, child) {
                  final url = value.text.trim();
                  if (url.isEmpty || (!url.startsWith('http') && !url.startsWith('https'))) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        url,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                            borderRadius: BorderRadius.circular(12)
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image, color: Colors.grey, size: 40),
                              SizedBox(height: 8),
                              Text('No se pudo cargar la imagen', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 24),
              Text(
                _contentType == 'reforma' ? 'Resumen o Análisis de la Reforma (Opcional)' : 'Cuerpo del Contenido',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.primary)
              ),
              const SizedBox(height: 8),
              
              // Editor Quill
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    quill.QuillSimpleToolbar(
                      controller: _quillController,
                      config: const quill.QuillSimpleToolbarConfig(
                        showAlignmentButtons: true,
                        showCodeBlock: false,
                      ),
                    ),
                    const Divider(height: 1),
                    Container(
                      height: 300,
                      padding: const EdgeInsets.all(16),
                      child: quill.QuillEditor.basic(
                        controller: _quillController,
                        config: const quill.QuillEditorConfig(),
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Campos dinámicos según el tipo
              if (_contentType == 'reforma') ...[
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                Text('Datos del Decreto (Formato DOF)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.primary)),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _isCustomIssuingBody ? 'Otro (Escribir personalizado)...' : _selectedIssuingBody,
                  decoration: _buildInputDecoration('Órgano Emisor', Icons.account_balance),
                  items: [
                    'H. Congreso de la Unión',
                    'Poder Ejecutivo Federal',
                    'Suprema Corte de Justicia de la Nación',
                    'Congreso del Estado',
                    'Otro (Escribir personalizado)...'
                  ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) {
                    if (val == 'Otro (Escribir personalizado)...') {
                      setState(() => _isCustomIssuingBody = true);
                      _issuingBodyController.clear();
                    } else {
                      setState(() {
                        _isCustomIssuingBody = false;
                        _selectedIssuingBody = val!;
                        _issuingBodyController.text = val;
                      });
                    }
                  },
                ),
                if (_isCustomIssuingBody) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _issuingBodyController,
                    decoration: _buildInputDecoration('Especificar Órgano Emisor', Icons.edit),
                  ),
                ],
                const SizedBox(height: 16),
                TextFormField(
                  controller: _oldContentController,
                  maxLines: 4,
                  decoration: _buildInputDecoration('Texto Original', Icons.history),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _newContentController,
                  maxLines: 4,
                  decoration: _buildInputDecoration('Texto Reformado (Para quedar como sigue)', Icons.update),
                ),
                const SizedBox(height: 24),
                Text('Artículos Transitorios y Vigencia', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.primary)),
                const SizedBox(height: 16),
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: colorScheme.outlineVariant)),
                  title: Text('Entrada en Vigor: ${_entryIntoForceDate == null ? 'Seleccionar' : DateFormat('dd/MM/yyyy').format(_entryIntoForceDate!)}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _pickDateTime(context, isStart: false, isEntryIntoForce: true),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _transitoryArticlesController,
                  maxLines: 3,
                  decoration: _buildInputDecoration('Artículos Transitorios (Opcional)', Icons.article_outlined),
                ),
              ],

              if (_contentType == 'evento' || _contentType == 'convocatoria') ...[
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                Text('Detalles de ${_contentType == 'evento' ? 'Evento' : 'Convocatoria'}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.primary)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: colorScheme.outlineVariant)),
                        title: Text('Inicio: ${_eventStart == null ? 'Seleccionar' : DateFormat('dd/MM/yyyy HH:mm').format(_eventStart!)}'),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => _pickDateTime(context, isStart: true),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: colorScheme.outlineVariant)),
                        title: Text('Fin: ${_eventEnd == null ? 'Seleccionar' : DateFormat('dd/MM/yyyy HH:mm').format(_eventEnd!)}'),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => _pickDateTime(context, isStart: false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: colorScheme.outlineVariant)),
                  title: Text('Fecha Límite (Postulación / Registro): ${_deadline == null ? 'Seleccionar' : DateFormat('dd/MM/yyyy HH:mm').format(_deadline!)}'),
                  trailing: const Icon(Icons.timer),
                  onTap: () => _pickDateTime(context, isStart: false, isDeadline: true),
                ),
                const SizedBox(height: 16),
                TextFormField(controller: _eventLocationController, decoration: _buildInputDecoration('Lugar o Modalidad', Icons.location_on)),
                const SizedBox(height: 16),
                TextFormField(controller: _eventCostController, decoration: _buildInputDecoration('Costo (Ej. Gratuito, \$500 MXN)', Icons.attach_money)),
                const SizedBox(height: 16),
                TextFormField(controller: _eventLinkController, decoration: _buildInputDecoration('Enlace de registro o aplicación', Icons.link)),
              ],

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Text('Opciones de Destacado', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.primary)),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Destacar publicación'),
                subtitle: const Text('Aparecerá en el carrusel principal del inicio.'),
                value: _isFeatured,
                activeColor: colorScheme.primary,
                onChanged: (val) {
                  setState(() {
                    _isFeatured = val;
                    if (!val) _featuredUntil = null;
                  });
                },
              ),
              if (_isFeatured) ...[
                const SizedBox(height: 16),
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: colorScheme.outlineVariant)),
                  title: Text('Destacar hasta: ${_featuredUntil == null ? 'Seleccionar (obligatorio)' : DateFormat('dd/MM/yyyy HH:mm').format(_featuredUntil!)}'),
                  trailing: const Icon(Icons.calendar_today, color: Colors.orange),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _featuredUntil ?? DateTime.now().add(const Duration(days: 7)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null && mounted) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() {
                          _featuredUntil = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                        });
                      }
                    }
                  },
                ),
              ],

              if (_contentType == 'reforma' || _contentType == 'noticia') ...[
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                Text('Fuente Original', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.primary)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: TextFormField(controller: _sourceNameController, decoration: _buildInputDecoration('Nombre de la fuente (ej. DOF)', Icons.source))),
                    const SizedBox(width: 16),
                    Expanded(child: TextFormField(controller: _sourceUrlController, decoration: _buildInputDecoration('URL de la fuente', Icons.public))),
                  ],
                ),
              ],

              const SizedBox(height: 48),
              LawButton(
                label: _status == 'draft' ? 'Guardar Borrador' : (_status == 'scheduled' ? 'Programar Publicación' : 'Publicar Ahora'),
                isLoading: _isLoading,
                icon: _status == 'draft' ? Icons.save : (_status == 'scheduled' ? Icons.schedule : Icons.publish),
                onPressed: _submit,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
