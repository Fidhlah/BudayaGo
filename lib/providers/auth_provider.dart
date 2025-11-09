import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  bool _isLoading = true;
  String? _error;

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  bool get isEmailConfirmed => _user?.emailConfirmedAt != null;
  String? get error => _error;

  AuthProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    debugPrint('🔐 AuthProvider: Initializing...');
    
    try {
      // ✅ Get initial user
      _user = _authService.currentUser;
      debugPrint('   Initial user: ${_user?.email}');
      debugPrint('   Email confirmed: ${_user?.emailConfirmedAt != null}');
      
      // ✅ Setup deep link listener
      _setupAuthListener();
      
    } catch (e) {
      debugPrint('❌ AuthProvider initialization error: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('✅ AuthProvider: Initialized');
    }
  }

  // ✅ DEEP LINK: Listen to auth changes
  void _setupAuthListener() {
    _authService.authStateChanges.listen(
      (data) async {
        final event = data.event;
        final newUser = data.session?.user;
        
        debugPrint('🔐 AuthProvider: Auth event - $event');
        debugPrint('   New user: ${newUser?.email}');
        debugPrint('   Email confirmed: ${newUser?.emailConfirmedAt != null}');
        
        // ✅ Handle specific events
        switch (event) {
          case AuthChangeEvent.signedIn:
          case AuthChangeEvent.tokenRefreshed:
          case AuthChangeEvent.userUpdated:
            // ✅ Update user state
            final oldEmailConfirmed = _user?.emailConfirmedAt != null;
            final newEmailConfirmed = newUser?.emailConfirmedAt != null;
            
            _user = newUser;
            
            // ✅ If email just got confirmed (deep link success)
            if (!oldEmailConfirmed && newEmailConfirmed) {
              debugPrint('✅ Email verification completed via deep link!');
            }
            
            notifyListeners();
            break;
            
          case AuthChangeEvent.signedOut:
            _user = null;
            _error = null;
            debugPrint('👋 User signed out');
            notifyListeners();
            break;
            
          default:
            debugPrint('ℹ️ Auth event ignored: $event');
        }
      },
      onError: (error) {
        debugPrint('❌ Auth listener error: $error');
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  /// ✅ LOGIN: Delegate to service
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _error = null;
      notifyListeners();

      debugPrint('🔐 AuthProvider: Signing in...');
      
      final response = await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      _user = response.user;
      
      debugPrint('✅ Sign in successful');
      debugPrint('   Email confirmed: ${_user?.emailConfirmedAt != null}');
      
      notifyListeners();
      return true;

    } catch (e) {
      debugPrint('❌ Sign in error: $e');
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// ✅ REGISTER: Delegate to service
  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      _error = null;
      notifyListeners();

      debugPrint('📧 AuthProvider: Signing up...');
      
      final response = await _authService.signUpWithEmail(
        email: email,
        password: password,
        fullName: fullName,
      );

      _user = response.user;
      
      debugPrint('✅ Sign up successful');
      debugPrint('   Verification email sent to: ${_user?.email}');
      
      notifyListeners();
      return true;

    } catch (e) {
      debugPrint('❌ Sign up error: $e');
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// ✅ SIGN OUT: Delegate to service
  Future<void> signOut() async {
    try {
      debugPrint('👋 AuthProvider: Signing out...');
      
      await _authService.signOut();
      
      _user = null;
      _error = null;
      
      debugPrint('✅ Signed out');
      notifyListeners();

    } catch (e) {
      debugPrint('❌ Sign out error: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  /// ✅ REFRESH: Manually refresh session
  Future<void> refreshUser() async {
    try {
      debugPrint('🔄 AuthProvider: Refreshing user...');
      
      final response = await _authService.refreshSession();
      
      _user = response.session?.user;
      
      debugPrint('✅ User refreshed');
      debugPrint('   Email confirmed: ${_user?.emailConfirmedAt != null}');
      
      notifyListeners();

    } catch (e) {
      debugPrint('❌ Refresh error: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  /// ✅ Helper: Get user-friendly error message
  String getErrorMessage() {
    if (_error == null) return '';
    
    if (_error!.contains('Invalid login credentials')) {
      return 'Email atau password salah!';
    } else if (_error!.contains('Email not confirmed')) {
      return 'Email belum diverifikasi. Cek inbox kamu!';
    } else if (_error!.contains('User already registered')) {
      return 'Email sudah terdaftar!';
    } else if (_error!.contains('User not found')) {
      return 'Akun tidak ditemukan. Silakan register dulu.';
    } else if (_error!.contains('Too many requests')) {
      return 'Terlalu banyak percobaan. Tunggu sebentar.';
    }
    
    return _error!;
  }

  /// ✅ Helper: Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}