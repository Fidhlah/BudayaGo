import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

/// ✅ SERVICE LAYER: Handle all auth-related API calls
class AuthService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  /// Get current user
  User? get currentUser => _supabase.auth.currentUser;

  /// Get current session
  Session? get currentSession => _supabase.auth.currentSession;

  /// Auth state changes stream
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// ✅ Sign in with email & password
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    print('🔐 AuthService: signInWithEmail');
    print('   Email: $email');

    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// ✅ Sign up with email & password
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    print('📧 AuthService: signUpWithEmail');
    print('   Email: $email');
    print('   Username: $username');

    return await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
      emailRedirectTo:
          'budayago://auth-callback', // 🔥 FIX: Deep link untuk email verification
    );
  }

  /// ✅ Sign out
  Future<void> signOut() async {
    print('👋 AuthService: signOut');
    await _supabase.auth.signOut();
  }

  /// ✅ Refresh session
  Future<AuthResponse> refreshSession() async {
    print('🔄 AuthService: refreshSession');
    return await _supabase.auth.refreshSession();
  }

  /// ✅ Resend verification email
  Future<void> resendVerificationEmail({required String email}) async {
    print('📧 AuthService: resendVerificationEmail');
    print('   Email: $email');

    await _supabase.auth.resend(
      type: OtpType.signup,
      email: email,
      emailRedirectTo:
          'budayago://auth-callback', // 🔥 FIX: Deep link untuk email verification
    );
  }
}
