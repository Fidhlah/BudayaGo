import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Custom AppBar dengan gradient dan pola batik untuk konsistensi UI
class CustomGradientAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final Widget? leadingIcon;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Color>? gradientColors;
  final Widget? bottom;
  final double? bottomHeight;

  const CustomGradientAppBar({
    Key? key,
    required this.title,
    this.leadingIcon,
    this.actions,
    this.showBackButton = false,
    this.onBackPressed,
    this.gradientColors,
    this.bottom,
    this.bottomHeight,
  }) : super(key: key);

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottomHeight ?? 0));

  @override
  Widget build(BuildContext context) {
    final colors =
        gradientColors ??
        [AppColors.batik800, AppColors.batik600, AppColors.batikGold];

    return AppBar(
      leading:
          showBackButton
              ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              )
              : leadingIcon,
      centerTitle: false,
      titleSpacing: 8,
      title: Text(
        title,
        style: AppTextStyles.h5.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: actions,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
        ),
        child: Stack(
          children: [
            // Pattern Background
            Positioned.fill(
              child: Opacity(
                opacity: 0.1,
                child: CustomPaint(painter: BatikPatternPainter()),
              ),
            ),
          ],
        ),
      ),
      bottom: bottom as PreferredSizeWidget?,
    );
  }
}

/// Custom Painter untuk Batik Pattern Background
class BatikPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
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
