import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Konfigurasi Supabase
class SupabaseConfig {
  // Private constructor untuk prevent instantiation
  SupabaseConfig._();

  /// Initialize Supabase
  ///
  /// Dipanggil di main() sebelum runApp()
  static Future<void> initialize() async {
    // Load .env file
    await dotenv.load(fileName: ".env");

    // Get credentials dari .env
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

    // Validate credentials
    if (supabaseUrl == null || supabaseUrl.isEmpty) {
      throw Exception('❌ SUPABASE_URL not found in .env file!');
    }

    if (supabaseAnonKey == null || supabaseAnonKey.isEmpty) {
      throw Exception('❌ SUPABASE_ANON_KEY not found in .env file!');
    }

    print('🚀 Initializing Supabase...');
    print('   URL: $supabaseUrl');
    print('   Key: ${supabaseAnonKey.substring(0, 20)}...');

    // ✅ Initialize Supabase dengan auth options
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        // ✅ PKCE flow untuk security
        authFlowType: AuthFlowType.pkce,

        // ✅ Auto refresh token
        autoRefreshToken: true,

        // ✅ IMPORTANT: Detect deep link dari email verification
        detectSessionInUri: true,
      ),
      debug: true, // Set false di production
    );

    print('✅ Supabase initialized successfully!');
  }

  /// Get Supabase client instance
  ///
  /// Usage: SupabaseConfig.client
  static SupabaseClient get client => Supabase.instance.client;

  /// Get current auth user
  ///
  /// Returns null jika belum login
  static User? get currentUser => client.auth.currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  /// Get current session
  static Session? get currentSession => client.auth.currentSession;

  /// Sign out
  static Future<void> signOut() async {
    await client.auth.signOut();
    print('👋 User signed out');
  }
}