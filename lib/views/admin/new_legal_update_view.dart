import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import '../../providers/database_provider.dart';
import '../../models/legal_article.dart';
import '../../widgets/common_widgets.dart';

class NewLegalUpdateView extends ConsumerStatefulWidget {
  const NewLegalUpdateView({super.key});

  @override
  ConsumerState<NewLegalUpdateView> createState() => _NewLegalUpdateViewState();
}

class _NewLegalUpdateViewState extends ConsumerState<NewLegalUpdateView> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers basicos
  final _titleController = TextEditingController();
  final _oldContentController = TextEditingController();
  final _newContentController = TextEditingController();
  final _sourceNameController = TextEditingController();
  final _sourceUrlController = TextEditingController();
  final _eventLocationController = TextEditingController();
  final _eventLinkController = TextEditingController();
  final _tagsController = TextEditingController();
  final _imageUrlController = TextEditingController();

  late quill.QuillController _quillController;

  String _contentType = 'reforma'; // 'reforma', 'noticia', 'evento', 'convocatoria'
  String _status = 'published'; // 'draft', 'published', 'scheduled'
  String _category = 'Penal';
  
  String? _selectedCodeId;
  String? _selectedArticleId;
  List<LegalArticle> _articles = [];
  bool _isLoadingArticles = false;

  DateTime? _eventStart;
  DateTime? _eventEnd;
  DateTime? _deadline;
  DateTime? _scheduledDate;
  
  bool _isLoading = false;

  final List<String> _categories = [
    'Penal', 'Constitucional', 'Civil', 'Laboral',
    'Administrativo', 'Familiar', 'Mercantil', 'Electoral', 'General',
  ];

  @override
  void initState() {
    super.initState();
    _quillController = quill.QuillController.basic();
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
    _tagsController.dispose();
    _imageUrlController.dispose();
    _quillController.dispose();
    super.dispose();
  }

  Future<void> _loadArticlesForCode(String codeId) async {
    setState(() {
      _isLoadingArticles = true;
      _articles = [];
      _selectedArticleId = null;
    });

    try {
      final dbService = ref.read(databaseServiceProvider);
      final articles = await dbService.getArticlesByCode(codeId);
      setState(() {
        _articles = articles;
        _isLoadingArticles = false;
      });
    } catch (e) {
      setState(() => _isLoadingArticles = false);
    }
  }

  Future<void> _pickDateTime(BuildContext context, {required bool isStart, bool isDeadline = false, bool isScheduled = false}) async {
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
    
    // Obtener contenido de Quill como JSON string
    final contentJson = jsonEncode(_quillController.document.toDelta().toJson());

    setState(() => _isLoading = true);

    try {
      final dbService = ref.read(databaseServiceProvider);
      
      List<String> tags = _tagsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      await dbService.createLegalUpdate(
        title: _titleController.text.trim(),
        content: contentJson,
        category: _category,
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
        deadline: _deadline?.toIso8601String(),
        publishedAt: _status == 'scheduled' ? _scheduledDate : (_status == 'published' ? DateTime.now() : null),
        articleId: _contentType == 'reforma' ? _selectedArticleId : null,
        oldContent: _contentType == 'reforma' && _oldContentController.text.isNotEmpty ? _oldContentController.text.trim() : null,
        newContent: _contentType == 'reforma' && _newContentController.text.isNotEmpty ? _newContentController.text.trim() : null,
      );

      ref.invalidate(legalUpdatesProvider);

      if (!mounted) return;

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
    final codesAsync = ref.watch(legalCodesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Publicación', style: TextStyle(fontWeight: FontWeight.bold)),
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
                      onChanged: (val) => setState(() => _contentType = val!),
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
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _category,
                      decoration: _buildInputDecoration('Categoría', Icons.category),
                      items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (val) => setState(() => _category = val!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _tagsController,
                      decoration: _buildInputDecoration('Etiquetas (separadas por coma)', Icons.label),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: _buildInputDecoration('URL de Imagen de Portada (Opcional)', Icons.image),
              ),
              
              const SizedBox(height: 24),
              Text('Cuerpo del Contenido', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.primary)),
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
                Text('Vinculación Legal (Solo Reformas)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.primary)),
                const SizedBox(height: 16),
                codesAsync.when(
                  data: (codes) => DropdownButtonFormField<String>(
                    initialValue: _selectedCodeId,
                    decoration: _buildInputDecoration('Seleccionar Código/Ley', Icons.gavel),
                    items: codes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                    onChanged: (val) {
                      setState(() => _selectedCodeId = val);
                      if (val != null) _loadArticlesForCode(val);
                    },
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (e, _) => Text('Error al cargar códigos: $e'),
                ),
                const SizedBox(height: 16),
                if (_isLoadingArticles)
                  const CircularProgressIndicator()
                else if (_articles.isNotEmpty)
                  DropdownButtonFormField<String>(
                    initialValue: _selectedArticleId,
                    decoration: _buildInputDecoration('Seleccionar Artículo', Icons.article_outlined),
                    items: _articles.map((a) => DropdownMenuItem(value: a.id, child: Text('Art. ${a.number} - ${a.title}'))).toList(),
                    onChanged: (val) => setState(() => _selectedArticleId = val),
                  ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _oldContentController,
                        maxLines: 4,
                        decoration: _buildInputDecoration('Texto Anterior', Icons.history),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _newContentController,
                        maxLines: 4,
                        decoration: _buildInputDecoration('Texto Nuevo', Icons.update),
                      ),
                    ),
                  ],
                ),
              ],

              if (_contentType == 'evento') ...[
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                Text('Detalles del Evento', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.primary)),
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
                Row(
                  children: [
                    Expanded(child: TextFormField(controller: _eventLocationController, decoration: _buildInputDecoration('Lugar o Modalidad', Icons.location_on))),
                    const SizedBox(width: 16),
                    Expanded(child: TextFormField(controller: _eventLinkController, decoration: _buildInputDecoration('Enlace de registro', Icons.link))),
                  ],
                ),
              ],

              if (_contentType == 'convocatoria') ...[
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                Text('Detalles de Convocatoria', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colorScheme.primary)),
                const SizedBox(height: 16),
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: colorScheme.outlineVariant)),
                  title: Text('Fecha Límite: ${_deadline == null ? 'Seleccionar' : DateFormat('dd/MM/yyyy HH:mm').format(_deadline!)}'),
                  trailing: const Icon(Icons.timer),
                  onTap: () => _pickDateTime(context, isStart: false, isDeadline: true),
                ),
              ],

              if (_contentType != 'evento') ...[
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
