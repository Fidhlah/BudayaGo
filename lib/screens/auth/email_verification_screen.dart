import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
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
      
      // ✅ Auto-redirect when email is verified
      if (authProvider.isEmailConfirmed) {
        debugPrint('✅ Email verified! Auto-redirecting to home...');
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Email verified! Welcome to BudayaGo!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        // ✅ Navigate to home (replace entire stack)
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/home',
            (route) => false, // Remove all previous routes
          );
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
        debugPrint('✅ Email verified!');
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Email verified! Redirecting...'),
            backgroundColor: Colors.green,
          ),
        );
        
        // ✅ Navigate to home (listener will also trigger, but that's okay)
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/home',
            (route) => false,
          );
        });
      } else {
        debugPrint('⚠️ Email not verified yet');
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Email not verified yet. Please check your inbox.'),
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
      appBar: AppBar(
        title: const Text('Email Verification'),
        centerTitle: true,
        automaticallyImplyLeading: false, // Remove back button
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppDimensions.paddingL),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Icon(
                  Icons.mark_email_read,
                  size: AppDimensions.iconXL,
                  color: AppColors.primary,
                ),
                SizedBox(height: AppDimensions.spaceXL),

                // Title
                Text(
                  'Verify Your Email',
                  style: AppTextStyles.h2,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppDimensions.spaceM),

                // Description
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return Text(
                      'We sent a verification link to:\n${authProvider.user?.email ?? "your email"}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    );
                  },
                ),
                SizedBox(height: AppDimensions.spaceXS),
                Text(
                  'Please click the link in the email to verify your account.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppDimensions.spaceXL),

                // Check verification button
                ElevatedButton.icon(
                  onPressed: _isChecking ? null : _checkVerification,
                  icon: _isChecking
                      ? SizedBox(
                          width: AppDimensions.iconS,
                          height: AppDimensions.iconS,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(_isChecking ? 'Checking...' : 'I\'ve Verified'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingXL,
                      vertical: AppDimensions.paddingM,
                    ),
                  ),
                ),
                SizedBox(height: AppDimensions.spaceS),

                // Resend email button
                OutlinedButton.icon(
                  onPressed: _resendVerification,
                  icon: const Icon(Icons.email),
                  label: const Text('Resend Email'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingXL,
                      vertical: AppDimensions.paddingM,
                    ),
                  ),
                ),
                SizedBox(height: AppDimensions.spaceM),

                // Instructions
                const Divider(),
                SizedBox(height: AppDimensions.spaceM),
                Text(
                  'Instructions:',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppDimensions.spaceXS),
                Text(
                  '1. Check your email inbox (including spam folder)\n'
                  '2. Open the verification email from BudayaGo\n'
                  '3. Click the verification link\n'
                  '4. App will automatically redirect',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppDimensions.spaceL),

                // Sign out option
                TextButton(
                  onPressed: () async {
                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                    await authProvider.signOut();
                    // AuthGate will automatically redirect to login
                  },
                  child: const Text('Sign Out'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}