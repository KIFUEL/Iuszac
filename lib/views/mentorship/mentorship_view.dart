import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/database_provider.dart';
import '../../models/mentor.dart';
import '../../widgets/common_widgets.dart';

class MentorshipView extends ConsumerStatefulWidget {
  const MentorshipView({super.key});

  @override
  ConsumerState<MentorshipView> createState() => _MentorshipViewState();
}

class _MentorshipViewState extends ConsumerState<MentorshipView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedSpecialty = 'Todos';
  bool _onlyVerified = false;
  int _minExperience = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _launchUrlHelper(BuildContext context, String urlString, String errorMessage) async {
    final uri = Uri.parse(urlString);
    try {
      final success = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!success) {
        throw 'No se pudo iniciar el enlace';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$errorMessage (Detalle: $e)'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _contactWhatsApp(BuildContext context, Mentor mentor) {
    if (mentor.whatsappNumber == null || mentor.whatsappNumber!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Este mentor no tiene configurado un número de WhatsApp.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final name = mentor.profile?.fullName ?? 'Mentor';
    final number = mentor.whatsappNumber!.replaceAll(RegExp(r'[^0-9]'), '');
    final text = Uri.encodeComponent(
      'Hola $name, encontré tu perfil en LawApp y me gustaría solicitar una mentoría legal.',
    );
    _launchUrlHelper(
      context,
      'https://wa.me/$number?text=$text',
      'No se pudo abrir WhatsApp.',
    );
  }

  void _contactEmail(BuildContext context, Mentor mentor) {
    if (mentor.emailContact == null || mentor.emailContact!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Este mentor no tiene configurado un correo de contacto.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final name = mentor.profile?.fullName ?? 'Mentor';
    final email = mentor.emailContact!.trim();
    final subject = Uri.encodeComponent('Solicitud de Mentoría - LawApp');
    final body = Uri.encodeComponent(
      'Estimado/a $name,\n\nMe pongo en contacto contigo a través de LawApp para solicitar asesoría y mentoría profesional en tu área de especialidad.\n\nSaludos cordiales.',
    );
    _launchUrlHelper(
      context,
      'mailto:$email?subject=$subject&body=$body',
      'No se pudo abrir tu cliente de correo.',
    );
  }

  void _showMentorDetails(BuildContext context, Mentor mentor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        final name = mentor.profile?.fullName ?? 'Mentor';
        final initial = name.isNotEmpty ? name[0].toUpperCase() : 'M';
        final hasAvatar = mentor.profile?.avatarUrl != null && mentor.profile!.avatarUrl!.isNotEmpty;

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.all(24.0),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
            maxWidth: 600,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: colorScheme.primaryContainer,
                    backgroundImage: hasAvatar ? NetworkImage(mentor.profile!.avatarUrl!) : null,
                    child: !hasAvatar
                        ? Text(
                            initial,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                            if (mentor.isVerified)
                              const Icon(Icons.verified, color: Colors.blue, size: 22),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mentor.specialty,
                          style: TextStyle(
                            color: colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.work_history_outlined, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              '${mentor.experienceYears} años de experiencia',
                              style: const TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),
              Text(
                'Sobre mí',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                mentor.profile?.bio ?? 'Este mentor aún no ha agregado una biografía.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  if (mentor.whatsappNumber != null && mentor.whatsappNumber!.isNotEmpty)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _contactWhatsApp(context, mentor),
                        icon: const Icon(Icons.chat_bubble),
                        label: const Text('WhatsApp'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  if (mentor.whatsappNumber != null &&
                      mentor.whatsappNumber!.isNotEmpty &&
                      mentor.emailContact != null &&
                      mentor.emailContact!.isNotEmpty)
                    const SizedBox(width: 12),
                  if (mentor.emailContact != null && mentor.emailContact!.isNotEmpty)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _contactEmail(context, mentor),
                        icon: const Icon(Icons.email_outlined),
                        label: const Text('Enviar Correo'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.primary,
                          side: BorderSide(color: colorScheme.primary),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mentorsAsync = ref.watch(mentorsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Directorio de Mentores'),
            actions: [
              IconButton(
                onPressed: () => ref.invalidate(mentorsProvider),
                icon: const Icon(Icons.refresh_rounded),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Buscador y Barra de Herramientas
                  Card(
                    elevation: 0,
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Buscar por nombre o especialidad...',
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        setState(() {
                                          _searchController.clear();
                                          _searchQuery = '';
                                        });
                                      },
                                    )
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: colorScheme.surface,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val.trim().toLowerCase();
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                FilterChip(
                                  label: const Text('Todos'),
                                  selected: _selectedSpecialty == 'Todos',
                                  onSelected: (val) {
                                    if (val) setState(() => _selectedSpecialty = 'Todos');
                                  },
                                ),
                                const SizedBox(width: 8),
                                FilterChip(
                                  label: const Text('Verificados'),
                                  selected: _onlyVerified,
                                  onSelected: (val) {
                                    setState(() => _onlyVerified = val);
                                  },
                                ),
                                const SizedBox(width: 8),
                                FilterChip(
                                  label: const Text('5+ Años Exp.'),
                                  selected: _minExperience == 5,
                                  onSelected: (val) {
                                    setState(() => _minExperience = val ? 5 : 0);
                                  },
                                ),
                                const SizedBox(width: 8),
                                FilterChip(
                                  label: const Text('10+ Años Exp.'),
                                  selected: _minExperience == 10,
                                  onSelected: (val) {
                                    setState(() => _minExperience = val ? 10 : 0);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          mentorsAsync.when(
            data: (mentors) {
              // Aplicar filtros locales
              final filteredMentors = mentors.where((mentor) {
                final name = mentor.profile?.fullName.toLowerCase() ?? '';
                final specialty = mentor.specialty.toLowerCase();
                final matchesSearch = name.contains(_searchQuery) || specialty.contains(_searchQuery);
                final matchesSpecialty = _selectedSpecialty == 'Todos' || mentor.specialty == _selectedSpecialty;
                final matchesVerified = !_onlyVerified || mentor.isVerified;
                final matchesExperience = mentor.experienceYears >= _minExperience;

                return matchesSearch && matchesSpecialty && matchesVerified && matchesExperience;
              }).toList();

              if (filteredMentors.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline_rounded, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No se encontraron mentores.',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final bool isLargeScreen = MediaQuery.of(context).size.width >= 700;

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: isLargeScreen
                    ? SliverGrid(
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 400,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1.8,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildMentorCard(context, filteredMentors[index]),
                          childCount: filteredMentors.length,
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: _buildMentorCard(context, filteredMentors[index]),
                          ),
                          childCount: filteredMentors.length,
                        ),
                      ),
              );
            },
            loading: () => const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) => SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'Error al cargar mentores: ${err.toString()}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildMentorCard(BuildContext context, Mentor mentor) {
    final colorScheme = Theme.of(context).colorScheme;
    final name = mentor.profile?.fullName ?? 'Mentor';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'M';
    final hasAvatar = mentor.profile?.avatarUrl != null && mentor.profile!.avatarUrl!.isNotEmpty;

    return InkWell(
      onTap: () => _showMentorDetails(context, mentor),
      borderRadius: BorderRadius.circular(20),
      child: LawCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: colorScheme.secondaryContainer,
                  backgroundImage: hasAvatar ? NetworkImage(mentor.profile!.avatarUrl!) : null,
                  child: !hasAvatar
                      ? Text(
                          initial,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSecondaryContainer,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (mentor.isVerified)
                            const Icon(Icons.verified, color: Colors.blue, size: 18),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        mentor.specialty,
                        style: TextStyle(
                          color: colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Text(
                mentor.profile?.bio ?? 'Sin biografía disponible.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.4),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${mentor.experienceYears} años exp.',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey),
                ),
                Row(
                  children: [
                    if (mentor.emailContact != null && mentor.emailContact!.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.email_outlined),
                        tooltip: 'Enviar Correo',
                        visualDensity: VisualDensity.compact,
                        onPressed: () => _contactEmail(context, mentor),
                      ),
                    if (mentor.whatsappNumber != null && mentor.whatsappNumber!.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.chat_bubble_outline),
                        tooltip: 'Enviar WhatsApp',
                        color: Colors.green.shade600,
                        visualDensity: VisualDensity.compact,
                        onPressed: () => _contactWhatsApp(context, mentor),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
