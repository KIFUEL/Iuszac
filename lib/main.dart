import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme.dart';
import 'core/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // TODO: Reemplazar con tus credenciales de Supabase
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
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

    return MaterialApp.router(
      title: 'Law App',
      theme: LawTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
