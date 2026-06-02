import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../views/home/home_view.dart';
import '../views/forum/forum_view.dart';
import '../views/mentorship/mentorship_view.dart';
import '../views/profile/profile_view.dart';
import '../widgets/main_layout.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
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
          ),
          GoRoute(
            path: '/mentorship',
            builder: (context, state) => const MentorshipView(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileView(),
          ),
        ],
      ),
    ],
  );
});
