import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../services/karya_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';
import '../../widgets/custom_app_bar.dart';
import '../karya/karya_detail_screen.dart';

class OtherUserProfileScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String? mascot;
  final bool isPelakuBudaya;
  final int? level;
  final int? xp;
  final bool hideProgress;

  const OtherUserProfileScreen({
    super.key,
    required this.userId,
    required this.userName,
    this.mascot,
    this.isPelakuBudaya = false,
    this.level,
    this.xp,
    this.hideProgress = false,
  });

  @override
  State<OtherUserProfileScreen> createState() => _OtherUserProfileScreenState();
}

class _OtherUserProfileScreenState extends State<OtherUserProfileScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  List<Map<String, dynamic>>? _karyas;
  bool _isLoadingKaryas = true;

  @override
  void initState() {
    super.initState();
    _karyas = <Map<String, dynamic>>[];

    // Initialize TabController immediately for pelaku budaya
    if (widget.isPelakuBudaya) {
      _tabController = TabController(
        length: 2,
        vsync: this,
        initialIndex: 1, // Default to Karya tab for pelaku budaya
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadKaryas();
    });
  }

  Future<void> _loadKaryas() async {
    try {
      debugPrint('🔍 Loading karyas for userId: ${widget.userId}');

      if (widget.userId.isEmpty) {
        debugPrint('⚠️ userId is empty, skipping karya load');
        if (mounted) {
          setState(() {
            _karyas = [];
            _isLoadingKaryas = false;
          });
        }
        return;
      }

      final loadedKaryas = await KaryaService.getKaryasByUserId(widget.userId);
      debugPrint('✅ Loaded ${loadedKaryas.length} karyas');

      if (mounted) {
        setState(() {
          _karyas = loadedKaryas;
          _isLoadingKaryas = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading karyas: $e');
      if (mounted) {
        setState(() {
          _karyas = [];
          _isLoadingKaryas = false;
        });
      }
    }
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

  String _getMascotName() {
    return widget.mascot ?? 'User';
  }

  IconData _getIconFromCodePoint(int? codePoint) {
    switch (codePoint) {
      case 0xe838:
        return Icons.star;
      case 0xe7f2:
        return Icons.favorite;
      case 0xe55c:
        return Icons.home;
      case 0xe3af:
        return Icons.location_on;
      case 0xe3c7:
        return Icons.person;
      case 0xe3e4:
        return Icons.settings;
      case 0xe3f4:
        return Icons.shopping_cart;
      case 0xe1d8:
        return Icons.camera_alt;
      case 0xe3f7:
        return Icons.share;
      case 0xe3e6:
        return Icons.search;
      default:
        return Icons.auto_awesome;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomGradientAppBar(title: widget.userName),
      body:
          widget.isPelakuBudaya
              ? _buildPelakuBudayaBody()
              : _buildRegularUserBody(),
    );
  }

  Widget _buildRegularUserBody() {
    return SingleChildScrollView(
      child: Column(
        children: [_buildProfileHeader(context, false), _buildProgressTab()],
      ),
    );
  }

  Widget _buildPelakuBudayaBody() {
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
              _buildProgressTabWithHeader(context),
              _buildShowcaseTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressTabWithHeader(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [_buildProfileHeader(context, true), _buildProgressTab()],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, bool isPelakuBudaya) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.orangePinkGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.all(AppDimensions.paddingL),
      child: Column(
        children: [
          // Name and mascot badge
          Column(
            children: [
              Text(
                widget.userName,
                style: AppTextStyles.h4.copyWith(
                  color: AppColors.background,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppDimensions.spaceS),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingM,
                  vertical: AppDimensions.paddingS,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.isPelakuBudaya ? Icons.verified : _getMascotIcon(),
                      color: AppColors.batik700,
                      size: 20,
                    ),
                    SizedBox(width: AppDimensions.spaceS),
                    Text(
                      widget.isPelakuBudaya
                          ? 'Pelaku Budaya'
                          : _getMascotName(),
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.batik700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spaceL),

          // Character card and artifacts
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Character card
              Flexible(
                flex: 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  child: Image.asset(
                    'assets/images/artifacts/kartu2.jpeg',
                    width: 200,
                    height: 300,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 200,
                        height: 300,
                        color: AppColors.grey100,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _getMascotIcon(),
                              size: 50,
                              color: AppColors.grey400,
                            ),
                            SizedBox(height: 8),
                            Text(
                              widget.mascot ?? 'User',
                              style: TextStyle(
                                color: AppColors.grey400,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(width: AppDimensions.spaceS),

              // 5 Artifacts
              Flexible(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(5, (index) {
                    final isUnlocked = index < 4; // Hardcoded for now
                    final artifactNumber = index + 1;

                    return Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color:
                            isUnlocked
                                ? Colors.transparent
                                : AppColors.background.withOpacity(0.3),
                        shape: BoxShape.circle,
                        border:
                            isUnlocked
                                ? null
                                : Border.all(
                                  color: AppColors.background.withOpacity(0.5),
                                  width: 2,
                                ),
                      ),
                      child:
                          isUnlocked
                              ? ClipOval(
                                child: Image.asset(
                                  'assets/images/artifacts/artifact$artifactNumber.png',
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.broken_image,
                                      size: 24,
                                      color: AppColors.error,
                                    );
                                  },
                                ),
                              )
                              : Icon(
                                Icons.lock,
                                size: 24,
                                color: AppColors.background.withOpacity(0.7),
                              ),
                    );
                  }),
                ),
              ),
            ],
          ),

          // Display Name
          SizedBox(height: AppDimensions.spaceS),
          Text(
            widget.userName,
            style: AppTextStyles.h4.copyWith(color: AppColors.background),
          ),

          // Progress Bar (only if not hidden and has level data)
          if (!widget.hideProgress && widget.level != null) ...[
            SizedBox(height: AppDimensions.spaceS),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Level ${widget.level}',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.background,
                  ),
                ),
                Text(
                  '${widget.xp ?? 0}/${(widget.level ?? 1) * 100} XP',
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
                value: (widget.xp ?? 0) / ((widget.level ?? 1) * 100),
                minHeight: 10,
                backgroundColor: AppColors.background.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.background),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressTab() {
    return Padding(
      padding: EdgeInsets.all(AppDimensions.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pencapaian',
            style: AppTextStyles.h5.copyWith(color: AppColors.textPrimary),
          ),
          SizedBox(height: AppDimensions.spaceM),
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
                Icon(Icons.emoji_events, size: 48, color: AppColors.grey300),
                SizedBox(height: AppDimensions.spaceS),
                Text(
                  'Data pencapaian tidak ditampilkan',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShowcaseTab() {
    if (_isLoadingKaryas) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_karyas == null || _karyas!.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.art_track, size: 64, color: AppColors.grey300),
              SizedBox(height: AppDimensions.spaceM),
              Text(
                'Belum ada karya',
                style: AppTextStyles.h6.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: AppDimensions.spaceS),
              Text(
                '${widget.userName} belum mengunggah karya',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(AppDimensions.paddingM),
      itemCount: _karyas!.length,
      itemBuilder: (context, index) {
        final karya = _karyas![index];
        final imageUrl = karya['image_url'] as String?;
        final photos = imageUrl != null ? [imageUrl] : [];

        return Card(
          margin: EdgeInsets.only(bottom: AppDimensions.spaceL),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => KaryaDetailScreen(
                        karya: {
                          'id': karya['id'],
                          'name': karya['name'],
                          'description': karya['description'],
                          'tag': karya['tag'],
                          'imageUrl': karya['image_url'],
                          'creatorName': widget.userName,
                          'location': 'Indonesia',
                          'color': AppColors.batik700,
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
                              widget.userName,
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

                // Photos
                if (photos.isNotEmpty) _buildPhotoGrid(photos),

                // Content
                Padding(
                  padding: EdgeInsets.all(AppDimensions.paddingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        karya['name'] ?? 'Untitled',
                        style: AppTextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: AppDimensions.spaceXS),
                      Text(
                        karya['description'] ?? '',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Category tag
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
                        _getIconFromCodePoint(karya['icon_code_point']),
                        size: 16,
                        color: AppColors.batik700,
                      ),
                      SizedBox(width: 4),
                      Text(
                        karya['tag'] ?? 'Umum',
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
          ),
        );
      },
    );
  }

  Widget _buildPhotoGrid(List<dynamic> photos) {
    final photoCount = photos.length;

    if (photoCount == 0) return const SizedBox.shrink();

    return AspectRatio(
      aspectRatio: 1.0,
      child: ClipRRect(
        borderRadius: BorderRadius.zero,
        child: Builder(
          builder: (context) {
            if (photoCount == 1) {
              return _buildSinglePhoto(photos[0]);
            } else if (photoCount == 2) {
              return _buildTwoPhotos(photos);
            } else if (photoCount == 3) {
              return _buildThreePhotos(photos);
            } else {
              return _buildFourPhotos(photos);
            }
          },
        ),
      ),
    );
  }

  Widget _buildSinglePhoto(String photoUrl) {
    return Image.network(
      photoUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _buildPhotoPlaceholder();
      },
    );
  }

  Widget _buildTwoPhotos(List<dynamic> photos) {
    return Row(
      children: [
        Expanded(child: _buildPhoto(photos[0])),
        SizedBox(width: 2),
        Expanded(child: _buildPhoto(photos[1])),
      ],
    );
  }

  Widget _buildThreePhotos(List<dynamic> photos) {
    return Row(
      children: [
        Expanded(flex: 2, child: _buildPhoto(photos[0])),
        SizedBox(width: 2),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              Expanded(child: _buildPhoto(photos[1])),
              SizedBox(height: 2),
              Expanded(child: _buildPhoto(photos[2])),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFourPhotos(List<dynamic> photos) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildPhoto(photos[0])),
              SizedBox(width: 2),
              Expanded(child: _buildPhoto(photos[1])),
            ],
          ),
        ),
        SizedBox(height: 2),
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildPhoto(photos[2])),
              SizedBox(width: 2),
              Expanded(
                child:
                    photos.length > 3
                        ? _buildPhoto(photos[3])
                        : _buildPhotoPlaceholder(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhoto(String photoUrl) {
    return Image.network(
      photoUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _buildPhotoPlaceholder();
      },
    );
  }

  Widget _buildPhotoPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.batik200.withOpacity(0.6),
            AppColors.batik100.withOpacity(0.3),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.image,
          color: AppColors.background.withOpacity(0.7),
          size: 40,
        ),
      ),
    );
  }
}
