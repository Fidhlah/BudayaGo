import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import 'category_detail_screen.dart';

class EksplorasiScreen extends StatefulWidget {
  const EksplorasiScreen({Key? key}) : super(key: key);

  @override
  State<EksplorasiScreen> createState() => _EksplorasiScreenState();
}

class _EksplorasiScreenState extends State<EksplorasiScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // 10 Objek Pemajuan Kebudayaan (OPK)
  final List<Map<String, dynamic>> _kulturalCategories = [
    {
      'name': 'Tradisi Lisan',
      'icon': Icons.record_voice_over,
      'color': AppColors.purple,
      'description': 'Cerita rakyat, dongeng, legenda',
      'count': 156,
    },
    {
      'name': 'Manuskrip',
      'icon': Icons.auto_stories,
      'color': AppColors.brown,
      'description': 'Naskah kuno & aksara tradisional',
      'count': 89,
    },
    {
      'name': 'Adat Istiadat',
      'icon': Icons.people,
      'color': AppColors.indigo,
      'description': 'Tradisi & kebiasaan masyarakat',
      'count': 234,
    },
    {
      'name': 'Ritus',
      'icon': Icons.celebration,
      'color': AppColors.red,
      'description': 'Upacara & ritual keagamaan',
      'count': 112,
    },
    {
      'name': 'Pengetahuan Tradisional',
      'icon': Icons.book,
      'color': AppColors.green,
      'description': 'Kearifan lokal & filosofi hidup',
      'count': 178,
    },
    {
      'name': 'Teknologi Tradisional',
      'icon': Icons.engineering,
      'color': AppColors.orange700,
      'description': 'Alat & metode tradisional',
      'count': 92,
    },
    {
      'name': 'Seni',
      'icon': Icons.palette,
      'color': AppColors.pink400,
      'description': 'Tari, musik, teater, rupa',
      'count': 301,
    },
    {
      'name': 'Bahasa',
      'icon': Icons.translate,
      'color': AppColors.blue,
      'description': 'Bahasa daerah & dialek',
      'count': 718,
    },
    {
      'name': 'Permainan Rakyat',
      'icon': Icons.sports_esports,
      'color': AppColors.purple,
      'description': 'Permainan tradisional anak',
      'count': 145,
    },
    {
      'name': 'Olahraga Tradisional',
      'icon': Icons.sports_martial_arts,
      'color': AppColors.indigo,
      'description': 'Seni bela diri & olahraga',
      'count': 67,
    },
  ];

  // 34 Provinsi Indonesia
  final List<Map<String, dynamic>> _provinces = [
    {'name': 'Aceh', 'icon': '🕌', 'count': 127},
    {'name': 'Sumatera Utara', 'icon': '🏔️', 'count': 156},
    {'name': 'Sumatera Barat', 'icon': '🏛️', 'count': 143},
    {'name': 'Riau', 'icon': '🌴', 'count': 98},
    {'name': 'Kepulauan Riau', 'icon': '🏝️', 'count': 76},
    {'name': 'Jambi', 'icon': '🌳', 'count': 84},
    {'name': 'Sumatera Selatan', 'icon': '🏞️', 'count': 112},
    {'name': 'Bangka Belitung', 'icon': '⛰️', 'count': 67},
    {'name': 'Bengkulu', 'icon': '🌊', 'count': 71},
    {'name': 'Lampung', 'icon': '🌋', 'count': 89},
    {'name': 'DKI Jakarta', 'icon': '🏙️', 'count': 145},
    {'name': 'Banten', 'icon': '🏰', 'count': 102},
    {'name': 'Jawa Barat', 'icon': '🎭', 'count': 234},
    {'name': 'Jawa Tengah', 'icon': '🏯', 'count': 267},
    {'name': 'DI Yogyakarta', 'icon': '👑', 'count': 189},
    {'name': 'Jawa Timur', 'icon': '⛩️', 'count': 298},
    {'name': 'Bali', 'icon': '🌺', 'count': 312},
    {'name': 'Nusa Tenggara Barat', 'icon': '🏖️', 'count': 134},
    {'name': 'Nusa Tenggara Timur', 'icon': '🗿', 'count': 156},
    {'name': 'Kalimantan Barat', 'icon': '🦜', 'count': 123},
    {'name': 'Kalimantan Tengah', 'icon': '🌲', 'count': 98},
    {'name': 'Kalimantan Selatan', 'icon': '🛶', 'count': 107},
    {'name': 'Kalimantan Timur', 'icon': '🦧', 'count': 89},
    {'name': 'Kalimantan Utara', 'icon': '🌴', 'count': 67},
    {'name': 'Sulawesi Utara', 'icon': '🏔️', 'count': 112},
    {'name': 'Sulawesi Tengah', 'icon': '🌊', 'count': 94},
    {'name': 'Sulawesi Selatan', 'icon': '⛵', 'count': 187},
    {'name': 'Sulawesi Tenggara', 'icon': '🏝️', 'count': 101},
    {'name': 'Gorontalo', 'icon': '🐟', 'count': 73},
    {'name': 'Sulawesi Barat', 'icon': '⛰️', 'count': 68},
    {'name': 'Maluku', 'icon': '🏝️', 'count': 145},
    {'name': 'Maluku Utara', 'icon': '🌋', 'count': 98},
    {'name': 'Papua', 'icon': '🦜', 'count': 234},
    {'name': 'Papua Barat', 'icon': '🏔️', 'count': 178},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredKulturalCategories {
    if (_searchQuery.isEmpty) return _kulturalCategories;
    return _kulturalCategories
        .where((cat) =>
            cat['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  List<Map<String, dynamic>> get filteredProvinces {
    if (_searchQuery.isEmpty) return _provinces;
    return _provinces
        .where((prov) =>
            prov['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // Custom AppBar dengan Library Theme
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              backgroundColor: AppColors.batik700,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.batik800,
                        AppColors.batik600,
                        AppColors.batikGold,
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Pattern Background
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.1,
                          child: CustomPaint(
                            painter: BatikPatternPainter(),
                          ),
                        ),
                      ),
                      // Content
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.local_library,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Perpustakaan Budaya',
                                      style: AppTextStyles.h3.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Jelajahi kekayaan budaya Indonesia',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  color: AppColors.batik700,
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.white,
                    indicatorWeight: 3,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white.withOpacity(0.7),
                    labelStyle: AppTextStyles.labelLarge,
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.category, size: 20),
                        text: 'Objek Kebudayaan',
                      ),
                      Tab(
                        icon: Icon(Icons.map, size: 20),
                        text: 'Provinsi',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: Column(
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Cari budaya Indonesia...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textHint,
                  ),
                  prefixIcon: const Icon(Icons.search, color: AppColors.batik600),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.grey100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),

            // TabBarView
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Objek Pemajuan Kebudayaan
                  _buildKulturalCategoriesTab(),

                  // Tab 2: Provinsi
                  _buildProvincesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKulturalCategoriesTab() {
    final categories = filteredKulturalCategories;

    if (categories.isEmpty) {
      return _buildEmptyState('Kategori tidak ditemukan');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _buildKulturalCategoryCard(category);
      },
    );
  }

  Widget _buildProvincesTab() {
    final provinces = filteredProvinces;

    if (provinces.isEmpty) {
      return _buildEmptyState('Provinsi tidak ditemukan');
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: provinces.length,
      itemBuilder: (context, index) {
        final province = provinces[index];
        return _buildProvinceCard(province);
      },
    );
  }

  Widget _buildKulturalCategoryCard(Map<String, dynamic> category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategoryDetailScreen(
                  categoryName: category['name'] as String,
                  categoryColor: category['color'] as Color,
                  categoryIcon: category['icon'] as IconData,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon Container
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: (category['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    category['icon'] as IconData,
                    size: 32,
                    color: category['color'] as Color,
                  ),
                ),
                const SizedBox(width: 16),

                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category['name'] as String,
                        style: AppTextStyles.h6,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category['description'] as String,
                        style: AppTextStyles.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.batik50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${category['count']} Konten',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.batik700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow Icon
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textHint,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProvinceCard(Map<String, dynamic> province) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryDetailScreen(
                categoryName: province['name'] as String,
                categoryColor: AppColors.batik600,
                categoryIcon: Icons.location_on,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Emoji Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.batik50,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    province['icon'] as String,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Province Name
              Text(
                province['name'] as String,
                textAlign: TextAlign.center,
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Content Count Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.batik600,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${province['count']}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter untuk Batik Pattern Background
class BatikPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    const spacing = 40.0;
    
    // Draw diagonal lines pattern
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
    
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i - size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
