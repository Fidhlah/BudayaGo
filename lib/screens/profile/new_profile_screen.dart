import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/home_provider.dart';
import '../../providers/profile_provider.dart';
import '../../config/supabase_config.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';
import '../../widgets/edit_display_name_dialog.dart';
import '../../widgets/upgrade_pelaku_budaya_dialog.dart';
import '../karya/upload_karya_screen.dart';

class NewProfileScreen extends StatefulWidget {
  final String mascot;

  const NewProfileScreen({Key? key, required this.mascot}) : super(key: key);

  @override
  State<NewProfileScreen> createState() => _NewProfileScreenState();
}

class _NewProfileScreenState extends State<NewProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _collectibles = [];
  bool _isLoadingCollectibles = true;

  @override
  void initState() {
    super.initState();
    // Always create 2 tabs: Progress & Karya
    _tabController = TabController(length: 2, vsync: this);
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final userId = SupabaseConfig.currentUser?.id;
    if (userId == null) return;

    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );

    // Load profile if not already loaded
    if (!profileProvider.hasProfile) {
      await profileProvider.loadProfile(userId);
    }

    // Load collectibles
    await profileProvider.loadCollectibles();

    if (mounted) {
      setState(() {
        _collectibles =
            profileProvider.collectibles
                .map(
                  (c) => {
                    'id': c.id,
                    'name': c.name,
                    'category': c.category,
                    'imageUrl': c.imageUrl,
                    'xpEarned': c.xpEarned,
                    'unlocked': true,
                  },
                )
                .toList();
        _isLoadingCollectibles = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  IconData _getMascotIcon() {
    switch (widget.mascot) {
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

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, _) {
        final profile = profileProvider.profile;
        final isPelakuBudaya = profile?.isPelakuBudaya ?? false;
        final hideProgress = profile?.hideProgress ?? false;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Profil Saya'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => EditDisplayNameDialog(
                          currentName:
                              profile?.displayName ?? 'Penjelajah Budaya',
                        ),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Profile Header
              _buildProfileHeader(
                context,
                profile,
                isPelakuBudaya,
                hideProgress,
              ),

              // Tabs: Progress & Karya (if pelaku budaya)
              TabBar(
                controller: _tabController,
                labelColor: AppColors.batik700,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.batik700,
                dividerColor: AppColors.batik700,
                tabs: [
                  const Tab(text: 'Progress'),
                  const Tab(text: 'Karya Saya'),
                ],
              ),

              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildProgressTab(),
                    isPelakuBudaya
                        ? _buildShowcaseTab(profile!)
                        : _buildUpgradePrompt(),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton:
              isPelakuBudaya
                  ? FloatingActionButton.extended(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UploadKaryaScreen(),
                        ),
                      );
                    },
                    backgroundColor: AppColors.batik700,
                    icon: const Icon(Icons.add),
                    label: const Text('Upload Karya'),
                  )
                  : null,
        );
      },
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    UserProfile? profile,
    bool isPelakuBudaya,
    bool hideProgress,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: AppColors.orangePinkGradient),
      ),
      child: Column(
        children: [
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
            child: Icon(
              _getMascotIcon(),
              size: AppDimensions.iconXL,
              color: AppColors.batik700,
            ),
          ),
          SizedBox(height: AppDimensions.spaceM),

          // Display Name
          Text(
            profile?.displayName ?? 'Penjelajah Budaya',
            style: AppTextStyles.h4.copyWith(color: AppColors.background),
          ),
          SizedBox(height: AppDimensions.spaceXS),

          // Badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingS,
              vertical: AppDimensions.paddingXS,
            ),
            decoration: BoxDecoration(
              color: AppColors.background.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            child: Text(
              isPelakuBudaya ? '✨ Pelaku Budaya' : widget.mascot,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.background,
              ),
            ),
          ),

          // Progress Bar (if not hidden and not pelaku budaya with hide option)
          if (!hideProgress) ...[
            SizedBox(height: AppDimensions.spaceL),
            Consumer<HomeProvider>(
              builder: (context, homeProvider, _) {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Level ${homeProvider.userLevel}',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.background,
                          ),
                        ),
                        Text(
                          '${homeProvider.userXP}/${homeProvider.xpForNextLevel} XP',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.background.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppDimensions.spaceXS),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusM,
                      ),
                      child: LinearProgressIndicator(
                        value: homeProvider.progressToNextLevel,
                        minHeight: 10,
                        backgroundColor: AppColors.background.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.background,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],

          // Hide Progress Toggle (for Pelaku Budaya)
          if (isPelakuBudaya) ...[
            SizedBox(height: AppDimensions.spaceM),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Sembunyikan Progress',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.background,
                  ),
                ),
                SizedBox(width: AppDimensions.spaceS),
                Theme(
                  data: ThemeData(useMaterial3: false),
                  child: Switch(
                    value: hideProgress,
                    onChanged: (value) {
                      final provider = Provider.of<ProfileProvider>(
                        context,
                        listen: false,
                      );
                      provider.updateProfile(hideProgress: value);
                    },
                    activeColor: AppColors.batik700,
                    inactiveThumbColor: AppColors.grey400,
                    activeTrackColor: AppColors.batik200,
                    inactiveTrackColor: AppColors.grey200,
                  ),
                ),
              ],
            ),
          ],

          // Upgrade Button (if not pelaku budaya)
          if (!isPelakuBudaya) ...[
            SizedBox(height: AppDimensions.spaceM),
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const UpgradeToPelakuBudayaDialog(),
                );
              },
              icon: const Icon(Icons.upgrade),
              label: const Text('Jadi Pelaku Budaya'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.background,
                foregroundColor: AppColors.batik700,
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingL,
                  vertical: AppDimensions.paddingS,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressTab() {
    // Achievements hardcoded (bisa diintegrasikan dengan database nanti)
    final achievements = [
      {
        'name': 'Penjelajah Pemula',
        'desc': 'Selesaikan 5 eksplorasi',
        'icon': Icons.explore,
        'unlocked': true,
      },
      {
        'name': 'Kolektor Budaya',
        'desc': 'Kumpulkan 3 artifact',
        'icon': Icons.collections,
        'unlocked': _collectibles.length >= 3,
      },
      {
        'name': 'Master Budaya',
        'desc': 'Capai level 10',
        'icon': Icons.workspace_premium,
        'unlocked': false,
      },
      {
        'name': 'Pecinta Seni',
        'desc': 'Scan 10 QR lokasi',
        'icon': Icons.qr_code_scanner,
        'unlocked': false,
      },
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Koleksi Artifacts Section
          Text(
            'Koleksi Artifact',
            style: AppTextStyles.h5.copyWith(color: AppColors.textPrimary),
          ),
          SizedBox(height: AppDimensions.spaceM),
          _isLoadingCollectibles
              ? const Center(child: CircularProgressIndicator())
              : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _collectibles.isEmpty ? 5 : _collectibles.length,
                itemBuilder: (context, index) {
                  if (_collectibles.isEmpty || index >= _collectibles.length) {
                    // Show locked placeholders
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.grey100,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusM,
                        ),
                        border: Border.all(color: AppColors.grey300),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock, size: 40, color: AppColors.grey400),
                          SizedBox(height: AppDimensions.spaceXS),
                          Text(
                            'Locked',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  final collectible = _collectibles[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.batik50,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusM,
                      ),
                      border: Border.all(color: AppColors.batik300),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star, size: 40, color: AppColors.batik700),
                        SizedBox(height: AppDimensions.spaceXS),
                        Text(
                          collectible['name'],
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
          SizedBox(height: AppDimensions.spaceXL),

          // Achievements Section
          Text(
            'Pencapaian',
            style: AppTextStyles.h5.copyWith(color: AppColors.textPrimary),
          ),
          SizedBox(height: AppDimensions.spaceM),
          ...achievements.map((achievement) {
            final unlocked = achievement['unlocked'] as bool;
            return Container(
              margin: EdgeInsets.only(bottom: AppDimensions.spaceM),
              padding: EdgeInsets.all(AppDimensions.paddingM),
              decoration: BoxDecoration(
                color: unlocked ? AppColors.batik50 : AppColors.grey50,
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                border: Border.all(
                  color: unlocked ? AppColors.batik300 : AppColors.grey200,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: unlocked ? AppColors.batik700 : AppColors.grey300,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      achievement['icon'] as IconData,
                      color: AppColors.background,
                      size: 30,
                    ),
                  ),
                  SizedBox(width: AppDimensions.spaceM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          achievement['name'] as String,
                          style: AppTextStyles.labelLarge.copyWith(
                            color:
                                unlocked
                                    ? AppColors.textPrimary
                                    : AppColors.textTertiary,
                          ),
                        ),
                        SizedBox(height: AppDimensions.spaceXS),
                        Text(
                          achievement['desc'] as String,
                          style: AppTextStyles.bodySmall.copyWith(
                            color:
                                unlocked
                                    ? AppColors.textSecondary
                                    : AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (unlocked)
                    Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 30,
                    ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildShowcaseTab(UserProfile profile) {
    if (profile.uploadedKaryaIds.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.art_track,
              size: AppDimensions.iconXL * 2,
              color: AppColors.grey300,
            ),
            SizedBox(height: AppDimensions.spaceL),
            Text(
              'Belum ada karya',
              style: AppTextStyles.h5.copyWith(color: AppColors.textSecondary),
            ),
            SizedBox(height: AppDimensions.spaceS),
            Text(
              'Upload karya pertamamu!',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(AppDimensions.paddingM),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: profile.uploadedKaryaIds.length,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.batik300, AppColors.batik700],
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image, size: 60, color: AppColors.background),
              SizedBox(height: AppDimensions.spaceS),
              Text(
                'Karya ${index + 1}',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.background,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUpgradePrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline,
            size: AppDimensions.iconXL * 2,
            color: AppColors.grey300,
          ),
          SizedBox(height: AppDimensions.spaceL),
          Text(
            'Fitur Pelaku Budaya',
            style: AppTextStyles.h5.copyWith(color: AppColors.textSecondary),
          ),
          SizedBox(height: AppDimensions.spaceS),
          Text(
            'Upgrade untuk showcase karyamu',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          SizedBox(height: AppDimensions.spaceL),
          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const UpgradeToPelakuBudayaDialog(),
              );
            },
            icon: const Icon(Icons.upgrade),
            label: const Text('Jadi Pelaku Budaya'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.batik700,
              foregroundColor: AppColors.background,
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingL,
                vertical: AppDimensions.paddingM,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
