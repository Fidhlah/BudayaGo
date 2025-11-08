import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Ambil user sekarang
  User? getCurrentUser(){ return _supabase.auth.currentUser;}

  // Lagi login?
  bool isLoggedIn(){ return _supabase.auth.currentUser != null;}

  // Daftar dengan email & password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async{
    return await _supabase.auth.signUp(
      email: email,
      password: password,
    );
  }

  // Masuk dengan email & password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Listen to auth state changes
  Stream<AuthState> get authStateChanges {
    return _supabase.auth.onAuthStateChange;
  }

}
