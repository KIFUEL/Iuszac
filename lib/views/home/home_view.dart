import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/database_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/large_update_card.dart';
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
    _checkInstallable();
  }

  void _checkInstallable() {
    if (PwaHelper.isInstallable()) {
      setState(() {
        _isInstallable = true;
      });
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }

  double _responsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return (width - 1100) / 2;
    if (width > 800) return (width - 760) / 2;
    return 16.0;
  }

  Widget _buildInstallBanner(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(_responsivePadding(context), 8, _responsivePadding(context), 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.install_mobile, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Instala la aplicación', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Añade IUSZAC a tu pantalla de inicio.', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: PwaHelper.triggerInstall,
              style: ElevatedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary, backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('Instalar', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white70, size: 22),
              onPressed: () => setState(() => _isDismissed = true),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final profile = ref.watch(userProfileProvider).value;
    final updatesAsync = ref.watch(publicationsProvider);
    final firstName = profile?.fullName.split(' ')[0] ?? user?.userMetadata?['full_name']?.split(' ')[0] ?? 'Usuario';
    final colorScheme = Theme.of(context).colorScheme;
    final hPad = _responsivePadding(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: colorScheme.primaryContainer,
                        backgroundImage: profile?.avatarUrl != null ? NetworkImage(profile!.avatarUrl!) : null,
                        child: profile?.avatarUrl == null
                            ? Icon(Icons.person, color: colorScheme.onPrimaryContainer, size: 28)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getGreeting(),
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              firstName,
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () => context.go('/profile'),
                          icon: const Icon(Icons.settings_outlined),
                          color: colorScheme.onSurfaceVariant,
                          tooltip: 'Ajustes',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: GestureDetector(
                        onTap: () => context.go('/search'),
                        child: Hero(
                          tag: 'search_bar',
                          child: Material(
                            type: MaterialType.transparency,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorScheme.shadow.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                                border: Border.all(
                                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.search_rounded, color: colorScheme.primary, size: 26),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Buscar artículos, foros, eventos...',
                                      style: TextStyle(
                                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(Icons.tune_rounded, color: colorScheme.primary, size: 20),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_isInstallable && !_isDismissed)
            SliverToBoxAdapter(child: _buildInstallBanner(context)),

          // Main content
          SliverToBoxAdapter(
            child: updatesAsync.when(
              data: (updates) {
                if (updates.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(child: Text('No hay publicaciones recientes')),
                  );
                }

                // 1. Featured / Carousel
                final now = DateTime.now();
                var carouselUpdates = updates.where((u) => u.isFeatured && (u.featuredUntil == null || u.featuredUntil!.isAfter(now))).toList();
                // Si no hay destacados, poner las 5 mas nuevas
                if (carouselUpdates.isEmpty) {
                  carouselUpdates = updates.take(5).toList();
                } else if (carouselUpdates.length < 5) {
                  // Rellenar hasta 5 con las más nuevas que no estén ya en el carrusel
                  final existingIds = carouselUpdates.map((e) => e.id).toSet();
                  final fill = updates.where((u) => !existingIds.contains(u.id)).take(5 - carouselUpdates.length);
                  carouselUpdates.addAll(fill);
                }

                // 2. Noticias
                final news = updates.where((u) => u.contentType == 'noticia').take(3).toList();

                // 3. Eventos / Convocatorias
                final events = updates.where((u) => u.contentType == 'evento' || u.contentType == 'convocatoria').take(3).toList();

                // 4. Reformas
                final reforms = updates.where((u) => u.contentType == 'reforma').take(3).toList();

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        // Carrusel
                        if (carouselUpdates.isNotEmpty) ...[
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: hPad),
                            child: _buildSectionHeader(context, 'Destacados', Icons.star, null),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 380, // Aproximadamente el alto de LargeUpdateCard
                            child: PageView.builder(
                              controller: PageController(viewportFraction: 0.92),
                              itemCount: carouselUpdates.length,
                              itemBuilder: (context, index) {
                                final update = carouselUpdates[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                  child: LargeUpdateCard(
                                    update: update,
                                    onTap: () => context.push('/alerts/detail/${update.id}'),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],

                        // Noticias
                        if (news.isNotEmpty) ...[
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: hPad),
                            child: _buildSectionHeader(context, 'Últimas Noticias', Icons.newspaper, () => context.go('/alerts?type=noticia')),
                          ),
                          const SizedBox(height: 8),
                          ...news.map((u) => Padding(
                                padding: EdgeInsets.symmetric(horizontal: hPad),
                                child: LargeUpdateCard(
                                  update: u,
                                  onTap: () => context.push('/alerts/detail/${u.id}'),
                                ),
                              )),
                          const SizedBox(height: 32),
                        ],

                        // Eventos
                        if (events.isNotEmpty) ...[
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: hPad),
                            child: _buildSectionHeader(context, 'Próximos Eventos', Icons.event, () => context.go('/alerts?type=evento')),
                          ),
                          const SizedBox(height: 8),
                          ...events.map((u) => Padding(
                                padding: EdgeInsets.symmetric(horizontal: hPad),
                                child: LargeUpdateCard(
                                  update: u,
                                  onTap: () => context.push('/alerts/detail/${u.id}'),
                                ),
                              )),
                          const SizedBox(height: 32),
                        ],

                        // Reformas
                        if (reforms.isNotEmpty) ...[
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: hPad),
                            child: _buildSectionHeader(context, 'Últimas Reformas', Icons.gavel, () => context.go('/alerts?type=reforma')),
                          ),
                          const SizedBox(height: 8),
                          ...reforms.map((u) => Padding(
                                padding: EdgeInsets.symmetric(horizontal: hPad),
                                child: LargeUpdateCard(
                                  update: u,
                                  onTap: () => context.push('/alerts/detail/${u.id}'),
                                ),
                              )),
                          const SizedBox(height: 48),
                        ],
                      ],
                    ),
                  ),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon, VoidCallback? onAction) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
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
              color: colorScheme.onSurface,
            ),
          ),
        ),
        if (onAction != null)
          TextButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            label: const Text('Ver todos', style: TextStyle(fontSize: 14)),
          ),
      ],
    );
  }
}
