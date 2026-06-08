import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/profile.dart';

// Provider para el servicio de autenticación
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// StreamProvider para vigilar el estado de la sesión en tiempo real
final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// Provider para obtener los datos del usuario actual de Supabase Auth
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authServiceProvider).currentUser;
});

// Provider para obtener el perfil extendido del usuario desde la tabla 'profiles'
final userProfileProvider = FutureProvider<Profile?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  try {
    // 1. Validar activamente con el servidor que la cuenta siga existiendo y sea válida.
    // Esto previene que usuarios borrados sigan navegando con una sesión local "fantasma".
    await Supabase.instance.client.auth.getUser();
  } catch (e) {
    // Si el servidor rechaza el token (ej. usuario eliminado o baneado), destruimos la sesión local.
    await Supabase.instance.client.auth.signOut();
    return null;
  }

  // 2. Si el usuario es válido en el servidor, cargamos su perfil público.
  final response = await Supabase.instance.client
      .from('profiles')
      .select()
      .eq('id', user.id)
      .maybeSingle();

  if (response == null) return null;
  return Profile.fromJson(response);
});

// Provider para actualizar el perfil del usuario actual
final profileUpdateProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

