import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/home_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/supabase_config.dart';
import '../../services/collectibles_service.dart';
import '../../services/karya_service.dart';
import '../../services/achievement_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/edit_display_name_dialog.dart';
import '../../widgets/upgrade_pelaku_budaya_dialog.dart';
import '../karya/upload_karya_screen.dart';
import '../karya/karya_detail_screen.dart';

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
  List<Map<String, dynamic>>? _achievements;
  bool _isLoadingAchievements = true;

  // Helper method to get constant icons for tree shaking
  IconData _getIconFromCodePoint(int? codePoint) {
    // Map common code points to predefined constant icons
    switch (codePoint) {
      case 0xe838: // star
        return Icons.star;
      case 0xe7f2: // favorite
        return Icons.favorite;
      case 0xe55c: // home
        return Icons.home;
      case 0xe3af: // location_on
        return Icons.location_on;
      case 0xe3c7: // person
        return Icons.person;
      case 0xe3e4: // settings
        return Icons.settings;
      case 0xe3f4: // shopping_cart
        return Icons.shopping_cart;
      case 0xe1d8: // camera_alt
        return Icons.camera_alt;
      case 0xe3f7: // share
        return Icons.share;
      case 0xe3e6: // search
        return Icons.search;
      default:
        return Icons.auto_awesome; // Default fallback icon
    }
  }

  @override
  void initState() {
    super.initState();

    // Explicitly initialize lists for Flutter Web compatibility
    _collectibles = <Map<String, dynamic>>[];
    _achievements = <Map<String, dynamic>>[];

    // Load data after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileData();
      _initializeTabController();
    });
  }

  // REMOVED didChangeDependencies - causing infinite loop
  // Visited locations will be loaded after QR scan in home_screen.dart

  void _initializeTabController() {
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );
    final isPelakuBudaya = profileProvider.profile?.isPelakuBudaya ?? false;

    // Initialize TabController for Pelaku Budaya and auto-open Progress tab
    if (isPelakuBudaya) {
      if (_tabController == null || _tabController!.length != 2) {
        _tabController = TabController(
          length: 2,
          vsync: this,
          initialIndex: 0,
        ); // Start at Progress tab
      }
    }
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
      final collectiblesData = await CollectiblesService.loadUserCollectibles(
        userId,
      );

      debugPrint(
        '🎁 Loaded ${collectiblesData.length} collectibles from service',
      );
      for (var i = 0; i < collectiblesData.length; i++) {
        debugPrint(
          '  [$i] ${collectiblesData[i]['name']} - order: ${collectiblesData[i]['orderNumber']}, unlocked: ${collectiblesData[i]['isUnlocked']}',
        );
      }

      // Load achievements from database
      await _loadAchievements(userId);

      // Load visited locations from ProfileProvider (which loads from database)
      await profileProvider.loadVisitedLocations(userId);

      if (mounted) {
        setState(() {
          // Use collectibles from service with all information
          _collectibles =
              collectiblesData.map((item) {
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

  Future<void> _loadAchievements(String userId) async {
    try {
      debugPrint('🏆 Loading achievements for user...');

      // Get all achievements from database
      final allAchievements = await AchievementService.loadAchievements();

      // Get user's unlocked achievements
      final userAchievements = await AchievementService.loadUserAchievements(
        userId,
      );

      // Create a Set of unlocked achievement IDs for quick lookup
      final unlockedIds =
          userAchievements
              .where((ua) => ua['is_completed'] == true)
              .map((ua) => ua['achievement_id'] as String)
              .toSet();

      // Get current user stats for dynamic checking
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);

      final currentLevel = homeProvider.userLevel;
      final unlockedCollectibles =
          _collectibles?.where((c) => c['unlocked'] == true).length ?? 0;

      // Map achievements with unlock status and dynamic checking
      final achievementsWithStatus =
          allAchievements.map((achievement) {
            final isUnlocked = unlockedIds.contains(achievement['id']);

            // Dynamic unlock check based on criteria
            bool shouldBeUnlocked = isUnlocked;
            if (!isUnlocked) {
              final criteria = achievement['criteria'] as Map<String, dynamic>?;
              if (criteria != null) {
                // Check level requirement
                if (criteria.containsKey('level_reached')) {
                  final requiredLevel = criteria['level_reached'] as int;
                  shouldBeUnlocked = currentLevel >= requiredLevel;
                }
                // Check collectibles requirement
                else if (criteria.containsKey('collectibles_unlocked')) {
                  final requiredCount =
                      criteria['collectibles_unlocked'] as int;
                  shouldBeUnlocked = unlockedCollectibles >= requiredCount;
                }
                // Other criteria can be checked here (museums_visited, etc.)
              }
            }

            return {
              'id': achievement['id'],
              'name': achievement['name'],
              'description': achievement['description'],
              'type': achievement['type'],
              'exp_reward': achievement['exp_reward'],
              'icon_url': achievement['icon_url'],
              'criteria': achievement['criteria'],
              'unlocked': shouldBeUnlocked,
            };
          }).toList();

      if (mounted) {
        setState(() {
          _achievements = achievementsWithStatus;
          _isLoadingAchievements = false;
        });
      }

      debugPrint(
        '✅ Loaded ${_achievements?.length ?? 0} achievements (${unlockedIds.length} unlocked)',
      );
    } catch (e) {
      debugPrint('❌ Error loading achievements: $e');
      if (mounted) {
        setState(() {
          _achievements = [];
          _isLoadingAchievements = false;
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
          backgroundColor: AppColors.orange50,
          appBar: CustomGradientAppBar(
            title: 'Profil Saya',
            actions: [
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
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
                  ? Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: AppColors.skyGradient),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: FloatingActionButton.extended(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UploadKaryaScreen(),
                          ),
                        );
                      },
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      icon: const Icon(Icons.add),
                      label: const Text('Upload Karya'),
                    ),
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
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDimensions.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.orangePinkGradient,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          // Character Card (kiri) + 5 Artifacts (kanan)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Character Card - Load from database
              Flexible(
                flex: 3,
                child: Consumer<ProfileProvider>(
                  builder: (context, profileProvider, _) {
                    final character = profileProvider.character;

                    if (character == null) {
                      // Placeholder if no character assigned yet
                      return Container(
                        width: 200,
                        height: 300,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusM,
                          ),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 64,
                              color: Colors.white,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Belum ada karakter',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Display character card from database
                    if (character.imageUrl != null &&
                        character.imageUrl!.isNotEmpty) {
                      debugPrint('🎴 Character Card Debug:');
                      debugPrint('   Character Name: ${character.name}');
                      debugPrint('   Image URL: ${character.imageUrl}');
                    }

                    return Container(
                      width: 200,
                      height: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusM,
                        ),
                        color: Colors.white.withOpacity(0.2),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child:
                          character.imageUrl != null &&
                                  character.imageUrl!.isNotEmpty
                              ? FittedBox(
                                fit: BoxFit.cover,
                                alignment: Alignment.center,
                                child: Image.network(
                                  character.imageUrl!,
                                  repeat: ImageRepeat.noRepeat,
                                  frameBuilder: (
                                    context,
                                    child,
                                    frame,
                                    wasSynchronouslyLoaded,
                                  ) {
                                    if (wasSynchronouslyLoaded) {
                                      debugPrint(
                                        '✅ Character image loaded synchronously',
                                      );
                                      return child;
                                    }
                                    if (frame == null) {
                                      debugPrint(
                                        '⏳ Character image loading...',
                                      );
                                      return Container(
                                        width: 200,
                                        height: 300,
                                        color: Colors.white.withOpacity(0.2),
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                          ),
                                        ),
                                      );
                                    }
                                    debugPrint(
                                      '✅ Character image loaded (frame: $frame)',
                                    );
                                    return child;
                                  },
                                  loadingBuilder: (
                                    context,
                                    child,
                                    loadingProgress,
                                  ) {
                                    if (loadingProgress == null) {
                                      debugPrint(
                                        '✅ Character image fully loaded',
                                      );
                                      return child;
                                    }
                                    final progress =
                                        loadingProgress.expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null;
                                    debugPrint(
                                      '📥 Loading progress: ${(progress ?? 0) * 100}%',
                                    );
                                    return Container(
                                      width: 200,
                                      height: 300,
                                      color: Colors.white.withOpacity(0.2),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          value: progress,
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    debugPrint(
                                      '❌ Error loading character image: $error',
                                    );
                                    debugPrint('   URL: ${character.imageUrl}');
                                    debugPrint('   Stack: $stackTrace');
                                    return Container(
                                      width: 200,
                                      height: 300,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(
                                          AppDimensions.radiusM,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.image_not_supported,
                                            size: 50,
                                            color: Colors.white70,
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            character.name,
                                            style: AppTextStyles.h6.copyWith(
                                              color: Colors.white,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Image load failed',
                                            style: AppTextStyles.bodySmall
                                                .copyWith(
                                                  color: Colors.white60,
                                                ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              )
                              : Container(
                                width: 200,
                                height: 300,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusM,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.person,
                                      size: 64,
                                      color: Colors.white,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      character.name,
                                      style: AppTextStyles.h6.copyWith(
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                    );
                  },
                ),
              ),
              SizedBox(width: AppDimensions.spaceS),

              // 5 Artifacts tersusun vertikal - Load from database
              Flexible(
                flex: 2,
                child:
                    _isLoadingCollectibles
                        ? const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                        : Builder(
                          builder: (context) {
                            // Get collectibles from database (already sorted by order_number)
                            final collectibles = _collectibles ?? [];
                            final displayCount = 5;

                            debugPrint(
                              '📍 Displaying ${collectibles.length} collectibles',
                            );
                            for (
                              var i = 0;
                              i < collectibles.length && i < 5;
                              i++
                            ) {
                              debugPrint(
                                '  [UI pos $i (TOP=$i==0)] ${collectibles[i]['name']} - unlocked: ${collectibles[i]['unlocked']}',
                              );
                            }

                            return Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(displayCount, (index) {
                                // Check if collectible exists at this index
                                if (index < collectibles.length) {
                                  final collectible = collectibles[index];
                                  final isUnlocked =
                                      collectible['unlocked'] == true;
                                  final imageUrl =
                                      collectible['imageUrl'] as String?;

                                  return GestureDetector(
                                    onTap:
                                        isUnlocked
                                            ? () {
                                              // Show artifact detail
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    '${collectible['name']} - ${collectible['rarity']}',
                                                  ),
                                                  duration: const Duration(
                                                    seconds: 2,
                                                  ),
                                                ),
                                              );
                                            }
                                            : null,
                                    child: Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color:
                                            isUnlocked
                                                ? Colors.transparent
                                                : AppColors.background
                                                    .withOpacity(0.3),
                                        shape: BoxShape.circle,
                                        border:
                                            isUnlocked
                                                ? null
                                                : Border.all(
                                                  color: AppColors.background
                                                      .withOpacity(0.5),
                                                  width: 2,
                                                ),
                                      ),
                                      child:
                                          isUnlocked &&
                                                  imageUrl != null &&
                                                  imageUrl.isNotEmpty
                                              ? ClipOval(
                                                child: Image.network(
                                                  imageUrl,
                                                  width: 60,
                                                  height: 60,
                                                  fit: BoxFit.cover,
                                                  loadingBuilder: (
                                                    context,
                                                    child,
                                                    loadingProgress,
                                                  ) {
                                                    if (loadingProgress == null)
                                                      return child;
                                                    return Center(
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: Colors.white,
                                                        value:
                                                            loadingProgress
                                                                        .expectedTotalBytes !=
                                                                    null
                                                                ? loadingProgress
                                                                        .cumulativeBytesLoaded /
                                                                    loadingProgress
                                                                        .expectedTotalBytes!
                                                                : null,
                                                      ),
                                                    );
                                                  },
                                                  errorBuilder: (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) {
                                                    debugPrint(
                                                      '❌ Error loading collectible image: $error',
                                                    );
                                                    return Icon(
                                                      Icons.broken_image,
                                                      size: 24,
                                                      color: Colors.white70,
                                                    );
                                                  },
                                                ),
                                              )
                                              : Icon(
                                                isUnlocked
                                                    ? Icons.broken_image
                                                    : Icons.lock,
                                                size: 24,
                                                color:
                                                    isUnlocked
                                                        ? Colors.white70
                                                        : AppColors.background
                                                            .withOpacity(0.7),
                                              ),
                                    ),
                                  );
                                } else {
                                  // Empty slot if less than 5 collectibles
                                  return Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: AppColors.background.withOpacity(
                                        0.2,
                                      ),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.background.withOpacity(
                                          0.3,
                                        ),
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.lock_outline,
                                      size: 20,
                                      color: AppColors.background.withOpacity(
                                        0.5,
                                      ),
                                    ),
                                  );
                                }
                              }),
                            );
                          },
                        ),
              ),
            ],
          ),

          // Display Name with Edit Button
          SizedBox(height: AppDimensions.spaceS),
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

          // Progress Bar
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
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
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
      ),
    );
  }

  Widget _buildProgressTab() {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, _) {
        final visitedLocations = profileProvider.visitedLocations;

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

              if (visitedLocations.isEmpty)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(AppDimensions.paddingL),
                  decoration: BoxDecoration(
                    color: AppColors.grey50,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                    border: Border.all(color: AppColors.grey200),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.location_off,
                        size: 48,
                        color: AppColors.grey300,
                      ),
                      SizedBox(height: AppDimensions.spaceS),
                      Text(
                        'Belum ada tempat yang dikunjungi',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppDimensions.spaceXS),
                      Text(
                        'Scan QR code di lokasi wisata budaya untuk mulai mengoleksi!',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

              if (visitedLocations.isNotEmpty)
                ...visitedLocations.map((location) {
                  final visitedAt = location['visitedAt'] as DateTime;
                  final daysAgo = DateTime.now().difference(visitedAt).inDays;

                  return Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: AppDimensions.spaceM),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusL,
                      ),
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
                              const SizedBox(width: 12),
                              Icon(
                                Icons.star,
                                size: 14,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '+${location['expGained']} XP',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.warning,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
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

              // Loading state for achievements
              if (_isLoadingAchievements)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                ),

              // Empty state for achievements
              if (!_isLoadingAchievements && (_achievements?.isEmpty ?? true))
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(AppDimensions.paddingL),
                  decoration: BoxDecoration(
                    color: AppColors.grey50,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                    border: Border.all(color: AppColors.grey200),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.emoji_events,
                        size: 48,
                        color: AppColors.grey300,
                      ),
                      SizedBox(height: AppDimensions.spaceS),
                      Text(
                        'Belum ada pencapaian tersedia',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

              // Build achievement widgets as grid from database
              if (!_isLoadingAchievements &&
                  (_achievements?.isNotEmpty ?? false))
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _achievements!.length,
                  itemBuilder: (context, index) {
                    final achievement = _achievements![index];
                    final unlocked = achievement['unlocked'] as bool? ?? false;
                    final name =
                        achievement['name'] as String? ?? 'Achievement';
                    final description =
                        achievement['description'] as String? ?? '';
                    final expReward = achievement['exp_reward'] as int? ?? 0;

                    // Map achievement icons based on name or type
                    IconData achievementIcon = _getAchievementIcon(name);

                    return Container(
                      padding: EdgeInsets.all(AppDimensions.paddingS),
                      decoration: BoxDecoration(
                        color: unlocked ? AppColors.batik50 : AppColors.grey50,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusM,
                        ),
                        border: Border.all(
                          color:
                              unlocked ? AppColors.batik300 : AppColors.grey200,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color:
                                  unlocked
                                      ? AppColors.batik700
                                      : AppColors.grey300,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              achievementIcon,
                              color: AppColors.background,
                              size: 26,
                            ),
                          ),
                          SizedBox(height: 6),
                          Flexible(
                            child: Text(
                              name,
                              style: AppTextStyles.bodySmall.copyWith(
                                color:
                                    unlocked
                                        ? AppColors.textPrimary
                                        : AppColors.textTertiary,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(height: 4),
                          Flexible(
                            child: Text(
                              description,
                              style: AppTextStyles.bodySmall.copyWith(
                                color:
                                    unlocked
                                        ? AppColors.textSecondary
                                        : AppColors.textTertiary,
                                fontSize: 9,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (unlocked) ...[
                            SizedBox(height: 2),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: AppColors.success,
                                  size: 12,
                                ),
                                SizedBox(width: 2),
                                Text(
                                  '+$expReward XP',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.success,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
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
      },
    );
  } // Helper method to get icon based on achievement name

  IconData _getAchievementIcon(String achievementName) {
    final nameLower = achievementName.toLowerCase();

    if (nameLower.contains('penjelajah') || nameLower.contains('explorer')) {
      return Icons.explore;
    } else if (nameLower.contains('kolektor') ||
        nameLower.contains('collector')) {
      return Icons.collections;
    } else if (nameLower.contains('master') || nameLower.contains('level')) {
      return Icons.workspace_premium;
    } else if (nameLower.contains('wisata') || nameLower.contains('museum')) {
      return Icons.museum;
    } else if (nameLower.contains('quiz') || nameLower.contains('test')) {
      return Icons.psychology;
    } else if (nameLower.contains('seni') || nameLower.contains('art')) {
      return Icons.palette;
    } else if (nameLower.contains('scan') || nameLower.contains('qr')) {
      return Icons.qr_code_scanner;
    } else {
      return Icons.emoji_events; // Default trophy icon
    }
  }

  Widget _buildShowcaseTab(UserProfile profile) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: KaryaService.getUserKarya(profile.id),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Error state
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: AppDimensions.iconXL * 2,
                  color: AppColors.error,
                ),
                SizedBox(height: AppDimensions.spaceL),
                Text(
                  'Gagal memuat karya',
                  style: AppTextStyles.h5.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: AppDimensions.spaceS),
                Text(
                  'Error: ${snapshot.error}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final karyaList = snapshot.data ?? [];

        // Empty state
        if (karyaList.isEmpty) {
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
                  style: AppTextStyles.h5.copyWith(
                    color: AppColors.textSecondary,
                  ),
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

        // Display karya list
        return RefreshIndicator(
          onRefresh: () async {
            setState(() {}); // Trigger rebuild to reload data
          },
          child: ListView.builder(
            padding: EdgeInsets.all(AppDimensions.paddingM),
            itemCount: karyaList.length,
            itemBuilder: (context, index) {
              final karya = karyaList[index];
              final imageUrl = karya['image_url'] as String?;
              final hasImage = imageUrl != null && imageUrl.isNotEmpty;

              return Card(
                margin: EdgeInsets.only(bottom: AppDimensions.spaceL),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                ),
                child: InkWell(
                  onTap: () {
                    // Navigate to detail screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => KaryaDetailScreen(
                              karya: {
                                'id': karya['id'],
                                'name': karya['name'],
                                'description': karya['description'],
                                'imageUrl': imageUrl,
                                'tag': karya['tag'],
                                'umkm': karya['umkm_category'],
                                'creatorName': profile.displayName ?? 'Anonim',
                                'location': profile.displayName ?? 'Indonesia',
                                'color': Color(
                                  karya['color'] ?? AppColors.batik700.value,
                                ),
                                'icon': _getIconFromCodePoint(
                                  karya['icon_code_point'],
                                ),
                                'likes': karya['likes'] ?? 0,
                                'views': karya['views'] ?? 0,
                              },
                            ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
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
                                    profile.displayName ?? 'Penjelajah Budaya',
                                    style: AppTextStyles.labelLarge.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Indonesia',
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

                      // Image (if available)
                      if (hasImage)
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.zero,
                            topRight: Radius.zero,
                            bottomLeft: Radius.zero,
                            bottomRight: Radius.zero,
                          ),
                          child: Image.network(
                            imageUrl,
                            width: double.infinity,
                            height: 300,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: double.infinity,
                                height: 300,
                                color: AppColors.grey100,
                                child: Icon(
                                  Icons.broken_image,
                                  size: 64,
                                  color: AppColors.grey400,
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: double.infinity,
                                height: 300,
                                color: AppColors.grey100,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                      // Content: Title + Description
                      Padding(
                        padding: EdgeInsets.all(AppDimensions.paddingM),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              karya['name'] ?? 'Untitled',
                              style: AppTextStyles.labelLarge.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (karya['description'] != null &&
                                (karya['description'] as String)
                                    .isNotEmpty) ...[
                              SizedBox(height: AppDimensions.spaceXS),
                              Text(
                                karya['description'] as String,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            SizedBox(height: AppDimensions.spaceS),
                            // Tags
                            Wrap(
                              spacing: AppDimensions.spaceXS,
                              children: [
                                if (karya['tag'] != null)
                                  Chip(
                                    label: Text(
                                      karya['tag'] as String,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.batik700,
                                      ),
                                    ),
                                    backgroundColor: AppColors.batik700
                                        .withOpacity(0.1),
                                    side: BorderSide.none,
                                    padding: EdgeInsets.zero,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                if (karya['umkm_category'] != null)
                                  Chip(
                                    label: Text(
                                      karya['umkm_category'] as String,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    backgroundColor: AppColors.grey100
                                        .withOpacity(0.5),
                                    side: BorderSide.none,
                                    padding: EdgeInsets.zero,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
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
          ),
          _buildProgressTab(),
        ],
      ),
    );
  }

  Widget _buildPelakuBudayaBody(UserProfile profile) {
    // Ensure TabController is initialized (already done in initState with Progress tab as default)
    if (_tabController == null || _tabController!.length != 2) {
      _tabController = TabController(
        length: 2,
        vsync: this,
        initialIndex: 0,
      ); // Default to Progress tab
    }

    return Column(
      children: [
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
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildProgressTabWithHeader(context, profile),
              _buildShowcaseTab(profile),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressTabWithHeader(
    BuildContext context,
    UserProfile profile,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildProfileHeader(context, profile, true),
          _buildProgressTab(),
        ],
      ),
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

                  // Retake Personality Test Button
                  OutlinedButton(
                    onPressed: () async {
                      // Show confirmation dialog
                      final shouldRetake = await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Konfirmasi Ambil Ulang Tes'),
                              content: const Text(
                                'Apakah Anda yakin akan mengambil ulang tes kepribadian? Progress level dan XP Anda akan direset.',
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
                                  child: const Text('Lanjutkan'),
                                ),
                              ],
                            ),
                      );

                      if (shouldRetake == true && context.mounted) {
                        // Get providers
                        final homeProvider = Provider.of<HomeProvider>(
                          context,
                          listen: false,
                        );
                        final profileProvider = Provider.of<ProfileProvider>(
                          context,
                          listen: false,
                        );

                        // Reset progress
                        homeProvider.resetProgress();

                        // Reset mascot in profile
                        await profileProvider.updateProfile(mascot: null);

                        // Close settings dialog
                        Navigator.pop(context);

                        // Navigate to personality test
                        if (context.mounted) {
                          Navigator.pushNamed(context, '/personality-test');
                        }
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.batik700,
                      side: BorderSide(color: AppColors.batik700, width: 2),
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
                        Icon(Icons.psychology, size: 20),
                        SizedBox(width: AppDimensions.spaceS),
                        Text(
                          'Ambil Ulang Tes Kepribadian',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.batik700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppDimensions.spaceM),

                  // Show/Hide Progress Toggle (for pelaku budaya)
                  if (isPelakuBudaya) ...[
                    Consumer<ProfileProvider>(
                      builder: (context, profileProvider, _) {
                        final hideProgress =
                            profileProvider.profile?.hideProgress ?? false;
                        return SwitchListTile(
                          title: Text(
                            'Tampilkan Progress',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            'Tampilkan level dan XP di profile',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          value: !hideProgress,
                          onChanged: (value) async {
                            await profileProvider.updateProfile(
                              hideProgress: !value,
                            );
                          },
                          activeColor: AppColors.batik700,
                          contentPadding: EdgeInsets.zero,
                        );
                      },
                    ),
                    SizedBox(height: AppDimensions.spaceM),
                  ],

                  // Become Pelaku Budaya Button (for regular users)
                  if (!isPelakuBudaya) ...[
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder:
                              (context) => const UpgradeToPelakuBudayaDialog(),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.batik700,
                        side: BorderSide(color: AppColors.batik700, width: 2),
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
                          Icon(Icons.badge, size: 20),
                          SizedBox(width: AppDimensions.spaceS),
                          Text(
                            'Jadi Pelaku Budaya',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.batik700,
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
