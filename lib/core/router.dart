import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../views/home/home_view.dart';
import '../views/forum/forum_view.dart';
import '../views/forum/new_post_view.dart';
import '../views/forum/post_detail_view.dart';
import '../views/alerts/alerts_view.dart';
import '../views/alerts/reform_detail_view.dart';
import '../views/mentorship/mentorship_view.dart';
import '../views/mentorship/mentorship_detail_view.dart';
import '../views/mentorship/new_mentorship_view.dart';
import '../views/profile/profile_view.dart';
import '../views/profile/settings_view.dart';
import '../views/auth/login_view.dart';
import '../views/auth/register_view.dart';
import '../views/auth/splash_view.dart';
import '../views/codes/codes_list_view.dart';
import '../views/codes/article_detail_view.dart';
import '../views/search/global_search_view.dart';
import '../widgets/main_layout.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable:
        GoRouterRefreshStream(Supabase.instance.client.auth.onAuthStateChange),
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
            builder: (context, state) => const AlertsView(),
            routes: [
              GoRoute(
                path: 'detail/:id',
                builder: (context, state) {
                  final alertId = state.pathParameters['id']!;
                  return ReformDetailView(alertId: alertId);
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
                path: 'settings',
                builder: (context, state) => const SettingsView(),
              ),
            ],
          ),
          GoRoute(
            path: '/codes',
            builder: (context, state) => const CodesListView(),
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
        ],
      ),
    ],
  );
});
