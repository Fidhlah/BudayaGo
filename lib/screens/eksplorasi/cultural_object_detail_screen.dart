import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../widgets/custom_app_bar.dart';
import '../../theme/app_colors.dart';

class CulturalObjectDetailScreen extends StatefulWidget {
  final String objectName;
  final String region;
  final String description;
  final String fullContent;
  final int xp;
  final Color categoryColor;
  final IconData categoryIcon;
  final String? imageUrl;

  const CulturalObjectDetailScreen({
    Key? key,
    required this.objectName,
    required this.region,
    required this.description,
    required this.fullContent,
    required this.xp,
    required this.categoryColor,
    required this.categoryIcon,
    this.imageUrl,
  }) : super(key: key);

  @override
  State<CulturalObjectDetailScreen> createState() =>
      _CulturalObjectDetailScreenState();
}

class _CulturalObjectDetailScreenState
    extends State<CulturalObjectDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _hasReadToBottom = false;
  bool _hasClaimedXP = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      if (!_hasReadToBottom) {
        setState(() {
          _hasReadToBottom = true;
        });
      }
    }
  }

  void _claimXP() {
    if (_hasClaimedXP) return;

    setState(() {
      _hasClaimedXP = true;
    });

    // TODO: Simpan ke database bahwa user telah claim XP untuk konten ini
    // TODO: Update total XP user

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade400, Colors.orange.shade700],
                    ),
                  ),
                  child: const Icon(Icons.star, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Selamat!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Kamu mendapatkan ${widget.xp} XP',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Back to list
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.orange50,
      appBar: CustomGradientAppBar(
        title: widget.objectName,
        showBackButton: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 200,
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
                        size: 100,
                        color: widget.categoryColor.withOpacity(0.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Region Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: widget.categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: widget.categoryColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: widget.categoryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.region,
                          style: TextStyle(
                            fontSize: 14,
                            color: widget.categoryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // XP Badge
                  Row(
                    children: [
                      Icon(Icons.star, size: 20, color: Colors.orange.shade600),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.xp} XP',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Full Content with Markdown
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: MarkdownBody(
                        data: widget.fullContent,
                        styleSheet: MarkdownStyleSheet(
                          h1: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          h2: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: widget.categoryColor,
                            height: 2.0,
                          ),
                          h3: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            height: 1.8,
                          ),
                          p: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                            height: 1.6,
                          ),
                          listBullet: TextStyle(color: widget.categoryColor),
                          strong: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 100), // Space for button
                ],
              ),
            ),
          ),

          // Bottom Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      _hasReadToBottom && !_hasClaimedXP ? _claimXP : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _hasClaimedXP
                            ? Colors.grey.shade400
                            : (_hasReadToBottom
                                ? Colors.orange.shade700
                                : Colors.grey.shade300),
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: _hasReadToBottom && !_hasClaimedXP ? 2 : 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _hasClaimedXP
                            ? Icons.check_circle
                            : (_hasReadToBottom
                                ? Icons.star
                                : Icons.arrow_downward),
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _hasClaimedXP
                            ? 'XP Sudah Diklaim'
                            : (_hasReadToBottom
                                ? 'Selesai Baca & Claim ${widget.xp} XP'
                                : 'Scroll untuk Selesai Baca'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
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
