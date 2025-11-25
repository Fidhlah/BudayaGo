import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import '../../theme/app_colors.dart';
import '../../services/eksplorasi_service.dart';
import 'cultural_object_detail_screen.dart';

class CulturalObjectsScreen extends StatefulWidget {
  final String categoryName;
  final String categoryId;
  final Color categoryColor;
  final IconData categoryIcon;
  final bool isProvince; // Flag to indicate if filtering by province

  const CulturalObjectsScreen({
    Key? key,
    required this.categoryName,
    required this.categoryId,
    required this.categoryColor,
    required this.categoryIcon,
    this.isProvince = false, // Default to category filtering
  }) : super(key: key);

  @override
  State<CulturalObjectsScreen> createState() => _CulturalObjectsScreenState();
}

class _CulturalObjectsScreenState extends State<CulturalObjectsScreen> {
  List<Map<String, dynamic>> _contents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    try {
      // Load content based on filter type (province or category)
      final contents = widget.isProvince
          ? await EksplorasiService.loadContentByProvince(widget.categoryId)
          : await EksplorasiService.loadContentByCategory(widget.categoryId);
          
      if (mounted) {
        setState(() {
          _contents = contents;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading content: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  double _getCardHeight(int index) {
    // Pattern tinggi yang bervariasi seperti referensi
    final heights = [180.0, 150.0, 200.0, 160.0, 170.0, 190.0];
    return heights[index % heights.length];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.orange50,
        appBar: CustomGradientAppBar(
          title: widget.categoryName,
          showBackButton: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.orange50,
      appBar: CustomGradientAppBar(
        title: widget.categoryName,
        showBackButton: true,
      ),
      body: Column(
        children: [
          // Header info badge
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                Icon(
                  widget.categoryIcon,
                  color: widget.categoryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.isProvince
                      ? 'Budaya dari ${widget.categoryName}'
                      : 'Kategori: ${widget.categoryName}',
                  style: TextStyle(
                    color: widget.categoryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: widget.categoryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_contents.length} Konten',
                    style: TextStyle(
                      color: widget.categoryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Content area
          Expanded(
            child: _contents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.categoryIcon,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada konten',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.isProvince
                              ? 'Konten dari ${widget.categoryName} akan segera ditambahkan'
                              : 'Konten untuk kategori ini akan segera ditambahkan',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: _buildMasonryLayout(context, _contents),
                    ),
                  ),
          ),
        ],
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
                    .asMap()
                    .entries
                    .map(
                      (entry) => _buildMasonryCard(
                        context,
                        entry.value,
                        entry.key * 2,
                      ),
                    )
                    .toList(),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            children:
                rightColumn
                    .asMap()
                    .entries
                    .map(
                      (entry) => _buildMasonryCard(
                        context,
                        entry.value,
                        entry.key * 2 + 1,
                      ),
                    )
                    .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMasonryCard(
    BuildContext context,
    Map<String, dynamic> object,
    int index,
  ) {
    return InkWell(
      onTap: () {
        // Extract province name from nested object or use fallback
        String provinceName = 'Indonesia';
        if (object['provinces'] != null && object['provinces'] is Map) {
          provinceName = object['provinces']['name'] ?? 'Indonesia';
        } else if (object['province_name'] != null) {
          provinceName = object['province_name'];
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => CulturalObjectDetailScreen(
                  contentId: object['id'] ?? '',
                  objectName: object['title'] ?? 'Objek Budaya',
                  region: provinceName,
                  description:
                      object['description'] ?? 'Deskripsi tidak tersedia',
                  fullContent:
                      object['full_content'] ??
                      object['description'] ??
                      'Konten tidak tersedia',
                  xp: object['xp_reward'] ?? 150,
                  categoryColor: widget.categoryColor,
                  categoryIcon: widget.categoryIcon,
                  imageUrl: object['image_url'],
                ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child:
                  object['image_url'] != null
                      ? Image.network(
                        object['image_url'],
                        height: _getCardHeight(index),
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: _getCardHeight(index),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  widget.categoryColor.withOpacity(0.3),
                                  widget.categoryColor.withOpacity(0.1),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Icon(
                              widget.categoryIcon,
                              size: 50,
                              color: widget.categoryColor.withOpacity(0.5),
                            ),
                          );
                        },
                      )
                      : Container(
                        height: _getCardHeight(index),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              widget.categoryColor.withOpacity(0.3),
                              widget.categoryColor.withOpacity(0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Icon(
                          widget.categoryIcon,
                          size: 50,
                          color: widget.categoryColor.withOpacity(0.5),
                        ),
                      ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    object['title'] ?? 'Objek Budaya',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Show different info based on filter type
                  Row(
                    children: [
                      Icon(
                        widget.isProvince ? Icons.category : Icons.location_on,
                        size: 12,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.isProvince
                              ? (object['cultural_categories']?['name'] ?? 'Budaya')
                              : (object['provinces']?['name'] ?? 'Indonesia'),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, size: 14, color: Colors.orange.shade600),
                      const SizedBox(width: 4),
                      Text(
                        '${object['xp_reward'] ?? 150} XP',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
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
  }
}
