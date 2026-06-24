import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/database_provider.dart';
import '../../widgets/common_widgets.dart';

class NewPostView extends ConsumerStatefulWidget {
  const NewPostView({super.key});

  @override
  ConsumerState<NewPostView> createState() => _NewPostViewState();
}

class _NewPostViewState extends ConsumerState<NewPostView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();
  bool _isUrgent = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Procesar hashtags: limpiar, quitar '#' extras y filtrar vacíos
      final tags = _tagsController.text
          .split(',')
          .map((t) => t.trim().replaceAll('#', ''))
          .where((t) => t.isNotEmpty)
          .toList();

      final dbService = ref.read(databaseServiceProvider);
      await dbService.createForumPost(
        _titleController.text.trim(),
        _contentController.text.trim(),
        tags: tags,
        isUrgent: _isUrgent,
      );

      // Invalida el provider para que refresque la lista de posts del foro
      ref.invalidate(forumPostsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Publicación creada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/forum');
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
        title: const Text('Nueva Publicación'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/forum'),
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
                    'Plantea tu duda o caso legal',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Describe los hechos detalladamente y utiliza hashtags para categorizar tu consulta.',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  
                  // Campo de Título
                  LawTextField(
                    label: 'Título del Post',
                    icon: Icons.title_rounded,
                    controller: _titleController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor ingresa un título';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  LawTextField(
                    label: 'Hashtags (separados por comas)',
                    icon: Icons.tag,
                    controller: _tagsController,
                    keyboardType: TextInputType.text,
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
                  const SizedBox(height: 20),
                  
                  // Campo de Contenido
                  TextFormField(
                    controller: _contentController,
                    maxLines: 8,
                    decoration: InputDecoration(
                      labelText: 'Cuerpo del Post / Hechos',
                      labelStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6)),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(bottom: 140),
                        child: Icon(Icons.description_outlined, color: colorScheme.primary),
                      ),
                      alignLabelWithHint: true,
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
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor escribe el contenido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Interruptor de Urgencia
                  SwitchListTile(
                    title: const Text('Marcar como asunto urgente', style: TextStyle(fontSize: 14)),
                    subtitle: const Text('Añade un aviso visual para obtener ayuda rápida', style: TextStyle(fontSize: 11)),
                    value: _isUrgent,
                    activeThumbColor: Colors.red,
                    onChanged: (val) => setState(() => _isUrgent = val),
                    contentPadding: EdgeInsets.zero,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Error
                  if (_errorMessage != null) ...[
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: colorScheme.error, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                  ],
                  
                  // Botón
                  LawButton(
                    label: 'Publicar en el Foro',
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
