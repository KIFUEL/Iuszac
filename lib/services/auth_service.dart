import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Obtener el usuario actual
  User? get currentUser => _supabase.auth.currentUser;

  // Escuchar cambios en el estado de autenticación (Login/Logout)
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Registro con Email y Contraseña
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
      },
    );
  }

  // Inicio de Sesión
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Cerrar Sesión
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Recuperar contraseña
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }
}
