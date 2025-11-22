import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';

class UpgradeToPelakuBudayaDialog extends StatelessWidget {
  const UpgradeToPelakuBudayaDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Upgrade ke Pelaku Budaya', style: AppTextStyles.h5),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dengan menjadi Pelaku Budaya, kamu dapat:',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppDimensions.spaceM),
          _buildBenefit(Icons.upload, 'Upload hasil karya budaya'),
          _buildBenefit(Icons.visibility, 'Showcase karya di profilmu'),
          _buildBenefit(Icons.people, 'Terhubung dengan pelaku budaya lain'),
          _buildBenefit(Icons.star, 'Dapatkan apresiasi dari komunitas'),
          SizedBox(height: AppDimensions.spaceM),
          Text(
            'Apakah kamu yakin ingin menjadi Pelaku Budaya?',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Batal',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            final profileProvider = Provider.of<ProfileProvider>(
              context,
              listen: false,
            );

            // Show loading
            showDialog(
              context: context,
              barrierDismissible: false,
              builder:
                  (context) => const Center(child: CircularProgressIndicator()),
            );

            await profileProvider.upgradeToPelakuBudaya();

            if (context.mounted) {
              // Close loading dialog
              Navigator.pop(context);
              // Close upgrade dialog
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Selamat! Kamu sekarang Pelaku Budaya 🎉',
                  ),
                  backgroundColor: AppColors.success,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.batik700,
            foregroundColor: AppColors.background,
          ),
          child: const Text('Ya, Upgrade Sekarang'),
        ),
      ],
    );
  }

  Widget _buildBenefit(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppDimensions.spaceXS),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.batik700),
          SizedBox(width: AppDimensions.spaceS),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
