import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';
import '../../services/karya_service.dart';
import '../profile/other_user_profile_screen.dart';

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
                    : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: _karyaItems.length,
                      itemBuilder: (context, index) {
                        return _buildKaryaFeedCard(
                          context,
                          _karyaItems[index],
                          index,
                        );
                      },
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

  Widget _buildKaryaFeedCard(
    BuildContext context,
    Map<String, dynamic> item,
    int index,
  ) {
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.spaceS,
      ),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: User Info
          Padding(
            padding: EdgeInsets.all(AppDimensions.paddingM),
            child: Row(
              children: [
                // Avatar & Creator name (clickable)
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      _navigateToUserProfile(
                        context,
                        item['creatorName'] as String,
                        item['color'] as Color,
                        item['location'] as String?,
                      );
                    },
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                (item['color'] as Color).withOpacity(0.7),
                                (item['color'] as Color),
                              ],
                            ),
                          ),
                          child: Icon(
                            Icons.person,
                            color: AppColors.background,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: AppDimensions.spaceS),
                        // Creator name
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['creatorName'] as String,
                                style: AppTextStyles.labelLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (item['location'] != null)
                                Text(
                                  item['location'] as String,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Photo Grid (1-4 photos like Twitter/X)
          _buildPhotoGrid(context, item),

          // Content (nama + deskripsi)
          Padding(
            padding: EdgeInsets.all(AppDimensions.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Karya name and description in Instagram style
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    children: [
                      TextSpan(
                        text: '${item['creatorName']} ',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextSpan(
                        text: item['name'] as String,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item['description'] != null &&
                    (item['description'] as String).isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      item['description'] as String,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                SizedBox(height: AppDimensions.spaceS),
                // Tag chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: (item['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: (item['color'] as Color).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_offer,
                        size: 14,
                        color: item['color'] as Color,
                      ),
                      SizedBox(width: 4),
                      Text(
                        item['tag'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: item['color'] as Color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build photo grid (1-4 photos like Twitter/X)
  Widget _buildPhotoGrid(BuildContext context, Map<String, dynamic> item) {
    // Generate different number of photos based on item index for variation
    // Get a pseudo-random number of photos (1-4) based on item properties
    final int photoCount =
        ((item['name'] as String).length + (item['tag'] as String).length) % 4 +
        1;

    // Create photo list with variations
    final List<Map<String, dynamic>> photos = [];
    final List<IconData> iconVariations = [
      Icons.photo,
      Icons.image,
      Icons.collections,
      Icons.wallpaper,
    ];

    for (int i = 0; i < photoCount; i++) {
      photos.add({
        'color': item['color'],
        'icon':
            i == 0 ? item['icon'] : iconVariations[i % iconVariations.length],
      });
    }

    if (photoCount == 1) {
      return _buildSinglePhoto(context, photos[0], 0, photos);
    } else if (photoCount == 2) {
      return _buildTwoPhotos(context, photos);
    } else if (photoCount == 3) {
      return _buildThreePhotos(context, photos);
    } else {
      return _buildFourPhotos(context, photos);
    }
  }

  // Single photo layout
  Widget _buildSinglePhoto(
    BuildContext context,
    Map<String, dynamic> photo,
    int index,
    List<Map<String, dynamic>> allPhotos,
  ) {
    return GestureDetector(
      onTap: () => _showFullscreenPhoto(context, index, allPhotos),
      child: Container(
        width: double.infinity,
        height: 400,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              (photo['color'] as Color).withOpacity(0.8),
              (photo['color'] as Color).withOpacity(0.4),
            ],
          ),
        ),
        child: Center(
          child: Icon(
            photo['icon'] as IconData,
            size: 120,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  // Two photos layout (side by side)
  Widget _buildTwoPhotos(
    BuildContext context,
    List<Map<String, dynamic>> photos,
  ) {
    return SizedBox(
      height: 300,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _showFullscreenPhoto(context, 0, photos),
              child: Container(
                margin: const EdgeInsets.only(right: 1),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      (photos[0]['color'] as Color).withOpacity(0.8),
                      (photos[0]['color'] as Color).withOpacity(0.4),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    photos[0]['icon'] as IconData,
                    size: 80,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _showFullscreenPhoto(context, 1, photos),
              child: Container(
                margin: const EdgeInsets.only(left: 1),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      (photos[1]['color'] as Color).withOpacity(0.8),
                      (photos[1]['color'] as Color).withOpacity(0.4),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    photos[1]['icon'] as IconData,
                    size: 80,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Three photos layout (left big, right 2 stacked)
  Widget _buildThreePhotos(
    BuildContext context,
    List<Map<String, dynamic>> photos,
  ) {
    return SizedBox(
      height: 300,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () => _showFullscreenPhoto(context, 0, photos),
              child: Container(
                margin: const EdgeInsets.only(right: 1),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      (photos[0]['color'] as Color).withOpacity(0.8),
                      (photos[0]['color'] as Color).withOpacity(0.4),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    photos[0]['icon'] as IconData,
                    size: 80,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showFullscreenPhoto(context, 1, photos),
                    child: Container(
                      margin: const EdgeInsets.only(left: 1, bottom: 1),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            (photos[1]['color'] as Color).withOpacity(0.8),
                            (photos[1]['color'] as Color).withOpacity(0.4),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          photos[1]['icon'] as IconData,
                          size: 60,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showFullscreenPhoto(context, 2, photos),
                    child: Container(
                      margin: const EdgeInsets.only(left: 1, top: 1),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            (photos[2]['color'] as Color).withOpacity(0.8),
                            (photos[2]['color'] as Color).withOpacity(0.4),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          photos[2]['icon'] as IconData,
                          size: 60,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Four photos layout (2x2 grid)
  Widget _buildFourPhotos(
    BuildContext context,
    List<Map<String, dynamic>> photos,
  ) {
    return SizedBox(
      height: 300,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showFullscreenPhoto(context, 0, photos),
                    child: Container(
                      margin: const EdgeInsets.only(right: 1, bottom: 1),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            (photos[0]['color'] as Color).withOpacity(0.8),
                            (photos[0]['color'] as Color).withOpacity(0.4),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          photos[0]['icon'] as IconData,
                          size: 60,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showFullscreenPhoto(context, 1, photos),
                    child: Container(
                      margin: const EdgeInsets.only(left: 1, bottom: 1),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            (photos[1]['color'] as Color).withOpacity(0.8),
                            (photos[1]['color'] as Color).withOpacity(0.4),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          photos[1]['icon'] as IconData,
                          size: 60,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showFullscreenPhoto(context, 2, photos),
                    child: Container(
                      margin: const EdgeInsets.only(right: 1, top: 1),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            (photos[2]['color'] as Color).withOpacity(0.8),
                            (photos[2]['color'] as Color).withOpacity(0.4),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          photos[2]['icon'] as IconData,
                          size: 60,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showFullscreenPhoto(context, 3, photos),
                    child: Container(
                      margin: const EdgeInsets.only(left: 1, top: 1),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            (photos[3]['color'] as Color).withOpacity(0.8),
                            (photos[3]['color'] as Color).withOpacity(0.4),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          photos[3]['icon'] as IconData,
                          size: 60,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Show fullscreen photo viewer
  void _showFullscreenPhoto(
    BuildContext context,
    int initialIndex,
    List<Map<String, dynamic>> photos,
  ) {
    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder:
          (context) => _FullscreenPhotoViewer(
            photos: photos,
            initialIndex: initialIndex,
          ),
    );
  }

  // Navigate to user profile
  void _navigateToUserProfile(
    BuildContext context,
    String userName,
    Color userColor,
    String? location,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => OtherUserProfileScreen(
              userName: userName,
              userColor: userColor,
              location: location,
            ),
      ),
    );
  }
}

// Fullscreen photo viewer widget
class _FullscreenPhotoViewer extends StatefulWidget {
  final List<Map<String, dynamic>> photos;
  final int initialIndex;

  const _FullscreenPhotoViewer({
    required this.photos,
    required this.initialIndex,
  });

  @override
  State<_FullscreenPhotoViewer> createState() => _FullscreenPhotoViewerState();
}

class _FullscreenPhotoViewerState extends State<_FullscreenPhotoViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Photo viewer with swipe
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.photos.length,
            itemBuilder: (context, index) {
              final photo = widget.photos[index];
              return Center(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        (photo['color'] as Color).withOpacity(0.8),
                        (photo['color'] as Color).withOpacity(0.4),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      photo['icon'] as IconData,
                      size: 200,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
              );
            },
          ),

          // Close button (X)
          Positioned(
            top: 40,
            right: 16,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, color: Colors.white, size: 32),
            ),
          ),

          // Photo counter
          if (widget.photos.length > 1)
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${widget.photos.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
