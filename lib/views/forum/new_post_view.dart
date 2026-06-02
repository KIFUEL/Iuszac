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
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dbService = ref.read(databaseServiceProvider);
      await dbService.createForumPost(
        _titleController.text.trim(),
        _contentController.text.trim(),
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
                          color: Theme.of(context).colorScheme.primary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Describe los hechos detalladamente y formula tus interrogantes. La comunidad legal te ayudará a analizarlos.',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  
                  // Campo de Título
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Título del Post',
                      prefixIcon: const Icon(Icons.title_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor ingresa un título';
                      }
                      if (value.length < 5) {
                        return 'El título debe tener al menos 5 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  // Campo de Contenido
                  TextFormField(
                    controller: _contentController,
                    maxLines: 8,
                    decoration: InputDecoration(
                      labelText: 'Cuerpo del Post / Hechos',
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(bottom: 140),
                        child: Icon(Icons.description_outlined),
                      ),
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor escribe el contenido de tu publicación';
                      }
                      if (value.length < 15) {
                        return 'El contenido es demasiado corto (mínimo 15 caracteres)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Error
                  if (_errorMessage != null) ...[
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 13),
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
