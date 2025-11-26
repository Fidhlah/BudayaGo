import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';
import '../../services/karya_service.dart';
import '../profile/other_user_profile_screen.dart';
import '../../widgets/custom_app_bar.dart';

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
      debugPrint('🔄 KaryaScreen: Starting to load karya...');
      final karya = await KaryaService.loadAllKarya();
      debugPrint('📊 KaryaScreen: Received ${karya.length} karya items');
      if (mounted) {
        setState(() {
          _karyaItems =
              karya.map((item) {
                final creator = item['users'] as Map<String, dynamic>?;
                final creatorName =
                    '${creator?['display_name'] ?? creator?['username'] ?? 'Unknown'}';
                final creatorId = item['creator_id'] as String?;

                debugPrint(
                  '📦 Mapping karya: ${item['name']}, creator_id: $creatorId',
                );

                return {
                  'id': item['id'],
                  'name': item['name'],
                  'description': item['description'],
                  'creator': creatorName,
                  'creatorName': creatorName,
                  'creator_id': creatorId,
                  'tag': item['tag'],
                  'umkm': item['umkm_category'],
                  'location': 'Indonesia', // Default location
                  'color': Color(item['color'] ?? AppColors.batik700.value),
                  'height':
                      200.0 +
                      (item['name'].toString().length % 3) *
                          40.0, // Varied heights
                  'icon': _getIconFromCodePoint(item['icon_code_point']),
                  'imageUrl': item['image_url'],
                  'likes': item['likes'] ?? 0,
                  'views': item['views'] ?? 0,
                  'isPelakuBudaya': creator?['is_pelaku_budaya'] ?? false,
                  'hideProgress': creator?['hide_progress'] ?? false,
                };
              }).toList();
          _isLoading = false;
        });
        debugPrint(
          '✅ KaryaScreen: State updated with ${_karyaItems.length} items',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ KaryaScreen Error loading karya: $e');
      debugPrint('Stack trace: $stackTrace');
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
                final creatorId = item['creator_id'] as String?;

                debugPrint(
                  '🔍 Search result: ${item['name']}, creator_id: $creatorId',
                );

                return {
                  'id': item['id'],
                  'name': item['name'],
                  'description': item['description'],
                  'creator': creatorName,
                  'creatorName': creatorName,
                  'creator_id': creatorId,
                  'tag': item['tag'],
                  'umkm': item['umkm_category'],
                  'location': 'Indonesia', // Default location
                  'color': Color(item['color'] ?? AppColors.batik700.value),
                  'height': 200.0 + (item['name'].toString().length % 3) * 40.0,
                  'icon': _getIconFromCodePoint(item['icon_code_point']),
                  'imageUrl': item['image_url'],
                  'likes': item['likes'] ?? 0,
                  'views': item['views'] ?? 0,
                  'isPelakuBudaya': creator?['is_pelaku_budaya'] ?? false,
                  'hideProgress': creator?['hide_progress'] ?? false,
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
      backgroundColor: AppColors.orange50,
      appBar: CustomGradientAppBar(title: 'Karya Pelaku Budaya'),
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
                            Icons.palette_outlined,
                            size: AppDimensions.iconXL * 1.5,
                            color: AppColors.grey400,
                          ),
                          const SizedBox(height: AppDimensions.spaceM),
                          Text(
                            _searchQuery.isEmpty
                                ? 'Belum Ada Karya'
                                : 'Tidak ada karya yang ditemukan',
                            style: AppTextStyles.h6.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.spaceXS),
                          Text(
                            _searchQuery.isEmpty
                                ? 'Upload karya pertamamu sebagai Pelaku Budaya'
                                : 'Coba kata kunci lain',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textTertiary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (_searchQuery.isEmpty) ...[
                            const SizedBox(height: AppDimensions.spaceL),
                            ElevatedButton.icon(
                              onPressed: () {
                                // Navigate to home and switch to profile tab
                                Navigator.of(
                                  context,
                                ).popUntil((route) => route.isFirst);
                              },
                              icon: const Icon(Icons.upload),
                              label: const Text('Upgrade & Upload Karya'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.buttonColour,
                                foregroundColor: AppColors.background,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppDimensions.paddingL,
                                  vertical: AppDimensions.paddingM,
                                ),
                              ),
                            ),
                          ],
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
                      debugPrint(
                        '🔍 Karya item creator_id: ${item['creator_id']}',
                      );
                      debugPrint('🔍 Karya item keys: ${item.keys.toList()}');

                      final creatorId = item['creator_id'] as String? ?? '';
                      if (creatorId.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Creator ID tidak tersedia'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        return;
                      }

                      _navigateToUserProfile(
                        context,
                        creatorId,
                        item['creatorName'] as String,
                        null, // mascot
                        item['isPelakuBudaya'] as bool? ?? false,
                        item['hideProgress'] as bool? ?? false,
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

  // Build photo grid - display actual image from database
  Widget _buildPhotoGrid(BuildContext context, Map<String, dynamic> item) {
    final String? imageUrl = item['imageUrl'] as String?;

    // If no image, show placeholder
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        width: double.infinity,
        height: 300,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              (item['color'] as Color).withOpacity(0.8),
              (item['color'] as Color).withOpacity(0.4),
            ],
          ),
        ),
        child: Center(
          child: Icon(
            item['icon'] as IconData,
            size: 100,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      );
    }

    // Display actual image
    return GestureDetector(
      onTap: () => _showFullscreenPhoto(context, imageUrl),
      child: Container(
        width: double.infinity,
        height: 300,
        color: AppColors.grey200,
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value:
                    loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    (item['color'] as Color).withOpacity(0.8),
                    (item['color'] as Color).withOpacity(0.4),
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.broken_image,
                      size: 64,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Gagal memuat gambar',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Show fullscreen photo viewer
  void _showFullscreenPhoto(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.zero,
            child: Stack(
              children: [
                Center(
                  child: InteractiveViewer(
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value:
                                loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 20,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.white, size: 32),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  // Navigate to user profile
  void _navigateToUserProfile(
    BuildContext context,
    String userId,
    String userName,
    String? mascot,
    bool isPelakuBudaya,
    bool hideProgress,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => OtherUserProfileScreen(
              userId: userId,
              userName: userName,
              mascot: mascot,
              isPelakuBudaya: isPelakuBudaya,
              hideProgress: hideProgress,
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
