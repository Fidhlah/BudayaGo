import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ✅ SIMPLIFIED: UI hanya call provider
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // ✅ CLEAN: Just call provider method
    final success = await authProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    // ✅ Handle result
    if (success) {
      // ✅ Navigation based on state
      if (authProvider.isEmailConfirmed) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/verify-email');
      }
    } else {
      // ✅ Show error from provider
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.getErrorMessage()),
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
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo/Icon
                    Icon(
                      Icons.account_circle,
                      size: AppDimensions.iconXL * 2,
                      color: Colors.white,
                    ),
                    const SizedBox(height: AppDimensions.spaceXL),

                    // Title
                    Text(
                      'Selamat Datang Kembali!',
                      style: AppTextStyles.h2.copyWith(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.spaceXS),
                    Text(
                      'Masuk untuk melanjutkan',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.spaceXL),

                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: AppColors.textSecondary),
                        hintText: 'email.anda@example.com',
                        hintStyle: TextStyle(color: AppColors.textHint),
                        prefixIcon: Icon(
                          Icons.email,
                          color: AppColors.orange700,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusM,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusM,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.orange700,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusM,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email tidak boleh kosong';
                        }
                        if (!value.contains('@')) {
                          return 'Email tidak valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppDimensions.spaceM),

                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: AppColors.textSecondary),
                        hintText: 'Masukkan password Anda',
                        hintStyle: TextStyle(color: AppColors.textHint),
                        prefixIcon: Icon(
                          Icons.lock,
                          color: AppColors.orange700,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: AppColors.orange700,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusM,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusM,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.orange700,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusM,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password tidak boleh kosong';
                        }
                        if (value.length < 6) {
                          return 'Password minimal 6 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppDimensions.spaceL),

                    // Login Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.orange700,
                        minimumSize: const Size(
                          double.infinity,
                          AppDimensions.buttonHeightM,
                        ),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusM,
                          ),
                        ),
                      ),
                      child:
                          _isLoading
                              ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.orange700,
                                  ),
                                ),
                              )
                              : const Text(
                                'Masuk',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                    const SizedBox(height: AppDimensions.spaceM),

                    // Register Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Belum punya akun? ',
                          style: TextStyle(color: Colors.white),
                        ),
                        TextButton(
                          onPressed:
                              _isLoading
                                  ? null
                                  : () {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/register',
                                    );
                                  },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: const Text('Daftar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
