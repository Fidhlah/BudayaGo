import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';
import '../qr/qr_scanner_screen.dart'; // ✅ Import QR Scanner

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('BudayaGo'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Logged out successfully'),
                    backgroundColor: AppColors.warning,
                  ),
                );
              }
            },
          ),
          // ✅ TAMBAH TOMBOL QR SCANNER DI SINI
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const QRScannerScreen(),
                ),
              );

              // Handle hasil scan
              if (result != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('QR Code: $result')),
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                size: AppDimensions.iconXL * 1.67, // 80px
                color: AppColors.success,
              ),
              SizedBox(height: AppDimensions.spaceL),
              Text(
                'Welcome to BudayaGo!',
                style: AppTextStyles.h3,
              ),
              SizedBox(height: AppDimensions.spaceM),
              Text(
                'Email: ${user?.email ?? "Unknown"}',
                style: AppTextStyles.bodyMedium,
              ),
              SizedBox(height: AppDimensions.spaceXS),
              Text(
                'User ID: ${user?.id ?? "Unknown"}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: AppDimensions.spaceXXL),

              SizedBox(height: AppDimensions.spaceM),

              ElevatedButton.icon(
                onPressed: () async {
                  await authProvider.signOut();
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingXL,
                    vertical: AppDimensions.paddingM,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      
    );
  }
}