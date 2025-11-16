import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'providers/auth_provider.dart';
import 'providers/qr_provider.dart';
import 'theme/app_theme.dart'; // ✅ Import single theme
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/email_verification_screen.dart';
import 'screens/home/home_screen.dart';

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
      ],
      child: MaterialApp(
        title: 'BudayaGo',
        debugShowCheckedModeBanner: false,
        
        // ✅ USE SINGLE THEME
        theme: AppTheme.theme,
        
        home: const AuthGate(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/verify-email': (context) => const EmailVerificationScreen(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}

// ✅ FIXED: AuthGate - Reactive to provider changes only
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // ✅ Debug logs
        debugPrint('🔄 AuthGate - Building UI...');
        debugPrint('   Loading: ${authProvider.isLoading}');
        debugPrint('   User: ${authProvider.user?.email}');
        debugPrint('   Email Confirmed: ${authProvider.isEmailConfirmed}');

        // ✅ Loading state
        if (authProvider.isLoading) {
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
        final user = authProvider.user;
        
        if (user == null) {
          // Not logged in
          debugPrint('→ Showing LoginScreen');
          return const LoginScreen();
        } else if (!authProvider.isEmailConfirmed) {
          // Logged in but email not verified
          debugPrint('→ Showing EmailVerificationScreen');
          return const EmailVerificationScreen();
        } else {
          // Logged in & email verified
          debugPrint('→ Showing HomeScreen');
          return const HomeScreen();
        }
      },
    );
  }
}
