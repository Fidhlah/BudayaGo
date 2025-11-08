import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null && isEmailConfirmed;  // ✅ UBAH INI
  bool get isEmailConfirmed => _user?.emailConfirmedAt != null;  // ✅ TAMBAH INI
  String? get errorMessage => _errorMessage;

  // Constructor - Listen to auth changes
  AuthProvider() {
    _user = _authService.getCurrentUser();
    
    // Auto-update saat auth state berubah
    _authService.authStateChanges.listen((data) {
      _user = data.session?.user;
      notifyListeners();
    });
  }

  // Sign Up
  Future<bool> signUp(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _authService.signUp(
        email: email,
        password: password,
      );

      _user = response.user;
      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign In
  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _authService.signIn(
        email: email,
        password: password,
      );

      _user = response.user;
      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}