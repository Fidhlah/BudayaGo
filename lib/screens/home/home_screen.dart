import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/home_provider.dart';
import 'category_list_screen.dart';
import '../qr/qr_scanner_screen.dart'; // ✅ Add import

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

  // Karya items data (getter to avoid Flutter Web issues)
  List<Map<String, dynamic>> get _karyaItems => [
    {
      'name': 'Batik Tulis Parang',
      'creator': 'Ibu Siti - Solo',
      'tag': 'Batik',
      'umkm': 'Batik Nusantara',
      'color': Colors.blue.shade300,
      'icon': Icons.auto_awesome,
    },
    {
      'name': 'Meja Kayu Jati Ukir',
      'creator': 'Pak Budi - Jepara',
      'tag': 'Furniture',
      'umkm': 'Kerajinan Kayu',
      'color': Colors.brown.shade300,
      'icon': Icons.table_restaurant,
    },
    {
      'name': 'Guci Kasongan',
      'creator': 'Pak Wawan - Yogyakarta',
      'tag': 'Keramik',
      'umkm': 'Gerabah Tradisional',
      'color': Colors.orange.shade300,
      'icon': Icons.local_florist,
    },
    {
      'name': 'Tas Anyaman Premium',
      'creator': 'Ibu Ani - Tasikmalaya',
      'tag': 'Anyaman',
      'umkm': 'Anyaman Bambu',
      'color': Colors.green.shade300,
      'icon': Icons.shopping_bag,
    },
    {
      'name': 'Kain Tenun Flores',
      'creator': 'Ibu Maria - NTT',
      'tag': 'Tenun',
      'umkm': 'Tenun Ikat',
      'color': Colors.purple.shade300,
      'icon': Icons.texture,
    },
    {
      'name': 'Wayang Arjuna',
      'creator': 'Pak Dalang - Solo',
      'tag': 'Wayang',
      'umkm': 'Wayang Kulit',
      'color': Colors.red.shade300,
      'icon': Icons.person,
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();

    // Initialize HomeProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      homeProvider.initializeUserData();
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
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Consumer<HomeProvider>(
                            builder: (context, homeProvider, _) {
                              return Text(
                                'Level ${homeProvider.userLevel} | ${homeProvider.userXP} XP',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
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
                        [Colors.purple.shade400, Colors.blue.shade300],
                      ),
                      _buildAdCard(
                        'Sanggar Seni Budaya',
                        'Pelajari tari dan musik tradisional Indonesia',
                        Icons.theater_comedy,
                        [Colors.orange.shade400, Colors.pink.shade300],
                      ),
                      _buildAdCard(
                        'Galeri Batik Nusantara',
                        'Temukan keindahan motif batik dari berbagai daerah',
                        Icons.palette,
                        [Colors.teal.shade400, Colors.green.shade300],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Tombol Scan QR - ✅ FIXED NAVIGATION
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: () async {
                      // ✅ Navigate to QR Scanner Screen
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const QRScannerScreen(),
                        ),
                      );

                      // ✅ Handle result after scan (if needed)
                      if (result != null && mounted) {
                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '✅ Check-in berhasil di ${result['locationName']}!',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );

                        // Give XP bonus using HomeProvider
                        final homeProvider = Provider.of<HomeProvider>(
                          context,
                          listen: false,
                        );
                        homeProvider.claimXP(50); // Give 50 XP for scanning
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.orange.shade200,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.qr_code_scanner,
                              color: Colors.orange.shade700,
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
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'Dapatkan bonus XP besar!',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
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
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to Eksplorasi tab (index 1)
                        widget.onNavigateToTab?.call(1);
                      },
                      child: Text(
                        'Lihat Semua',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w600,
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
                                    color: Colors.orange.shade50,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    category['icon'] as IconData,
                                    color: Colors.orange.shade700,
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

                // Section: Karya Pelaku Budaya (Mockup UMKM)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Karya Pelaku Budaya',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to Karya tab (index 2)
                        widget.onNavigateToTab?.call(2);
                      },
                      child: Text(
                        'Lihat Semua',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
                  child: ListView.builder(
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Image with gradient
                                Container(
                                  height: 120,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        (item['color'] as Color).withOpacity(
                                          0.8,
                                        ),
                                        (item['color'] as Color).withOpacity(
                                          0.4,
                                        ),
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
                                          color: Colors.white.withOpacity(0.4),
                                        ),
                                      ),
                                      // Tag at bottom
                                      Positioned(
                                        bottom: 8,
                                        left: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.9,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            item['tag'] as String,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: item['color'] as Color,
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
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item['creator'] as String,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
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
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(fontSize: 13, color: Colors.white),
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
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.orange.shade50,
            ),
          ),
          // Progress indicator
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 4,
              backgroundColor: Colors.orange.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange.shade600),
            ),
          ),
          // Level number in center
          Text(
            '$level',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
