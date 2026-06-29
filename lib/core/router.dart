import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../views/home/home_view.dart';
import '../views/forum/forum_view.dart';
import '../views/forum/new_post_view.dart';
import '../views/forum/post_detail_view.dart';
import '../views/alerts/alerts_view.dart';
import '../views/alerts/content_detail_wrapper.dart';
import '../views/mentorship/mentorship_view.dart';
import '../views/mentorship/mentorship_detail_view.dart';
import '../views/mentorship/new_mentorship_view.dart';
import '../views/profile/profile_view.dart';
import '../views/profile/edit_profile_view.dart';
import '../views/profile/notification_settings_view.dart';
import '../views/profile/security_settings_view.dart';
import '../views/profile/about_project_view.dart';
import '../views/auth/login_view.dart';
import '../views/auth/register_view.dart';
import '../views/auth/splash_view.dart';
import '../views/auth/suspended_view.dart';
import '../views/codes/codes_list_view.dart';
import '../views/codes/articles_list_view.dart';
import '../views/codes/article_detail_view.dart';
import '../views/search/global_search_view.dart';
import '../views/admin/admin_dashboard_view.dart';
import '../views/admin/content_manager_view.dart';
import '../views/admin/new_publication_view.dart';
import '../views/admin/admin_users_view.dart';
import '../views/admin/admin_moderation_view.dart';
import '../views/admin/admin_suspend_view.dart';
import '../widgets/main_layout.dart';
import '../providers/auth_provider.dart';
import '../models/profile.dart';
import '../models/publication.dart';

class RouterRefreshNotifier extends ChangeNotifier {
  void refresh() {
    notifyListeners();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = RouterRefreshNotifier();
  
  final authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((_) {
    refreshNotifier.refresh();
  });
  
  ref.listen<AsyncValue<Profile?>>(userProfileProvider, (previous, next) {
    refreshNotifier.refresh();
  });
  
  ref.onDispose(() {
    authSubscription.cancel();
    refreshNotifier.dispose();
  });

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/splash';

      if (session == null) {
        return isAuthRoute ? null : '/splash';
      }

      if (isAuthRoute) {
        return '/';
      }

      // Check suspension and role guards
      final profileAsync = ref.read(userProfileProvider);
      final profile = profileAsync.value;

      if (profile != null) {
        if (profile.isActivelySuspended) {
          if (state.matchedLocation != '/suspended') {
            return '/suspended';
          }
          return null;
        } else {
          if (state.matchedLocation == '/suspended') {
            return '/';
          }
        }

        // Check admin routes
        if (state.matchedLocation.startsWith('/admin/new-update')) {
          if (!profile.canPublish) return '/';
        } else if (state.matchedLocation.startsWith('/admin/moderation')) {
          if (!profile.canModerate) return '/';
        } else if (state.matchedLocation.startsWith('/admin/mentors') || state.matchedLocation.startsWith('/admin/suspend') || state.matchedLocation.startsWith('/admin/users')) {
          if (!profile.canManageUsers) return '/';
        } else if (state.matchedLocation.startsWith('/admin')) {
          if (!profile.canPublish && !profile.canModerate && !profile.canManageUsers) return '/';
        }

        // Check mentor routes
        if (state.matchedLocation.startsWith('/mentorship/new') || state.matchedLocation.startsWith('/mentorship/edit')) {
          if (!profile.canMentor) {
            return '/mentorship';
          }
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashView(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterView(),
      ),
      GoRoute(
        path: '/suspended',
        builder: (context, state) => const SuspendedView(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeView(),
          ),
          GoRoute(
            path: '/forum',
            builder: (context, state) => const ForumView(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => const NewPostView(),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final postId = state.pathParameters['id']!;
                  return PostDetailView(postId: postId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/alerts',
            builder: (context, state) {
              final type = state.uri.queryParameters['type'];
              return AlertsView(filterType: type);
            },
            routes: [
              GoRoute(
                path: 'detail/:id',
                builder: (context, state) {
                  final alertId = state.pathParameters['id']!;
                  return ContentDetailWrapper(updateId: alertId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/mentorship',
            builder: (context, state) => const MentorshipView(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => const NewMentorshipView(),
              ),
              GoRoute(
                path: 'edit/:id',
                builder: (context, state) {
                  final sessionId = state.pathParameters['id']!;
                  return NewMentorshipView(sessionId: sessionId);
                },
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final sessionId = state.pathParameters['id']!;
                  return MentorshipDetailView(sessionId: sessionId);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileView(),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (context, state) => const EditProfileView(),
              ),
              GoRoute(
                path: 'notifications',
                builder: (context, state) => const NotificationSettingsView(),
              ),
              GoRoute(
                path: 'security',
                builder: (context, state) => const SecuritySettingsView(),
              ),
              GoRoute(
                path: 'about',
                builder: (context, state) => const AboutProjectView(),
              ),
            ],
          ),
          GoRoute(
            path: '/codes',
            builder: (context, state) => const CodesListView(),
            routes: [
              GoRoute(
                path: ':codeId',
                builder: (context, state) {
                  final codeId = state.pathParameters['codeId']!;
                  final codeName = state.uri.queryParameters['name'] ?? 'Artículos';
                  return ArticlesListView(codeId: codeId, codeName: codeName);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/article/:id',
            builder: (context, state) {
              final articleId = state.pathParameters['id']!;
              return ArticleDetailView(articleId: articleId);
            },
          ),
          GoRoute(
            path: '/search',
            builder: (context, state) => const GlobalSearchView(),
          ),
          GoRoute(
            path: '/admin',
            builder: (context, state) => const AdminDashboardView(),
            routes: [
              GoRoute(
                path: 'content-manager',
                builder: (context, state) => const ContentManagerView(),
              ),
              GoRoute(
                path: 'new-update',
                builder: (context, state) => const NewPublicationView(),
              ),
              GoRoute(
                path: 'edit-update/:id',
                builder: (context, state) {
                  final update = state.extra as Publication?;
                  return NewPublicationView(existingUpdate: update);
                },
              ),
              GoRoute(
                path: 'users',
                builder: (context, state) => const AdminUsersView(),
              ),
              GoRoute(
                path: 'moderation',
                builder: (context, state) => const AdminModerationView(),
              ),
              GoRoute(
                path: 'suspend/:userId',
                builder: (context, state) {
                  final userId = state.pathParameters['userId']!;
                  return AdminSuspendView(userId: userId);
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

