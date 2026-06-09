import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/database_provider.dart';
import '../../models/legal_code.dart';
import '../../models/legal_update.dart';
import '../../widgets/common_widgets.dart';

import '../../utils/pwa_helper.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  bool _isInstallable = false;
  bool _isDismissed = false;

  @override
  void initState() {
    super.initState();
    PwaHelper.init((installable) {
      if (mounted) {
        setState(() {
          _isInstallable = installable;
        });
      }
    });
    _isInstallable = PwaHelper.isInstallable();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }

  /// Responsive horizontal padding – wider on tablets/desktop
  double _responsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 900) return 48;
    if (width >= 600) return 32;
    return 16;
  }

  Widget _buildInstallBanner(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hPad = _responsivePadding(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 8),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary,
              colorScheme.secondary,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.install_mobile_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '¡Instala IUZ UAZ!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Accede más rápido y trabaja sin conexión.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final success = await PwaHelper.triggerInstall();
                if (success) {
                  if (mounted) {
                    setState(() {
                      _isInstallable = false;
                    });
                  }
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('¡Gracias por instalar IUZ UAZ!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.download_rounded, size: 20),
              label: const Text(
                'Instalar',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                minimumSize: const Size(0, 48),
                elevation: 0,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white70, size: 22),
              onPressed: () {
                setState(() {
                  _isDismissed = true;
                });
              },
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final updatesAsync = ref.watch(legalUpdatesProvider);
    final codesAsync = ref.watch(legalCodesProvider);

    final firstName = user?.userMetadata?['full_name'] ?? 'Usuario';
    final colorScheme = Theme.of(context).colorScheme;
    final hPad = _responsivePadding(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header con Saludo e Ícono de Notificaciones
          SliverAppBar.large(
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_getGreeting()},',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                        fontSize: 14,
                        height: 1.4,
                      ),
                ),
                Text(
                  firstName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            // Removemos los actions para que ya no aparezca la campanita arriba
          ),

          // Buscador Global
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 8),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: GestureDetector(
                    onTap: () => context.go('/search'),
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: colorScheme.onSurfaceVariant, size: 24),
                          const SizedBox(width: 12),
                          Text(
                            'Busca artículos, códigos o foros...',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          if (_isInstallable && !_isDismissed)
            SliverToBoxAdapter(
              child: _buildInstallBanner(context),
            ),

          // ── Noticias y Reformas Recientes (Carrusel) ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: hPad),
                    child: _buildSectionHeader(
                      context,
                      'Reformas Recientes',
                      Icons.gavel_rounded,
                      () => context.go('/alerts'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  updatesAsync.when(
                    data: (updates) {
                      if (updates.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.newspaper_rounded,
                                  size: 80,
                                  color: colorScheme.outline.withValues(alpha: 0.4),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No hay reformas recientes',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurfaceVariant,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Vuelve más tarde para ver actualizaciones.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      final carouselUpdates = updates.take(3).toList();
                      return SizedBox(
                        height: 240,
                        child: PageView.builder(
                          controller: PageController(viewportFraction: 0.9),
                          itemCount: carouselUpdates.length,
                          itemBuilder: (context, index) {
                            final update = carouselUpdates[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6.0),
                              child: _buildCarouselNewsCard(context, update),
                            );
                          },
                        ),
                      );
                    },
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (err, _) => Padding(
                      padding: EdgeInsets.symmetric(horizontal: hPad),
                      child: Text('Error: $err', style: const TextStyle(fontSize: 14)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Divider between sections ──
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: const Divider(height: 32, thickness: 0.5),
            ),
          ),

          // ── Otras Noticias (Lista Vertical) ──
          SliverToBoxAdapter(
            child: updatesAsync.when(
              data: (updates) {
                if (updates.length <= 3) return const SizedBox();
                final remainingUpdates = updates.skip(3).toList();
                return Padding(
                  padding: EdgeInsets.fromLTRB(hPad, 8.0, hPad, 8.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(context, 'Más Noticias', Icons.article_outlined, null),
                          const SizedBox(height: 16),
                          ...remainingUpdates.map((update) => _buildListNewsCard(context, update)),
                        ],
                      ),
                    ),
                  ),
                );
              },
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),
          ),

          // ── Divider before codes section ──
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: const Divider(height: 32, thickness: 0.5),
            ),
          ),

          // ── Códigos Disponibles ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: hPad),
                    child: _buildSectionHeader(
                      context,
                      'Códigos Disponibles',
                      Icons.menu_book_rounded,
                      () => context.go('/codes'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 180,
                    child: codesAsync.when(
                      data: (codes) => ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: hPad - 4),
                        itemCount: codes.length,
                        itemBuilder: (context, index) =>
                            _buildCodeCard(context, codes[index]),
                      ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, _) => const SizedBox(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  /// Section header with accent bar, icon, title, and optional action button
  Widget _buildSectionHeader(BuildContext context, String title, IconData icon, VoidCallback? onAction) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        // Accent bar
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: colorScheme.secondary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
              color: colorScheme.onSurface,
              height: 1.3,
            ),
          ),
        ),
        if (onAction != null)
          TextButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            label: const Text(
              'Ver todos',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            style: TextButton.styleFrom(
              minimumSize: const Size(0, 48),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
      ],
    );
  }

  Widget _buildTypeChip(BuildContext context, String contentType) {
    final colorScheme = Theme.of(context).colorScheme;
    IconData icon;
    String label;
    Color color;
    
    switch (contentType) {
      case 'reforma':
        icon = Icons.gavel_rounded;
        label = 'Reforma';
        color = Colors.blue;
        break;
      case 'noticia':
        icon = Icons.newspaper_rounded;
        label = 'Noticia';
        color = Colors.orange;
        break;
      case 'evento':
        icon = Icons.event_rounded;
        label = 'Evento';
        color = Colors.green;
        break;
      case 'convocatoria':
        icon = Icons.campaign_rounded;
        label = 'Convocatoria';
        color = Colors.purple;
        break;
      default:
        icon = Icons.article_rounded;
        label = 'Publicación';
        color = colorScheme.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 10,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselNewsCard(BuildContext context, LegalUpdate update) {
    final colorScheme = Theme.of(context).colorScheme;
    final formattedDate = DateFormat('dd/MM/yyyy').format(update.createdAt);
    final isNew = DateTime.now().difference(update.createdAt).inHours < 24;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: LawCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    update.category,
                    style: TextStyle(
                      color: colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildTypeChip(context, update.contentType),
                if (isNew) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.shade700,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'NUEVO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                Icon(Icons.calendar_today_rounded, size: 14, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                const SizedBox(width: 4),
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(
              height: 1,
              thickness: 0.5,
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              update.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Text(
                      update.plainContent,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                        height: 1.5,
                      ),
                      maxLines: update.contentType == 'evento' || update.contentType == 'convocatoria' ? 2 : 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (update.contentType == 'evento') ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.event, size: 13, color: Colors.green.shade700),
                        const SizedBox(width: 4),
                        Text(
                          update.eventStart != null
                              ? DateFormat('dd/MM HH:mm').format(update.eventStart!)
                              : 'Fecha pendiente',
                          style: TextStyle(fontSize: 11, color: Colors.green.shade700, fontWeight: FontWeight.bold),
                        ),
                        if (update.eventLocation != null) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.location_on, size: 13, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              update.eventLocation!,
                              style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                  if (update.contentType == 'convocatoria' && update.deadline != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined, size: 13, color: Colors.purple),
                        const SizedBox(width: 4),
                        Text(
                          'Límite: ${update.deadline}',
                          style: const TextStyle(fontSize: 11, color: Colors.purple, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                  if (update.tags.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: update.tags.map((tag) => Container(
                          margin: const EdgeInsets.only(right: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '#$tag',
                            style: TextStyle(fontSize: 9, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8)),
                          ),
                        )).toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    if (update.articleId != null) {
                      context.push('/article/${update.articleId}');
                    } else {
                      context.push('/alerts/detail/${update.id}');
                    }
                  },
                  icon: Icon(
                    update.articleId != null ? Icons.article_outlined : Icons.visibility_outlined,
                    size: 18,
                  ),
                  label: Text(
                    update.articleId != null ? 'Ver artículo' : 'Ver cambios',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    side: BorderSide(color: colorScheme.primary, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    minimumSize: const Size(0, 48),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListNewsCard(BuildContext context, LegalUpdate update) {
    final colorScheme = Theme.of(context).colorScheme;
    final formattedDate = DateFormat('dd/MM/yyyy').format(update.createdAt);
    final isNew = DateTime.now().difference(update.createdAt).inHours < 24;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: LawCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: InkWell(
          onTap: () {
            if (update.articleId != null) {
              context.push('/article/${update.articleId}');
            } else {
              context.push('/alerts/detail/${update.id}');
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      update.category,
                      style: TextStyle(
                        color: colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildTypeChip(context, update.contentType),
                  if (isNew) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.shade700,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'NUEVO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  Icon(Icons.calendar_today_rounded, size: 13, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                  const SizedBox(width: 4),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          update.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          update.plainContent,
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                            height: 1.5,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (update.contentType == 'evento') ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.event, size: 13, color: Colors.green.shade700),
                              const SizedBox(width: 4),
                              Text(
                                update.eventStart != null
                                    ? DateFormat('dd/MM HH:mm').format(update.eventStart!)
                                    : 'Fecha pendiente',
                                style: TextStyle(fontSize: 11, color: Colors.green.shade700, fontWeight: FontWeight.bold),
                              ),
                              if (update.eventLocation != null) ...[
                                const SizedBox(width: 8),
                                Icon(Icons.location_on, size: 13, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
                                const SizedBox(width: 2),
                                Expanded(
                                  child: Text(
                                    update.eventLocation!,
                                    style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                        if (update.contentType == 'convocatoria' && update.deadline != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.timer_outlined, size: 13, color: Colors.purple),
                              const SizedBox(width: 4),
                              Text(
                                'Límite: ${update.deadline}',
                                style: const TextStyle(fontSize: 11, color: Colors.purple, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                        if (update.tags.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: update.tags.map((tag) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '#$tag',
                                style: TextStyle(fontSize: 9, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8)),
                              ),
                            )).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.chevron_right,
                      size: 22,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCodeCard(BuildContext context, LegalCode code) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 155,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(20),
        child: LawCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon container with gradient background
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primaryContainer,
                      colorScheme.secondaryContainer,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.gavel_rounded,
                    size: 24,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                code.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: code.status == 'Vigente'
                      ? Colors.green.withValues(alpha: 0.12)
                      : Colors.blue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  code.status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: code.status == 'Vigente' ? Colors.green : Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
