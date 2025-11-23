import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../services/eksplorasi_service.dart';
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
  
  // Data from database
  List<Map<String, dynamic>> _kulturalCategories = [];
  List<Map<String, dynamic>> _provinces = [];
  bool _isLoading = true;

  // Icon mapping untuk categories
  final Map<String, IconData> _iconMapping = {
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

  // Color mapping untuk categories
  final Map<String, Color> _colorMapping = {
    '#9333EA': AppColors.purple,
    '#92400E': AppColors.brown,
    '#4F46E5': AppColors.indigo,
    '#DC2626': AppColors.red,
    '#10B981': AppColors.green,
    '#EA580C': AppColors.orange700,
    '#EC4899': AppColors.pink400,
    '#3B82F6': AppColors.blue,
    '#A855F7': AppColors.purple,
    '#6366F1': AppColors.indigo,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final categories = await EksplorasiService.loadCategories();
      final provinces = await EksplorasiService.loadProvinces();
      
      if (mounted) {
        setState(() {
          _kulturalCategories = categories.map((cat) {
            return {
              'id': cat['id'],
              'name': cat['name'],
              'icon': _iconMapping[cat['icon_name']] ?? Icons.category,
              'color': _colorMapping[cat['color']] ?? AppColors.orange,
              'description': cat['description'] ?? '',
              'count': cat['content_count'] ?? 0,
            };
          }).toList();
          
          _provinces = provinces.map((prov) {
            return {
              'id': prov['id'],
              'name': prov['name'],
              'icon': prov['icon_emoji'] ?? '🏝️',
              'count': prov['content_count'] ?? 0,
            };
          }).toList();
          
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading eksplorasi data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
