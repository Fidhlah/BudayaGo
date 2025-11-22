import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/supabase_config.dart';
import 'providers/auth_provider.dart';
import 'providers/qr_provider.dart';
import 'providers/character-matcher_provider.dart' as character_matcher;
import 'providers/home_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/chatbot_provider.dart';
import 'theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/email_verification_screen.dart';
import 'screens/main/main_screen.dart';
import 'screens/personality_test/personality_test_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => QrProvider()),
        ChangeNotifierProvider(
          create: (_) => character_matcher.PersonalityTestProvider(),
        ),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => ChatbotProvider()),
      ],
      child: MaterialApp(
        title: 'BudayaGo',
        debugShowCheckedModeBanner: false,

        // ✅ USE SINGLE THEME
        theme: AppTheme.theme,

        // 🔒 PRODUCTION MODE - Normal authentication flow
        home: const AuthGate(),

        // ⚠️ TESTING MODE - Uncomment untuk langsung ke Personality Test
        // home: const PersonalityTestScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/verify-email': (context) => const EmailVerificationScreen(),
          '/home': (context) => const MainScreen(),
        },
      ),
    );
  }
}

// ✅ FIXED: AuthGate - Check auth state AND personality test completion
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isCheckingCharacter = true;
  bool _hasCharacter = false;
  String? _lastCheckedUserId;
  bool _lastEmailConfirmed = false;

  @override
  void initState() {
    super.initState();
    debugPrint('🔧 AuthGate initState');
    _checkUserCharacter();
  }

  Future<void> _checkUserCharacter() async {
    final user = SupabaseConfig.currentUser;

    if (user == null) {
      if (mounted) {
        setState(() {
          _isCheckingCharacter = false;
          _hasCharacter = false;
          _lastCheckedUserId = null;
        });
      }
      return;
    }

    // Skip check if we already checked this user
    if (_lastCheckedUserId == user.id) {
      debugPrint('👤 Already checked user ${user.id}, skipping...');
      return;
    }

    // Mark as checking for new user
    if (mounted) {
      setState(() {
        _isCheckingCharacter = true;
        _lastCheckedUserId = user.id;
      });
    }

    try {
      debugPrint('👤 Checking user character...');
      debugPrint('   User ID: ${user.id}');
      debugPrint('   User Email: ${user.email}');

      // Retry logic for new users (trigger might take a moment)
      int attempts = 0;
      Map<String, dynamic>? response;

      while (attempts < 3) {
        response =
            await SupabaseConfig.client
                .from('users')
                .select('character_id, email, username')
                .eq('id', user.id)
                .maybeSingle();

        if (response != null) break;

        attempts++;
        if (attempts < 3) {
          debugPrint(
            '   User not found in public.users, retrying... ($attempts/3)',
          );
          await Future.delayed(Duration(milliseconds: 500 * attempts));
        }
      }

      debugPrint('   Response from DB: $response');
      debugPrint('   Character ID: ${response?['character_id']}');
      debugPrint('   Has Character: ${response?['character_id'] != null}');

      if (mounted) {
        setState(() {
          _hasCharacter = response?['character_id'] != null;
          _isCheckingCharacter = false;
        });
        debugPrint('   State updated: _hasCharacter=$_hasCharacter');
      }
    } catch (e) {
      debugPrint('❌ Error checking character: $e');
      if (mounted) {
        setState(() {
          _hasCharacter = false;
          _isCheckingCharacter = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🔍 AuthGate build() called');

    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.user;
        final emailConfirmed = authProvider.isEmailConfirmed;

        debugPrint('🔍 Consumer builder - user: ${user?.email ?? "null"}');
        debugPrint('   Last checked: $_lastCheckedUserId, New: ${user?.id}');
        debugPrint(
          '   Email confirmed: $emailConfirmed (was: $_lastEmailConfirmed)',
        );

        // ✅ Check if user changed OR email confirmation status changed
        if (user?.id != _lastCheckedUserId ||
            emailConfirmed != _lastEmailConfirmed) {
          debugPrint(
            '🔄 User or email status changed, triggering character check',
          );
          // Schedule check for next frame to avoid setState during build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _lastEmailConfirmed = emailConfirmed;
              _checkUserCharacter();
            }
          });
        }

        // ✅ User is logged out
        if (user == null) {
          debugPrint('🔄 AuthGate - User logged out');
          debugPrint('→ Showing LoginScreen');
          return const LoginScreen();
        }

        // ✅ Debug logs
        debugPrint('🔄 AuthGate - Building UI...');
        debugPrint('   Loading: ${authProvider.isLoading}');
        debugPrint('   User: ${authProvider.user?.email}');
        debugPrint('   Email Confirmed: ${authProvider.isEmailConfirmed}');
        debugPrint('   Checking Character: $_isCheckingCharacter');
        debugPrint('   Has Character: $_hasCharacter');

        // ✅ Loading state
        if (authProvider.isLoading || _isCheckingCharacter) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading...'),
                ],
              ),
            ),
          );
        }

        // ✅ Determine screen based on auth state
        if (!authProvider.isEmailConfirmed) {
          // Logged in but email not verified
          debugPrint('→ Showing EmailVerificationScreen');
          return const EmailVerificationScreen();
        } else if (!_hasCharacter) {
          // Logged in & verified but no character assigned
          debugPrint('→ Showing PersonalityTestScreen');
          return const PersonalityTestScreen();
        } else {
          // Logged in, verified, and has character
          debugPrint('→ Showing MainScreen');
          return const MainScreen();
        }
      },
    );
  }
}
