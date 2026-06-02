import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme.dart';
import 'core/router.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://cnzjucawwpswdwpxbtmj.supabase.co',
    anonKey: 'sb_publishable_vPBj4ExScRtYyL7KfyPkTw_Aj51j-tR',
  );

  runApp(
    const ProviderScope(
      child: LawApp(),
    ),
  );
}

class LawApp extends ConsumerWidget {
  const LawApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'LawApp',
      theme: LawTheme.lightTheme,
      darkTheme: LawTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
