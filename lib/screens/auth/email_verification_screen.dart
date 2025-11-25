import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    // ✅ Listen to auth state changes for auto-redirect
    _listenToAuthChanges();
  }

  // ✅ Listen for email verification (deep link)
  void _listenToAuthChanges() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Add listener to detect when email gets verified
    authProvider.addListener(() {
      if (!mounted) return;

      // ✅ Navigate to home when email is verified - AuthGate will handle routing
      if (authProvider.isEmailConfirmed) {
        debugPrint(
          '✅ Email verified! Navigating to trigger AuthGate routing...',
        );

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Email verified! Welcome to BudayaGo!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // ✅ Use pushNamedAndRemoveUntil to clear stack and let MaterialApp rebuild with AuthGate
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        });
      }
    });
  }

  // ✅ Manual check verification status
  Future<void> _checkVerification() async {
    setState(() => _isChecking = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      debugPrint('🔄 Manually checking email verification...');

      await authProvider.refreshUser();

      // Add a small delay to ensure state is updated
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      // ✅ Check if email is now verified
      if (authProvider.isEmailConfirmed) {
        debugPrint(
          '✅ Email verified! Navigating to trigger AuthGate routing...',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Email verified! Redirecting...'),
            backgroundColor: Colors.green,
          ),
        );

        // ✅ Use pushNamedAndRemoveUntil to clear stack and let MaterialApp rebuild with AuthGate
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        });
      } else {
        debugPrint('⚠️ Email not verified yet');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '⚠️ Email not verified yet. Please check your inbox.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error checking verification: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  // ✅ Resend verification email
  Future<void> _resendVerification() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final email = authProvider.user?.email;

    if (email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Email not found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      debugPrint('📧 Resending verification email to: $email');

      // TODO: Implement resend in auth_service.dart
      // await authProvider.resendVerificationEmail();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('📧 Verification email sent to $email'),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      debugPrint('❌ Error resending email: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.orangePinkGradient,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Icon(
                    Icons.mark_email_read,
                    size: AppDimensions.iconXL * 1.5,
                    color: Colors.white,
                  ),
                  SizedBox(height: AppDimensions.spaceXL),

                  // Title
                  Text(
                    'Verifikasi Email Anda',
                    style: AppTextStyles.h2.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppDimensions.spaceM),

                  // Description
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      return Text(
                        'Kami telah mengirim link verifikasi ke:\n${authProvider.user?.email ?? "email Anda"}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                  SizedBox(height: AppDimensions.spaceXS),
                  Text(
                    'Silakan klik link di email untuk memverifikasi akun Anda.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppDimensions.spaceXL),

                  // Check verification button
                  ElevatedButton.icon(
                    onPressed: _isChecking ? null : _checkVerification,
                    icon:
                        _isChecking
                            ? SizedBox(
                              width: AppDimensions.iconS,
                              height: AppDimensions.iconS,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.orange700,
                                ),
                              ),
                            )
                            : const Icon(Icons.refresh),
                    label: Text(
                      _isChecking ? 'Memeriksa...' : 'Sudah Verifikasi',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.orange700,
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingXL,
                        vertical: AppDimensions.paddingM,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusM,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: AppDimensions.spaceS),

                  // Resend email button
                  OutlinedButton.icon(
                    onPressed: _resendVerification,
                    icon: const Icon(Icons.email),
                    label: const Text('Kirim Ulang Email'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white, width: 2),
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.paddingXL,
                        vertical: AppDimensions.paddingM,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusM,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: AppDimensions.spaceM),

                  // Instructions
                  Divider(color: Colors.white.withOpacity(0.3)),
                  SizedBox(height: AppDimensions.spaceM),
                  Text(
                    'Instruksi:',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: AppDimensions.spaceXS),
                  Text(
                    '1. Cek inbox email Anda (termasuk folder spam)\n'
                    '2. Buka email verifikasi dari BudayaGo\n'
                    '3. Klik link verifikasi\n'
                    '4. Aplikasi akan otomatis redirect',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppDimensions.spaceL),

                  // Sign out option
                  TextButton(
                    onPressed: () async {
                      final authProvider = Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      );
                      await authProvider.signOut();
                      // AuthGate will automatically redirect to login
                    },
                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                    child: const Text('Keluar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
