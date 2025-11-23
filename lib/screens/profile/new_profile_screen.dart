import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/home_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/supabase_config.dart';
import '../../services/collectibles_service.dart';
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
  TabController? _tabController;
  List<Map<String, dynamic>>? _collectibles;
  bool _isLoadingCollectibles = true;
  List<Map<String, dynamic>>? _visitedLocations;

  @override
  void initState() {
    super.initState();

    // Explicitly initialize lists for Flutter Web compatibility
    _collectibles = <Map<String, dynamic>>[];
    _visitedLocations = <Map<String, dynamic>>[];

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

      // Load collectibles directly from service (includes lock status)
      final collectiblesData = await CollectiblesService.loadUserCollectibles(userId);

      if (mounted) {
        setState(() {
          // TODO: Load visited locations from user_visits table
          _visitedLocations = [];

          // Use collectibles from service with all information
          _collectibles = collectiblesData.map((item) {
            return {
              'id': item['id'],
              'name': item['name'],
              'description': item['description'] ?? '',
              'imageUrl': item['imageUrl'],
              'xpEarned': item['xpEarned'] ?? 0,
              'unlocked': item['isUnlocked'] == true,
              'category': 'Artifact',
              'location': 'Indonesia',
              'rarity': _getRarityFromXP(item['xpEarned'] ?? 0),
            };
          }).toList();
          
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

  String _getRarityFromXP(int xp) {
    // Match new EASIER level system:
    // Level 2 (100 XP) = Common
    // Level 4 (600 XP) = Uncommon
    // Level 6 (1,500 XP) = Rare
    // Level 8 (3,600 XP) = Epic
    // Level 10 (4,500 XP) = Legendary
    if (xp >= 4500) return 'Legendary';
    if (xp >= 3600) return 'Epic';
    if (xp >= 1500) return 'Rare';
    if (xp >= 600) return 'Uncommon';
    return 'Common';
  }

  @override
  void dispose() {
    _tabController?.dispose();
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
                icon: const Icon(Icons.settings),
                tooltip: 'Pengaturan',
                onPressed: () {
                  _showSettingsDialog(context, isPelakuBudaya);
                },
              ),
            ],
          ),
          body:
              isPelakuBudaya
                  ? _buildPelakuBudayaBody(profile!)
                  : _buildRegularUserBody(),
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
                  final collectibleCount = _collectibles?.length ?? 0;
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

                        final collectible = _collectibles![index];
                        final isUnlocked = collectible['unlocked'] == true;

                        return Flexible(
                          child: AspectRatio(
                            aspectRatio: 1.0,
                            child: GestureDetector(
                              onTap:
                                  isUnlocked
                                      ? () {
                                        _showCollectibleDetail(
                                          context,
                                          collectible,
                                        );
                                      }
                                      : null,
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  color:
                                      isUnlocked
                                          ? AppColors.background
                                          : AppColors.background.withOpacity(
                                            0.3,
                                          ),
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusM,
                                  ),
                                  border:
                                      isUnlocked
                                          ? null
                                          : Border.all(
                                            color: AppColors.background
                                                .withOpacity(0.5),
                                          ),
                                  boxShadow:
                                      isUnlocked
                                          ? [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.2,
                                              ),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                          : null,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      isUnlocked ? Icons.star : Icons.lock,
                                      size: 30,
                                      color:
                                          isUnlocked
                                              ? AppColors.batik700
                                              : AppColors.background
                                                  .withOpacity(0.7),
                                    ),
                                    SizedBox(height: AppDimensions.spaceXS),
                                    Text(
                                      isUnlocked ? collectible['name'] : '???',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color:
                                            isUnlocked
                                                ? AppColors.batik700
                                                : AppColors.background
                                                    .withOpacity(0.7),
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
          // Visited Locations Section
          Text(
            'Tempat yang Sudah Dikunjungi',
            style: AppTextStyles.h5.copyWith(color: AppColors.textPrimary),
          ),
          SizedBox(height: AppDimensions.spaceM),

          if ((_visitedLocations?.length ?? 0) == 0)
            Container(
              padding: EdgeInsets.all(AppDimensions.paddingL),
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                border: Border.all(color: AppColors.grey200),
              ),
              child: Column(
                children: [
                  Icon(Icons.location_off, size: 48, color: AppColors.grey300),
                  SizedBox(height: AppDimensions.spaceS),
                  Text(
                    'Belum ada tempat yang dikunjungi',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

          if ((_visitedLocations?.length ?? 0) > 0)
            ...(_visitedLocations ?? []).map((location) {
              final visitedAt = location['visitedAt'] as DateTime;
              final daysAgo = DateTime.now().difference(visitedAt).inDays;

              return Container(
                margin: EdgeInsets.only(bottom: AppDimensions.spaceM),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                  border: Border.all(color: AppColors.batik200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(AppDimensions.paddingM),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: AppColors.orangePinkGradient,
                      ),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusM,
                      ),
                    ),
                    child: Icon(
                      Icons.location_on,
                      color: AppColors.background,
                      size: 28,
                    ),
                  ),
                  title: Text(
                    location['name'] ?? 'Unknown Location',
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: AppDimensions.spaceXS),
                      Text(
                        location['description'] ?? '',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: AppDimensions.spaceXS),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            daysAgo == 0
                                ? 'Hari ini'
                                : daysAgo == 1
                                ? '1 hari yang lalu'
                                : '$daysAgo hari yang lalu',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textTertiary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 24,
                  ),
                ),
              );
            }).toList(),

          // Achievements Section
          SizedBox(height: AppDimensions.spaceXL),
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
              crossAxisCount: 5,
              childAspectRatio: 0.8,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              // Dynamic check for Kolektor Budaya achievement
              bool unlocked = achievement['unlocked'] as bool;
              if (achievement['name'] == 'Kolektor Budaya' && mounted) {
                try {
                  unlocked = (_collectibles?.length ?? 0) >= 3;
                } catch (e) {
                  unlocked = false;
                }
              }

              return Container(
                padding: EdgeInsets.all(AppDimensions.paddingS),
                decoration: BoxDecoration(
                  color: unlocked ? AppColors.batik50 : AppColors.grey50,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  border: Border.all(
                    color: unlocked ? AppColors.batik300 : AppColors.grey200,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color:
                            unlocked ? AppColors.batik700 : AppColors.grey300,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        achievement['icon'] as IconData,
                        color: AppColors.background,
                        size: 20,
                      ),
                    ),
                    SizedBox(height: 4),
                    Flexible(
                      child: Text(
                        achievement['name'] as String,
                        style: AppTextStyles.bodySmall.copyWith(
                          color:
                              unlocked
                                  ? AppColors.textPrimary
                                  : AppColors.textTertiary,
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: 2),
                    Flexible(
                      child: Text(
                        achievement['desc'] as String,
                        style: AppTextStyles.bodySmall.copyWith(
                          color:
                              unlocked
                                  ? AppColors.textSecondary
                                  : AppColors.textTertiary,
                          fontSize: 7,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (unlocked) ...[
                      SizedBox(height: 2),
                      Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 14,
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

    // Demo data dengan variasi jumlah foto
    final demoKarya = List.generate(profile.uploadedKaryaIds.length, (index) {
      // Variasi jumlah foto: 1, 2, 3, atau 4
      final photoCount = (index % 4) + 1;
      return {
        'id': profile.uploadedKaryaIds[index],
        'title': 'Karya ${index + 1}',
        'description': 'Deskripsi karya budaya ${index + 1}',
        'photoCount': photoCount,
        'creator': profile.displayName ?? 'Penjelajah Budaya',
        'tag': index % 2 == 0 ? 'Seni Rupa' : 'Kerajinan',
      };
    });

    return ListView.builder(
      padding: EdgeInsets.all(AppDimensions.paddingM),
      itemCount: demoKarya.length,
      itemBuilder: (context, index) {
        final karya = demoKarya[index];
        final photoCount = karya['photoCount'] as int;

        return Card(
          margin: EdgeInsets.only(bottom: AppDimensions.spaceL),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
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
                        gradient: LinearGradient(
                          colors: AppColors.orangePinkGradient,
                        ),
                      ),
                      child: Icon(
                        _getMascotIcon(),
                        color: AppColors.background,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: AppDimensions.spaceS),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            karya['creator'] as String,
                            style: AppTextStyles.labelLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Solo, Jawa Tengah',
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
              _buildKaryaPhotoGrid(photoCount, index),

              // Content: Title + Description
              Padding(
                padding: EdgeInsets.all(AppDimensions.paddingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textPrimary,
                              ),
                              children: [
                                TextSpan(
                                  text: '${karya['creator']} ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(text: karya['title'] as String),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if ((karya['description'] as String).isNotEmpty) ...[
                      SizedBox(height: AppDimensions.spaceXS),
                      Text(
                        karya['description'] as String,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
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
                      color: AppColors.batik700,
                    ),
                    SizedBox(width: 4),
                    Text(
                      karya['tag'] as String,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.batik700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKaryaPhotoGrid(int photoCount, int karyaIndex) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        color: AppColors.grey100,
        child:
            photoCount == 1
                ? _buildSingleKaryaPhoto(karyaIndex, 0)
                : photoCount == 2
                ? _buildTwoKaryaPhotos(karyaIndex)
                : photoCount == 3
                ? _buildThreeKaryaPhotos(karyaIndex)
                : _buildFourKaryaPhotos(karyaIndex),
      ),
    );
  }

  Widget _buildSingleKaryaPhoto(int karyaIndex, int photoIndex) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.batik300, AppColors.batik700],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, size: 80, color: AppColors.background),
            SizedBox(height: AppDimensions.spaceS),
            Text(
              'Foto ${photoIndex + 1}',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.background,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTwoKaryaPhotos(int karyaIndex) {
    return Row(
      children: [
        Expanded(child: _buildKaryaPhotoPlaceholder(karyaIndex, 0)),
        SizedBox(width: 2),
        Expanded(child: _buildKaryaPhotoPlaceholder(karyaIndex, 1)),
      ],
    );
  }

  Widget _buildThreeKaryaPhotos(int karyaIndex) {
    return Row(
      children: [
        Expanded(flex: 2, child: _buildKaryaPhotoPlaceholder(karyaIndex, 0)),
        SizedBox(width: 2),
        Expanded(
          child: Column(
            children: [
              Expanded(child: _buildKaryaPhotoPlaceholder(karyaIndex, 1)),
              SizedBox(height: 2),
              Expanded(child: _buildKaryaPhotoPlaceholder(karyaIndex, 2)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFourKaryaPhotos(int karyaIndex) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildKaryaPhotoPlaceholder(karyaIndex, 0)),
              SizedBox(width: 2),
              Expanded(child: _buildKaryaPhotoPlaceholder(karyaIndex, 1)),
            ],
          ),
        ),
        SizedBox(height: 2),
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildKaryaPhotoPlaceholder(karyaIndex, 2)),
              SizedBox(width: 2),
              Expanded(child: _buildKaryaPhotoPlaceholder(karyaIndex, 3)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKaryaPhotoPlaceholder(int karyaIndex, int photoIndex) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.batik300, AppColors.batik700],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.image,
          size: 40,
          color: AppColors.background.withOpacity(0.7),
        ),
      ),
    );
  }

  void _showCollectibleDetail(
    BuildContext context,
    Map<String, dynamic> collectible,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
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
              child: Column(
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

                  // Artifact Icon
                  Container(
                    width: 120,
                    height: 120,
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
                      Icons.star,
                      size: 60,
                      color: AppColors.batik700,
                    ),
                  ),
                  SizedBox(height: AppDimensions.spaceM),

                  // Artifact Name
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingL,
                    ),
                    child: Text(
                      collectible['name'] ?? 'Unknown Artifact',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.background,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: AppDimensions.spaceXS),

                  // Rarity Badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingM,
                      vertical: AppDimensions.paddingXS,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusL,
                      ),
                    ),
                    child: Text(
                      collectible['rarity'] ?? 'Common',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.background,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: AppDimensions.spaceL),

                  // Info Container
                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingL,
                    ),
                    padding: EdgeInsets.all(AppDimensions.paddingM),
                    decoration: BoxDecoration(
                      color: AppColors.background.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusL,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category
                        Row(
                          children: [
                            Icon(
                              Icons.category,
                              color: AppColors.background,
                              size: 20,
                            ),
                            SizedBox(width: AppDimensions.spaceS),
                            Text(
                              'Kategori: ${collectible['category'] ?? '-'}',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.background,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppDimensions.spaceS),

                        // Location
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: AppColors.background,
                              size: 20,
                            ),
                            SizedBox(width: AppDimensions.spaceS),
                            Text(
                              collectible['location'] ?? '-',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.background,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppDimensions.spaceS),

                        // XP Earned
                        Row(
                          children: [
                            Icon(
                              Icons.star_border,
                              color: AppColors.background,
                              size: 20,
                            ),
                            SizedBox(width: AppDimensions.spaceS),
                            Text(
                              '+${collectible['xpEarned'] ?? 0} XP',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.background,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppDimensions.spaceL),

                  // Description
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingL,
                    ),
                    child: Text(
                      collectible['description'] ?? 'No description available.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.background,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: AppDimensions.spaceL),
                ],
              ),
            ),
          ),
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
                        'Sembara Explorer Card',
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

  Widget _buildRegularUserBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildProfileHeader(
            context,
            Provider.of<ProfileProvider>(context).profile,
            false,
            false,
          ),
          _buildProgressTab(),
        ],
      ),
    );
  }

  Widget _buildPelakuBudayaBody(UserProfile profile) {
    // Initialize TabController for Pelaku Budaya
    if (_tabController == null || _tabController!.length != 2) {
      _tabController = TabController(length: 2, vsync: this);
    }

    return Column(
      children: [
        // Profile Header
        _buildProfileHeader(context, profile, true, profile.hideProgress),
        // Tab Bar (non-sticky)
        Container(
          color: AppColors.background,
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.batik700,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.batik700,
            dividerColor: AppColors.batik700,
            tabs: const [Tab(text: 'Progress'), Tab(text: 'Karya')],
          ),
        ),
        // Tab Views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_buildProgressTab(), _buildShowcaseTab(profile)],
          ),
        ),
      ],
    );
  }

  void _showSettingsDialog(BuildContext context, bool isPelakuBudaya) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
            ),
            child: Padding(
              padding: EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    children: [
                      Icon(Icons.settings, color: AppColors.batik700),
                      SizedBox(width: AppDimensions.spaceS),
                      Text(
                        'Pengaturan',
                        style: AppTextStyles.h5.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  SizedBox(height: AppDimensions.spaceL),

                  // Upgrade Button (if not pelaku budaya)
                  if (!isPelakuBudaya) ...[
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder:
                              (context) => const UpgradeToPelakuBudayaDialog(),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.batik700,
                        foregroundColor: AppColors.background,
                        padding: EdgeInsets.symmetric(
                          vertical: AppDimensions.paddingM,
                          horizontal: AppDimensions.paddingM,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusM,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.upgrade, size: 20),
                          SizedBox(width: AppDimensions.spaceS),
                          Text(
                            'Jadi Pelaku Budaya',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.background,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppDimensions.spaceM),
                  ],

                  // Logout Button
                  ElevatedButton(
                    onPressed: () async {
                      // Show logout confirmation dialog
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
                                  onPressed:
                                      () => Navigator.pop(context, false),
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
                        print(
                          '🚪 Logout confirmed, starting logout process...',
                        );

                        // Get navigator and providers BEFORE closing dialog
                        final navigator = Navigator.of(
                          context,
                          rootNavigator: true,
                        );
                        final authProvider = Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        );
                        final profileProvider = Provider.of<ProfileProvider>(
                          context,
                          listen: false,
                        );
                        final homeProvider = Provider.of<HomeProvider>(
                          context,
                          listen: false,
                        );

                        print('✅ Got navigator and all providers');

                        // Close the settings dialog
                        Navigator.pop(context);

                        // Clear all state
                        print('🧹 Clearing ProfileProvider...');
                        profileProvider.clear();
                        print('🧹 Clearing HomeProvider...');
                        homeProvider.resetProgress();
                        print('✅ Providers cleared');

                        // Sign out
                        print('🔐 Calling authProvider.signOut()...');
                        await authProvider.signOut();
                        print('✅ SignOut completed');

                        // Navigate to login screen using saved navigator
                        print('🚀 Navigating to /login...');
                        navigator.pushNamedAndRemoveUntil(
                          '/login',
                          (route) => false,
                        );
                        print('✅ Navigation completed');
                      } else {
                        print('❌ Logout cancelled or context not mounted');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: AppColors.background,
                      padding: EdgeInsets.symmetric(
                        vertical: AppDimensions.paddingM,
                        horizontal: AppDimensions.paddingM,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusM,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, size: 20),
                        SizedBox(width: AppDimensions.spaceS),
                        Text(
                          'Logout',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.background,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
