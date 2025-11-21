import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';
import '../../services/karya_service.dart';
import 'karya_detail_screen.dart';

class KaryaScreen extends StatefulWidget {
  const KaryaScreen({Key? key}) : super(key: key);

  @override
  State<KaryaScreen> createState() => _KaryaScreenState();
}

class _KaryaScreenState extends State<KaryaScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _showSuggestions = false;
  List<Map<String, dynamic>> _karyaItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadKarya();
    _searchFocusNode.addListener(() {
      setState(() {
        _showSuggestions = _searchFocusNode.hasFocus;
      });
    });
  }

  Future<void> _loadKarya() async {
    setState(() => _isLoading = true);
    try {
      final karya = await KaryaService.loadAllKarya();
      if (mounted) {
        setState(() {
          _karyaItems =
              karya.map((item) {
                final creator = item['users'] as Map<String, dynamic>?;
                final creatorName =
                    '${creator?['display_name'] ?? creator?['username'] ?? 'Unknown'}';
                return {
                  'id': item['id'],
                  'name': item['name'],
                  'description': item['description'],
                  'creator': creatorName,
                  'creatorName': creatorName,
                  'tag': item['tag'],
                  'umkm': item['umkm_category'],
                  'location': item['location'],
                  'color': Color(item['color'] ?? AppColors.batik700.value),
                  'height':
                      200.0 +
                      (item['name'].toString().length % 3) *
                          40.0, // Varied heights
                  'icon': IconData(
                    item['icon_code_point'] ?? Icons.auto_awesome.codePoint,
                    fontFamily: 'MaterialIcons',
                  ),
                  'imageUrl': item['image_url'],
                  'likes': item['likes'] ?? 0,
                  'views': item['views'] ?? 0,
                };
              }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading karya: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _searchKarya(String query) async {
    if (query.isEmpty) {
      _loadKarya();
      return;
    }

    setState(() => _isLoading = true);
    try {
      final results = await KaryaService.searchKarya(query);
      if (mounted) {
        setState(() {
          _karyaItems =
              results.map((item) {
                final creator = item['users'] as Map<String, dynamic>?;
                final creatorName =
                    '${creator?['display_name'] ?? creator?['username'] ?? 'Unknown'}';
                return {
                  'id': item['id'],
                  'name': item['name'],
                  'description': item['description'],
                  'creator': creatorName,
                  'creatorName': creatorName,
                  'tag': item['tag'],
                  'umkm': item['umkm_category'],
                  'location': item['location'],
                  'color': Color(item['color'] ?? AppColors.batik700.value),
                  'height': 200.0 + (item['name'].toString().length % 3) * 40.0,
                  'icon': IconData(
                    item['icon_code_point'] ?? Icons.auto_awesome.codePoint,
                    fontFamily: 'MaterialIcons',
                  ),
                  'imageUrl': item['image_url'],
                  'likes': item['likes'] ?? 0,
                  'views': item['views'] ?? 0,
                };
              }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error searching karya: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Karya Pelaku Budaya')),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            color: AppColors.orange50,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Cari karya, pelaku, atau tag...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.primary,
                    ),
                    suffixIcon:
                        _searchQuery.isNotEmpty
                            ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: AppColors.primary,
                              ),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                });
                              },
                            )
                            : null,
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                    // Debounce search
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (_searchQuery == value.toLowerCase()) {
                        _searchKarya(value);
                      }
                    });
                  },
                ),
                // Tag suggestions
                if (_showSuggestions && _searchQuery.isEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: AppDimensions.spaceS),
                    padding: const EdgeInsets.all(AppDimensions.paddingS),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusL,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.local_offer,
                              size: 16,
                              color: AppColors.orange700,
                            ),
                            const SizedBox(width: AppDimensions.spaceXS),
                            Text(
                              'Cari berdasarkan tag',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildTagChip('Batik', AppColors.blue),
                            _buildTagChip('Furniture', AppColors.brown),
                            _buildTagChip('Keramik', AppColors.orange),
                            _buildTagChip('Anyaman', AppColors.green),
                            _buildTagChip('Tenun', AppColors.purple),
                            _buildTagChip('Wayang', AppColors.red),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // Content
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _karyaItems.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: AppDimensions.iconXL,
                            color: AppColors.grey400,
                          ),
                          const SizedBox(height: AppDimensions.spaceM),
                          Text(
                            'Tidak ada karya yang ditemukan',
                            style: AppTextStyles.h6.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.spaceXS),
                          Text(
                            'Coba kata kunci lain',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    )
                    : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _buildMasonryLayout(context, _karyaItems),
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip(String tag, Color color) {
    return InkWell(
      onTap: () {
        setState(() {
          _searchController.text = tag;
          _searchQuery = tag.toLowerCase();
          _searchFocusNode.unfocus();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_offer, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              tag,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMasonryLayout(
    BuildContext context,
    List<Map<String, dynamic>> items,
  ) {
    // Split items into 2 columns
    final leftColumn = <Map<String, dynamic>>[];
    final rightColumn = <Map<String, dynamic>>[];

    for (int i = 0; i < items.length; i++) {
      if (i % 2 == 0) {
        leftColumn.add(items[i]);
      } else {
        rightColumn.add(items[i]);
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children:
                leftColumn
                    .map((item) => _buildKaryaCard(context, item))
                    .toList(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            children:
                rightColumn
                    .map((item) => _buildKaryaCard(context, item))
                    .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildKaryaCard(BuildContext context, Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          // Navigate ke detail screen karya spesifik
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => KaryaDetailScreen(karya: item),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area with gradient
            Container(
              height: item['height'] as double,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    (item['color'] as Color).withOpacity(0.8),
                    (item['color'] as Color).withOpacity(0.4),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Decorative icon
                  Center(
                    child: Icon(
                      item['icon'] as IconData,
                      size: 60,
                      color: Colors.white.withOpacity(0.4),
                    ),
                  ),
                  // Tag at bottom
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item['tag'] as String,
                        style: TextStyle(
                          fontSize: 12,
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
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'] as String,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['creator'] as String,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
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
    );
  }
}
