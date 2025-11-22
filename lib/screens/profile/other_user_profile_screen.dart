import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';

class OtherUserProfileScreen extends StatelessWidget {
  final String userName;
  final Color userColor;
  final String? location;
  final String? mascot;
  final bool isPelakuBudaya;

  const OtherUserProfileScreen({
    super.key,
    required this.userName,
    required this.userColor,
    this.location,
    this.mascot,
    this.isPelakuBudaya = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with gradient
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: userColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      userColor.withOpacity(0.8),
                      userColor.withOpacity(0.4),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: AppDimensions.spaceXL),
                      // Avatar
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.background,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Icon(Icons.person, size: 50, color: userColor),
                      ),
                      SizedBox(height: AppDimensions.spaceM),
                      // Name
                      Text(
                        userName,
                        style: AppTextStyles.h4.copyWith(
                          color: AppColors.background,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (location != null) ...[
                        SizedBox(height: AppDimensions.spaceXS),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: AppColors.background.withOpacity(0.8),
                            ),
                            SizedBox(width: 4),
                            Text(
                              location!,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.background.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Profile content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: userColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: userColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPelakuBudaya ? Icons.verified : _getMascotIcon(),
                          size: 18,
                          color: userColor,
                        ),
                        SizedBox(width: 8),
                        Text(
                          isPelakuBudaya
                              ? '✨ Pelaku Budaya'
                              : _getMascotBadgeText(),
                          style: AppTextStyles.labelMedium.copyWith(
                            color: userColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppDimensions.spaceXL),

                  // Stats
                  Center(
                    child: _buildStatColumn('12', 'Karya', Icons.art_track),
                  ),
                  SizedBox(height: AppDimensions.spaceXL),

                  // Bio
                  Text(
                    'Tentang',
                    style: AppTextStyles.h6.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppDimensions.spaceS),
                  Text(
                    'Pelaku budaya yang mencintai seni dan tradisi Nusantara. Berbagi karya untuk melestarikan budaya Indonesia.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: AppDimensions.spaceXL),

                  // Karya Section
                  Text(
                    'Karya Terbaru',
                    style: AppTextStyles.h6.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppDimensions.spaceM),

                  // List of karya cards with photo variations
                  ...List.generate(4, (index) {
                    // Variasi jumlah foto: 1, 2, 3, atau 4
                    final photoCount = (index % 4) + 1;

                    return Card(
                      margin: EdgeInsets.only(bottom: AppDimensions.spaceL),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusL,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: Creator info
                          Padding(
                            padding: EdgeInsets.all(AppDimensions.paddingM),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: userColor,
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    color: AppColors.background,
                                    size: 20,
                                  ),
                                ),
                                SizedBox(width: AppDimensions.spaceS),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        userName,
                                        style: AppTextStyles.labelLarge
                                            .copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      Text(
                                        location ?? 'Indonesia',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Photo Grid (1-4 photos)
                          _buildKaryaPhotoGrid(photoCount, userColor),

                          // Content: Title + Description
                          Padding(
                            padding: EdgeInsets.all(AppDimensions.paddingM),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textPrimary,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: '$userName ',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextSpan(text: 'Karya ${index + 1}'),
                                    ],
                                  ),
                                ),
                                SizedBox(height: AppDimensions.spaceXS),
                                Text(
                                  'Karya seni budaya yang menggambarkan keindahan tradisi Nusantara.',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Tag at bottom
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              AppDimensions.paddingM,
                              0,
                              AppDimensions.paddingM,
                              AppDimensions.paddingM,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.local_offer,
                                  size: 16,
                                  color: userColor,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  index % 2 == 0 ? 'Seni Rupa' : 'Kerajinan',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: userColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: userColor, size: 28),
        SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.h5.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  // Helper methods untuk photo grid
  Widget _buildKaryaPhotoGrid(int photoCount, Color userColor) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: ClipRRect(
        borderRadius: BorderRadius.zero,
        child: Builder(
          builder: (context) {
            switch (photoCount) {
              case 1:
                return _buildSingleKaryaPhoto(0, userColor);
              case 2:
                return _buildTwoKaryaPhotos(0, userColor);
              case 3:
                return _buildThreeKaryaPhotos(0, userColor);
              case 4:
                return _buildFourKaryaPhotos(0, userColor);
              default:
                return _buildSingleKaryaPhoto(0, userColor);
            }
          },
        ),
      ),
    );
  }

  Widget _buildSingleKaryaPhoto(int index, Color userColor) {
    return _buildKaryaPhotoPlaceholder(userColor);
  }

  Widget _buildTwoKaryaPhotos(int index, Color userColor) {
    return Row(
      children: [
        Expanded(child: _buildKaryaPhotoPlaceholder(userColor)),
        SizedBox(width: 2),
        Expanded(child: _buildKaryaPhotoPlaceholder(userColor)),
      ],
    );
  }

  Widget _buildThreeKaryaPhotos(int index, Color userColor) {
    return Row(
      children: [
        Expanded(flex: 2, child: _buildKaryaPhotoPlaceholder(userColor)),
        SizedBox(width: 2),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              Expanded(child: _buildKaryaPhotoPlaceholder(userColor)),
              SizedBox(height: 2),
              Expanded(child: _buildKaryaPhotoPlaceholder(userColor)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFourKaryaPhotos(int index, Color userColor) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildKaryaPhotoPlaceholder(userColor)),
              SizedBox(width: 2),
              Expanded(child: _buildKaryaPhotoPlaceholder(userColor)),
            ],
          ),
        ),
        SizedBox(height: 2),
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildKaryaPhotoPlaceholder(userColor)),
              SizedBox(width: 2),
              Expanded(child: _buildKaryaPhotoPlaceholder(userColor)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKaryaPhotoPlaceholder(Color userColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [userColor.withOpacity(0.6), userColor.withOpacity(0.3)],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.image,
          color: AppColors.background.withOpacity(0.7),
          size: 40,
        ),
      ),
    );
  }

  IconData _getMascotIcon() {
    switch (mascot) {
      case 'Komodo':
        return Icons.pets;
      case 'Harimau':
        return Icons.shield;
      case 'Garuda':
        return Icons.flight;
      case 'Merak':
        return Icons.auto_awesome;
      case 'Orangutan':
        return Icons.favorite;
      case 'Gajah':
        return Icons.people;
      case 'Banteng':
        return Icons.flag;
      default:
        return Icons.star;
    }
  }

  String _getMascotBadgeText() {
    return mascot ?? 'User';
  }
}
