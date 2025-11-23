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
import '../../services/eksplorasi_service.dart';
import '../../config/supabase_config.dart';
import '../../widgets/custom_app_bar.dart';
import '../qr/qr_scanner_screen.dart';
import '../eksplorasi/cultural_objects_screen.dart';

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
  List<Map<String, dynamic>> _eksplorasiCategories = [];
  bool _isLoadingEksplorasi = true;

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

  // Load eksplorasi categories from database
  Future<void> _loadEksplorasiCategories() async {
    try {
      final categories = await EksplorasiService.loadCategories();
      if (mounted) {
        setState(() {
          _eksplorasiCategories =
              categories.take(5).map((cat) {
                return {
                  'id': cat['id'],
                  'name': cat['name'],
                  'icon': _getIconFromString(cat['icon_name']),
                  'color': _getColorFromHex(cat['color']),
                };
              }).toList();
          _isLoadingEksplorasi = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading eksplorasi categories: $e');
      if (mounted) {
        setState(() => _isLoadingEksplorasi = false);
      }
    }
  }

  IconData _getIconFromString(String iconName) {
    final iconMap = {
      'record_voice_over': Icons.record_voice_over,
      'auto_stories': Icons.auto_stories,
      'people': Icons.people,
      'celebration': Icons.celebration,
      'book': Icons.book,
      'engineering': Icons.engineering,
      'palette': Icons.palette,
      'translate': Icons.translate,
      'sports_esports': Icons.sports_esports,
      'sports_martial_arts': Icons.sports_martial_arts,
    };
    return iconMap[iconName] ?? Icons.category;
  }

  Color _getColorFromHex(String hexColor) {
    final colorMap = {
      '#9333EA': const Color(0xFF9333EA),
      '#92400E': const Color(0xFF92400E),
      '#4F46E5': const Color(0xFF4F46E5),
      '#DC2626': const Color(0xFFDC2626),
      '#10B981': const Color(0xFF10B981),
      '#EA580C': const Color(0xFFEA580C),
      '#EC4899': const Color(0xFFEC4899),
      '#3B82F6': const Color(0xFF3B82F6),
      '#A855F7': const Color(0xFFA855F7),
      '#6366F1': const Color(0xFF6366F1),
    };
    return colorMap[hexColor] ?? AppColors.orange700;
  }

  @override
  void initState() {
    super.initState();
    _startAutoScroll();

    // Initialize HomeProvider and load data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      homeProvider.initializeUserData();
      _loadKaryaItems();
      _loadEksplorasiCategories();
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
    return Scaffold(
      backgroundColor: AppColors.orange50,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: CustomGradientAppBar(
          title: 'Halo, Penjelajah!',
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Consumer<HomeProvider>(
                builder: (context, homeProvider, _) {
                  return _buildLevelProgress(
                    homeProvider.userLevel,
                    homeProvider.progressToNextLevel,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Advertisement Carousel
                    SizedBox(
                      height: 200,
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
                                  final homeProvider =
                                      Provider.of<HomeProvider>(
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
                                      content: Text(
                                        'Gagal mencatat kunjungan: $e',
                                      ),
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
                          padding: const EdgeInsets.all(12),
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
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.orange50,
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusM,
                                  ),
                                ),
                                child: Icon(
                                  Icons.qr_code_scanner,
                                  color: AppColors.orange700,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Scan QR di Museum',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'Dapatkan bonus XP besar!',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 14),
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
                    _isLoadingEksplorasi
                        ? const SizedBox(
                          height: 120,
                          child: Center(child: CircularProgressIndicator()),
                        )
                        : SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _eksplorasiCategories.length,
                            itemBuilder: (context, index) {
                              final category = _eksplorasiCategories[index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => CulturalObjectsScreen(
                                              categoryId:
                                                  category['id'] as String,
                                              categoryName:
                                                  category['name'] as String,
                                              categoryColor:
                                                  category['color'] as Color,
                                              categoryIcon:
                                                  category['icon'] as IconData,
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: (category['color'] as Color)
                                                .withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            category['icon'] as IconData,
                                            color: category['color'] as Color,
                                            size: 28,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          category['name'] as String,
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 10,
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
                        const Text(
                          'Karya Pelaku Budaya',
                          style: AppTextStyles.h4,
                        ),
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
                                        padding: const EdgeInsets.only(
                                          right: 16,
                                        ),
                                        child: GestureDetector(
                                          onTap: () {
                                            // Navigate to Karya tab when tapped
                                            widget.onNavigateToTab?.call(2);
                                          },
                                          child: Container(
                                            width: 160,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.05),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Image with actual photo or gradient fallback
                                                Container(
                                                  height: 120,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        const BorderRadius.vertical(
                                                          top: Radius.circular(
                                                            16,
                                                          ),
                                                        ),
                                                    color: AppColors.grey200,
                                                  ),
                                                  child: Stack(
                                                    children: [
                                                      // Actual image or gradient placeholder
                                                      if (item['imageUrl'] !=
                                                              null &&
                                                          (item['imageUrl']
                                                                  as String)
                                                              .isNotEmpty)
                                                        ClipRRect(
                                                          borderRadius:
                                                              const BorderRadius.vertical(
                                                                top:
                                                                    Radius.circular(
                                                                      16,
                                                                    ),
                                                              ),
                                                          child: Image.network(
                                                            item['imageUrl']
                                                                as String,
                                                            width:
                                                                double.infinity,
                                                            height: 120,
                                                            fit: BoxFit.cover,
                                                            errorBuilder: (
                                                              context,
                                                              error,
                                                              stackTrace,
                                                            ) {
                                                              return Container(
                                                                decoration: BoxDecoration(
                                                                  gradient: LinearGradient(
                                                                    begin:
                                                                        Alignment
                                                                            .topLeft,
                                                                    end:
                                                                        Alignment
                                                                            .bottomRight,
                                                                    colors: [
                                                                      (item['color']
                                                                              as Color)
                                                                          .withOpacity(
                                                                            0.8,
                                                                          ),
                                                                      (item['color']
                                                                              as Color)
                                                                          .withOpacity(
                                                                            0.4,
                                                                          ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                child: Center(
                                                                  child: Icon(
                                                                    item['icon']
                                                                        as IconData,
                                                                    size: 50,
                                                                    color: Colors
                                                                        .white
                                                                        .withOpacity(
                                                                          0.4,
                                                                        ),
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        )
                                                      else
                                                        Container(
                                                          decoration: BoxDecoration(
                                                            gradient: LinearGradient(
                                                              begin:
                                                                  Alignment
                                                                      .topLeft,
                                                              end:
                                                                  Alignment
                                                                      .bottomRight,
                                                              colors: [
                                                                (item['color']
                                                                        as Color)
                                                                    .withOpacity(
                                                                      0.8,
                                                                    ),
                                                                (item['color']
                                                                        as Color)
                                                                    .withOpacity(
                                                                      0.4,
                                                                    ),
                                                              ],
                                                            ),
                                                          ),
                                                          child: Center(
                                                            child: Icon(
                                                              item['icon']
                                                                  as IconData,
                                                              size: 50,
                                                              color: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                    0.4,
                                                                  ),
                                                            ),
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
                                                                .withOpacity(
                                                                  0.9,
                                                                ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12,
                                                                ),
                                                          ),
                                                          child: Text(
                                                            item['tag']
                                                                as String,
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
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
                                                  padding: const EdgeInsets.all(
                                                    12,
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
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
                                                            TextOverflow
                                                                .ellipsis,
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        item['creator']
                                                            as String,
                                                        style: AppTextStyles
                                                            .bodySmall
                                                            .copyWith(
                                                              color:
                                                                  AppColors
                                                                      .textSecondary,
                                                            ),
                                                        maxLines: 1,
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
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
            ],
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
      width: 45,
      height: 45,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
          // Progress indicator
          SizedBox(
            width: 45,
            height: 45,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 3,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          // Level number in center
          Text(
            '$level',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
