import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _oldContentController = TextEditingController();
  final _newContentController = TextEditingController();

  String _category = 'Penal';
  String? _selectedCodeId;
  String? _selectedArticleId;
  bool _isReforma = false;
  bool _isLoading = false;
  List<LegalArticle> _articles = [];
  bool _isLoadingArticles = false;

  final List<String> _categories = [
    'Penal',
    'Constitucional',
    'Civil',
    'Laboral',
    'Administrativo',
    'Familiar',
    'Mercantil',
    'Electoral',
    'General',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _oldContentController.dispose();
    _newContentController.dispose();
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
      setState(() {
        _isLoadingArticles = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar artículos: $e')),
        );
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final dbService = ref.read(databaseServiceProvider);
      await dbService.createLegalUpdate(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        category: _category,
        articleId: _selectedArticleId,
        oldContent: _isReforma ? _oldContentController.text.trim() : null,
        newContent: _isReforma ? _newContentController.text.trim() : null,
      );

      // Invalidar el provider de actualizaciones
      ref.invalidate(legalUpdatesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Actualización publicada correctamente 🎉'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop(); // Regresa al dashboard de admin
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al publicar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _buildFieldDecoration(
    BuildContext context,
    String labelText,
    String hintText,
    IconData icon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: Icon(icon, size: 20),
      filled: true,
      fillColor: isDark ? const Color(0xFF161B2E) : const Color(0xFFF3F4F8),
      isDense: true,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.15),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.error, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.error, width: 1.5),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final codesAsync = ref.watch(legalCodesProvider);
    final colorScheme = Theme.of(context).colorScheme;


    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicar Noticia / Reforma'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detalles de la Publicación',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 16),
                    LawTextField(
                      controller: _titleController,
                      label: 'Título de la Noticia / Reforma',
                      icon: Icons.title,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El título es obligatorio';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _category,
                      decoration: _buildFieldDecoration(context, 'Categoría o Materia', 'Selecciona categoría', Icons.category_outlined),
                      items: _categories.map((cat) {
                        return DropdownMenuItem<String>(
                          value: cat,
                          child: Text(cat),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _category = val);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _contentController,
                      maxLines: 4,
                      decoration: _buildFieldDecoration(context, 'Descripción / Resumen de los Cambios', 'Describe brevemente qué cambió en la legislación...', Icons.description_outlined),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La descripción es obligatoria';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    // Toggle para indicar si es una reforma con comparativa
                    SwitchListTile(
                      title: const Text(
                        'Vincular con un artículo y mostrar comparativo',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      subtitle: const Text(
                        'Permite comparar el texto anterior con el nuevo y enlazar al artículo.',
                        style: TextStyle(fontSize: 12),
                      ),
                      value: _isReforma,
                      onChanged: (val) {
                        setState(() => _isReforma = val);
                      },
                      activeThumbColor: colorScheme.primary,
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (_isReforma) ...[
                      const SizedBox(height: 16),
                      // Selector de Código Legal
                      codesAsync.when(
                        data: (codes) => DropdownButtonFormField<String>(
                          initialValue: _selectedCodeId,
                          decoration: _buildFieldDecoration(context, 'Seleccionar Código Legal', 'Selecciona el código afectado', Icons.gavel_rounded),
                          items: codes.map((code) {
                            return DropdownMenuItem<String>(
                              value: code.id,
                              child: Text(code.name),
                            );
                          }).toList(),
                          onChanged: (codeId) {
                            if (codeId != null) {
                              setState(() {
                                _selectedCodeId = codeId;
                              });
                              _loadArticlesForCode(codeId);
                            }
                          },
                        ),
                        loading: () => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        error: (_, __) => const Text('Error al cargar códigos'),
                      ),
                      const SizedBox(height: 16),
                      // Selector de Artículo Afectado
                      if (_selectedCodeId != null)
                        _isLoadingArticles
                            ? const Center(child: CircularProgressIndicator())
                            : DropdownButtonFormField<String>(
                                initialValue: _selectedArticleId,
                                decoration: _buildFieldDecoration(context, 'Seleccionar Artículo', 'Selecciona el artículo afectado', Icons.article_outlined),
                                items: _articles.map((art) {
                                  return DropdownMenuItem<String>(
                                    value: art.id,
                                    child: Text('${art.number}: ${art.title}'),
                                  );
                                }).toList(),
                                onChanged: (artId) {
                                  setState(() => _selectedArticleId = artId);
                                },
                                validator: (value) {
                                  if (_isReforma && value == null) {
                                    return 'Debes seleccionar el artículo afectado';
                                  }
                                  return null;
                                },
                              ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _oldContentController,
                        maxLines: 3,
                        decoration: _buildFieldDecoration(context, 'Texto Anterior (Derogado / Reformado)', 'Texto original de la ley antes de la reforma...', Icons.history_edu_outlined),
                        validator: (value) {
                          if (_isReforma && (value == null || value.isEmpty)) {
                            return 'El texto anterior es obligatorio';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _newContentController,
                        maxLines: 3,
                        decoration: _buildFieldDecoration(context, 'Texto Nuevo (Modificado / Adicionado)', 'Nuevo texto vigente aprobado en la reforma...', Icons.gavel_outlined),
                        validator: (value) {
                          if (_isReforma && (value == null || value.isEmpty)) {
                            return 'El texto nuevo es obligatorio';
                          }
                          return null;
                        },
                      ),
                    ],
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: LawButton(
                        label: 'Publicar Ahora',
                        onPressed: _submit,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}
