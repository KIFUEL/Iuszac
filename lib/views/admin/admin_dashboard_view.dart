import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/database_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/legal_update.dart';
import '../../widgets/common_widgets.dart';

class AdminDashboardView extends ConsumerWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider).value;
    final updatesAsync = ref.watch(legalUpdatesProvider);
    final postsAsync = ref.watch(forumPostsProvider);
    final usersAsync = ref.watch(allUsersProvider);
    final draftsAsync = ref.watch(myDraftsProvider);
    final scheduledAsync = ref.watch(scheduledUpdatesProvider);
    final colorScheme = Theme.of(context).colorScheme;

    // Get statistics reactively
    final int newsCount = updatesAsync.value?.length ?? 0;
    final int postsCount = postsAsync.value?.length ?? 0;
    final int usersCount = usersAsync.value?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Panel de Administración',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(legalUpdatesProvider);
              ref.invalidate(myDraftsProvider);
              ref.invalidate(scheduledUpdatesProvider);
              ref.invalidate(forumPostsProvider);
              ref.invalidate(allUsersProvider);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Actividad Global Stats Section
            Text(
              'Actividad Global',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Noticias',
                    newsCount.toString(),
                    Icons.newspaper,
                    colorScheme.primaryContainer,
                    colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Foros',
                    postsCount.toString(),
                    Icons.forum,
                    colorScheme.secondaryContainer,
                    colorScheme.onSecondaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Usuarios',
                    usersCount.toString(),
                    Icons.people,
                    colorScheme.tertiaryContainer,
                    colorScheme.onTertiaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Acciones Rápidas Section
            Text(
              'Acciones Rápidas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                return GridView.count(
                  crossAxisCount: isWide ? 3 : 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: isWide ? 2.5 : 1.8,
                  children: [
                    if (profile?.canPublish ?? false)
                      _buildActionButton(
                        context,
                        'Publicar Noticia',
                        Icons.add_photo_alternate_outlined,
                        colorScheme.primary,
                        () => context.push('/admin/new-update'),
                      ),
                    if (profile?.canManageUsers ?? false)
                      _buildActionButton(
                        context,
                        'Gestión de Usuarios',
                        Icons.manage_accounts_rounded,
                        colorScheme.secondary,
                        () => context.push('/admin/users'),
                      ),
                    if (profile?.canModerate ?? false)
                      _buildActionButton(
                        context,
                        'Moderar Contenido',
                        Icons.gavel_rounded,
                        colorScheme.error,
                        () => context.push('/admin/moderation'),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            DefaultTabController(
              length: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TabBar(
                    tabs: const [
                      Tab(text: 'Publicadas'),
                      Tab(text: 'Borradores'),
                      Tab(text: 'Programadas'),
                    ],
                    labelColor: colorScheme.primary,
                    unselectedLabelColor: colorScheme.onSurfaceVariant,
                    indicatorColor: colorScheme.primary,
                    dividerColor: Colors.transparent,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 400,
                    child: TabBarView(
                      children: [
                        _buildUpdatesList(context, ref, updatesAsync),
                        _buildUpdatesList(context, ref, draftsAsync),
                        _buildUpdatesList(context, ref, scheduledAsync),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color bgColor,
    Color fgColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: fgColor, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: fgColor),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: fgColor.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminUpdateCard(BuildContext context, WidgetRef ref, LegalUpdate update) {
    final colorScheme = Theme.of(context).colorScheme;
    final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(update.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: LawCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        update.category,
                        style: TextStyle(
                          color: colorScheme.onSecondaryContainer,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (update.status == 'draft')
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.1),
                          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Borrador',
                          style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      )
                    else if (update.status == 'scheduled')
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.purple.withValues(alpha: 0.1),
                          border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Programado: ${update.publishedAt != null ? DateFormat('dd/MM HH:mm').format(update.publishedAt!) : ''}',
                          style: const TextStyle(color: Colors.purple, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              update.title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              update.plainContent,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    context.push('/alerts/detail/${update.id}');
                  },
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: const Text('Ver', style: TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                  onPressed: () => _confirmDelete(context, ref, update.id),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar actualización?'),
        content: const Text(
          'Esta acción es irreversible y removerá la noticia de todos los paneles de usuario.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await ref.read(databaseServiceProvider).deleteLegalUpdate(id);
                ref.invalidate(legalUpdatesProvider);
                ref.invalidate(myDraftsProvider);
                ref.invalidate(scheduledUpdatesProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Noticia eliminada correctamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al eliminar: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdatesList(BuildContext context, WidgetRef ref, AsyncValue<List<LegalUpdate>> updatesAsync) {
    return updatesAsync.when(
      data: (updates) {
        if (updates.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'No hay publicaciones en esta categoría.',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          itemCount: updates.length,
          itemBuilder: (context, index) {
            final update = updates[index];
            return _buildAdminUpdateCard(context, ref, update);
          },
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text('Error al cargar publicaciones: $err', style: const TextStyle(color: Colors.red)),
        ),
      ),
    );
  }
}
