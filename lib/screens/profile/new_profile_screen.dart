import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/home_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/auth_provider.dart';
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

    // Load data after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileData();
    });
  }

  Future<void> _loadProfileData() async {
    final userId = SupabaseConfig.currentUser?.id;
    if (userId == null) {
      if (mounted) {
        setState(() {
          _isLoadingCollectibles = false;
        });
      }
      return;
    }

    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );

    try {
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
    } catch (e) {
      print('Error loading profile data: $e');
      if (mounted) {
        setState(() {
          _isLoadingCollectibles = false;
        });
      }
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
                icon: const Icon(Icons.badge),
                tooltip: 'Lihat Kartu',
                onPressed: () {
                  _showCharacterCard(context);
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Logout',
                onPressed: () async {
                  // Konfirmasi logout
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Konfirmasi Logout'),
                          content: const Text(
                            'Apakah Anda yakin ingin keluar?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Batal'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.batik700,
                              ),
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                  );

                  if (shouldLogout == true && context.mounted) {
                    final authProvider = Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    );
                    await authProvider.signOut();
                    if (context.mounted) {
                      Navigator.of(
                        context,
                      ).pushNamedAndRemoveUntil('/login', (route) => false);
                    }
                  }
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

          // Display Name with Edit Button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                profile?.displayName ?? 'Penjelajah Budaya',
                style: AppTextStyles.h4.copyWith(color: AppColors.background),
              ),
              SizedBox(width: AppDimensions.spaceS),
              InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => EditDisplayNameDialog(
                          currentName:
                              profile?.displayName ?? 'Penjelajah Budaya',
                        ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.background.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                  child: Icon(
                    Icons.edit,
                    size: 16,
                    color: AppColors.background,
                  ),
                ),
              ),
            ],
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

          // Koleksi Artifacts
          SizedBox(height: AppDimensions.spaceL),
          _isLoadingCollectibles
              ? const SizedBox(
                height: 60,
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              )
              : Builder(
                builder: (context) {
                  final collectibleCount = _collectibles.length;
                  final displayCount =
                      collectibleCount > 0 ? collectibleCount : 5;

                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingM,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(displayCount, (index) {
                        final hasCollectible =
                            collectibleCount > 0 && index < collectibleCount;

                        if (!hasCollectible) {
                          return Flexible(
                            child: AspectRatio(
                              aspectRatio: 1.0,
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.background.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusM,
                                  ),
                                  border: Border.all(
                                    color: AppColors.background.withOpacity(
                                      0.5,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.lock,
                                      size: 30,
                                      color: AppColors.background.withOpacity(
                                        0.7,
                                      ),
                                    ),
                                    SizedBox(height: AppDimensions.spaceXS),
                                    Text(
                                      '${index + 1}',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.background.withOpacity(
                                          0.7,
                                        ),
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }

                        final collectible = _collectibles[index];
                        return Flexible(
                          child: AspectRatio(
                            aspectRatio: 1.0,
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusM,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 30,
                                    color: AppColors.batik700,
                                  ),
                                  SizedBox(height: AppDimensions.spaceXS),
                                  Text(
                                    collectible['name'],
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.batik700,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  );
                },
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
        'unlocked': false, // Will check dynamically later
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
          // Achievements Section
          Text(
            'Pencapaian',
            style: AppTextStyles.h5.copyWith(color: AppColors.textPrimary),
          ),
          SizedBox(height: AppDimensions.spaceM),
          // Build achievement widgets as grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.0, // Bujur sangkar
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              // Dynamic check for Kolektor Budaya achievement
              bool unlocked = achievement['unlocked'] as bool;
              if (achievement['name'] == 'Kolektor Budaya') {
                try {
                  final count = _collectibles.length;
                  unlocked = count >= 3;
                } catch (e) {
                  unlocked = false;
                }
              }

              return Container(
                padding: EdgeInsets.all(AppDimensions.paddingM),
                decoration: BoxDecoration(
                  color: unlocked ? AppColors.batik50 : AppColors.grey50,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                  border: Border.all(
                    color: unlocked ? AppColors.batik300 : AppColors.grey200,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color:
                            unlocked ? AppColors.batik700 : AppColors.grey300,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        achievement['icon'] as IconData,
                        color: AppColors.background,
                        size: 30,
                      ),
                    ),
                    SizedBox(height: AppDimensions.spaceS),
                    Text(
                      achievement['name'] as String,
                      style: AppTextStyles.labelMedium.copyWith(
                        color:
                            unlocked
                                ? AppColors.textPrimary
                                : AppColors.textTertiary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AppDimensions.spaceXS),
                    Text(
                      achievement['desc'] as String,
                      style: AppTextStyles.bodySmall.copyWith(
                        color:
                            unlocked
                                ? AppColors.textSecondary
                                : AppColors.textTertiary,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (unlocked) ...[
                      SizedBox(height: AppDimensions.spaceXS),
                      Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 20,
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
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

  void _showCharacterCard(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: AppColors.orangePinkGradient,
                ),
                borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Consumer<ProfileProvider>(
                builder: (context, profileProvider, _) {
                  final profile = profileProvider.profile;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Close button
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),

                      // Character Icon
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.background,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Icon(
                          _getMascotIcon(),
                          size: 80,
                          color: AppColors.batik700,
                        ),
                      ),
                      SizedBox(height: AppDimensions.spaceL),

                      // Character Name
                      Text(
                        widget.mascot,
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.background,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: AppDimensions.spaceS),

                      // Display Name
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingM,
                          vertical: AppDimensions.paddingXS,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusL,
                          ),
                        ),
                        child: Text(
                          profile?.displayName ?? 'Penjelajah Budaya',
                          style: AppTextStyles.h5.copyWith(
                            color: AppColors.background,
                          ),
                        ),
                      ),
                      SizedBox(height: AppDimensions.spaceXL),

                      // Stats
                      Consumer<HomeProvider>(
                        builder: (context, homeProvider, _) {
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppDimensions.paddingXL,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem(
                                  'Level',
                                  '${homeProvider.userLevel}',
                                  Icons.stars,
                                ),
                                _buildStatItem(
                                  'XP',
                                  '${homeProvider.userXP}',
                                  Icons.bolt,
                                ),
                                _buildStatItem(
                                  'Artifacts',
                                  '2/5',
                                  Icons.inventory_2,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      SizedBox(height: AppDimensions.spaceXL),

                      // Footer
                      Text(
                        'BudayaGo Explorer Card',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.background.withOpacity(0.7),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      SizedBox(height: AppDimensions.paddingL),
                    ],
                  );
                },
              ),
            ),
          ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.background, size: 32),
        SizedBox(height: AppDimensions.spaceXS),
        Text(
          value,
          style: AppTextStyles.h4.copyWith(
            color: AppColors.background,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.background.withOpacity(0.8),
          ),
        ),
      ],
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
