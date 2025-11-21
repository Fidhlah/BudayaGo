import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/home_provider.dart';
import '../../providers/profile_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';
import '../../services/karya_service.dart';
import '../../services/visit_service.dart';
import '../../config/supabase_config.dart';
import 'category_list_screen.dart';
import '../qr/qr_scanner_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigateToTab;

  const HomeScreen({Key? key, this.onNavigateToTab}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;
  List<Map<String, dynamic>> _karyaItems = [];
  bool _isLoadingKarya = true;

  // Load karya from database
  Future<void> _loadKaryaItems() async {
    try {
      final karya = await KaryaService.loadAllKarya();
      if (mounted) {
        setState(() {
          _karyaItems =
              karya.take(6).map((item) {
                // Transform database data to display format
                final creator = item['users'] as Map<String, dynamic>?;
                return {
                  'id': item['id'],
                  'name': item['name'],
                  'creator':
                      '${creator?['display_name'] ?? creator?['username'] ?? 'Unknown'}',
                  'tag': item['tag'],
                  'umkm': item['umkm_category'],
                  'color': Color(item['color'] ?? AppColors.batik700.value),
                  'icon': IconData(
                    item['icon_code_point'] ?? Icons.auto_awesome.codePoint,
                    fontFamily: 'MaterialIcons',
                  ),
                  'imageUrl': item['image_url'],
                };
              }).toList();
          _isLoadingKarya = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading karya: $e');
      if (mounted) {
        setState(() => _isLoadingKarya = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _startAutoScroll();

    // Initialize HomeProvider and load karya
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      homeProvider.initializeUserData();
      _loadKaryaItems();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentPage < 2) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'name': 'Pakaian Adat', 'icon': Icons.checkroom},
      {'name': 'Tarian', 'icon': Icons.music_note},
      {'name': 'Makanan', 'icon': Icons.restaurant},
      {'name': 'Rumah Adat', 'icon': Icons.home},
      {'name': 'Alat Musik', 'icon': Icons.piano},
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Halo, Penjelajah!',
                            style: AppTextStyles.h3,
                          ),
                          const SizedBox(height: AppDimensions.spaceXS),
                          Consumer<HomeProvider>(
                            builder: (context, homeProvider, _) {
                              return Text(
                                'Level ${homeProvider.userLevel} | ${homeProvider.userXP} XP',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Consumer<HomeProvider>(
                      builder: (context, homeProvider, _) {
                        return _buildLevelProgress(
                          homeProvider.userLevel,
                          homeProvider.progressToNextLevel,
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Advertisement Carousel
                SizedBox(
                  height: 160,
                  child: PageView(
                    controller: _pageController,
                    children: [
                      _buildAdCard(
                        'Museum Nasional Indonesia',
                        'Jelajahi koleksi budaya dari seluruh Nusantara',
                        Icons.museum,
                        AppColors.purpleBlueGradient,
                      ),
                      _buildAdCard(
                        'Sanggar Seni Budaya',
                        'Pelajari tari dan musik tradisional Indonesia',
                        Icons.theater_comedy,
                        AppColors.orangePinkGradient,
                      ),
                      _buildAdCard(
                        'Galeri Batik Nusantara',
                        'Temukan keindahan motif batik dari berbagai daerah',
                        Icons.palette,
                        [AppColors.greenLight, AppColors.green],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Tombol Scan QR - ✅ INTEGRATED WITH DATABASE
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: () async {
                      // Navigate to QR Scanner Screen
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const QRScannerScreen(),
                        ),
                      );

                      // Handle result after scan
                      if (result != null &&
                          result['valid'] == true &&
                          mounted) {
                        final userId = SupabaseConfig.currentUser?.id;

                        if (userId != null) {
                          try {
                            // Record visit and give XP through database
                            final visitResult =
                                await VisitService.recordVisitAndGiveExp(
                                  userId: userId,
                                  partnerId: result['uuid'],
                                  expGained: 500, // 500 XP for museum visit
                                );

                            if (mounted && visitResult['success'] == true) {
                              // Sync HomeProvider with new XP/Level
                              final homeProvider = Provider.of<HomeProvider>(
                                context,
                                listen: false,
                              );
                              await homeProvider.syncUserProgress();

                              // Sync ProfileProvider for collectibles
                              final profileProvider =
                                  Provider.of<ProfileProvider>(
                                    context,
                                    listen: false,
                                  );
                              if (profileProvider.hasProfile) {
                                await profileProvider.loadCollectibles();
                              }

                              // Show success message with details
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '✅ ${visitResult['message']}\n'
                                    '🎉 +${visitResult['expGained']} XP | Level ${visitResult['newLevel']}\n'
                                    '${visitResult['unlockedCollectibles'] > 0 ? '🎁 ${visitResult['unlockedCollectibles']} Collectible Baru!' : ''}',
                                  ),
                                  backgroundColor: AppColors.success,
                                  duration: const Duration(seconds: 4),
                                ),
                              );
                            }
                          } catch (e) {
                            debugPrint('❌ Error recording visit: $e');
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Gagal mencatat kunjungan: $e'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        }
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.orange200,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusL,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(
                              AppDimensions.paddingS,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.orange50,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusM,
                              ),
                            ),
                            child: Icon(
                              Icons.qr_code_scanner,
                              color: AppColors.orange700,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Scan QR di Museum',
                                  style: AppTextStyles.h6,
                                ),
                                Text(
                                  'Dapatkan bonus XP besar!',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Section: Eksplorasi Pengetahuan
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Eksplorasi Pengetahuan',
                      style: AppTextStyles.h4,
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to Eksplorasi tab (index 1)
                        widget.onNavigateToTab?.call(1);
                      },
                      child: Text(
                        'Lihat Semua',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.orange700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => CategoryListScreen(
                                      category: category['name'] as String,
                                      onXPGained: (xp) {
                                        Provider.of<HomeProvider>(
                                          context,
                                          listen: false,
                                        ).claimXP(xp);
                                      },
                                    ),
                              ),
                            );
                          },
                          child: Container(
                            width: 110,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.orange50,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    category['icon'] as IconData,
                                    color: AppColors.orange700,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  category['name'] as String,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),

                // Section: Karya Pelaku Budaya (From Database)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Karya Pelaku Budaya', style: AppTextStyles.h4),
                    TextButton(
                      onPressed: () {
                        // Navigate to Karya tab (index 2)
                        widget.onNavigateToTab?.call(2);
                      },
                      child: Text(
                        'Lihat Semua',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.orange700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _isLoadingKarya
                    ? const SizedBox(
                      height: 220,
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : SizedBox(
                      height: 220,
                      child:
                          _karyaItems.isEmpty
                              ? Center(
                                child: Text(
                                  'Belum ada karya',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              )
                              : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _karyaItems.length,
                                itemBuilder: (context, index) {
                                  final item = _karyaItems[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 16),
                                    child: GestureDetector(
                                      onTap: () {
                                        // Navigate to Karya tab when tapped
                                        widget.onNavigateToTab?.call(2);
                                      },
                                      child: Container(
                                        width: 160,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.05,
                                              ),
                                              blurRadius: 10,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Image with gradient
                                            Container(
                                              height: 120,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    const BorderRadius.vertical(
                                                      top: Radius.circular(16),
                                                    ),
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    (item['color'] as Color)
                                                        .withOpacity(0.8),
                                                    (item['color'] as Color)
                                                        .withOpacity(0.4),
                                                  ],
                                                ),
                                              ),
                                              child: Stack(
                                                children: [
                                                  // Decorative icon
                                                  Center(
                                                    child: Icon(
                                                      item['icon'] as IconData,
                                                      size: 50,
                                                      color: Colors.white
                                                          .withOpacity(0.4),
                                                    ),
                                                  ),
                                                  // Tag at bottom
                                                  Positioned(
                                                    bottom: 8,
                                                    left: 8,
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                            vertical: 4,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white
                                                            .withOpacity(0.9),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        item['tag'] as String,
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color:
                                                              item['color']
                                                                  as Color,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Content
                                            Padding(
                                              padding: const EdgeInsets.all(12),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    item['name'] as String,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 13,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    item['creator'] as String,
                                                    style: AppTextStyles
                                                        .bodySmall
                                                        .copyWith(
                                                          color:
                                                              AppColors
                                                                  .textSecondary,
                                                        ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdCard(
    String title,
    String description,
    IconData icon,
    List<Color> gradientColors,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: AppTextStyles.h5.copyWith(color: Colors.white),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimensions.spaceXS),
                Text(
                  description,
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 35, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelProgress(int level, double progress) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.orange50,
            ),
          ),
          // Progress indicator
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 4,
              backgroundColor: AppColors.orange100,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.orange600,
              ),
            ),
          ),
          // Level number in center
          Text(
            '$level',
            style: AppTextStyles.h4.copyWith(color: AppColors.orange700),
          ),
        ],
      ),
    );
  }
}
