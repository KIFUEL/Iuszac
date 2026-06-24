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
  final authState = ref.watch(authStateProvider).value;
  return authState?.session?.user ?? Supabase.instance.client.auth.currentUser;
});

// Provider para obtener el perfil extendido del usuario desde la tabla 'profiles'
final userProfileProvider = FutureProvider<Profile?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  // Cargamos el perfil público del usuario desde la base de datos
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

