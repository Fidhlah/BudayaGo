import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';
import '../main/main_screen.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';

class MascotResultScreen extends StatefulWidget {
  final String characterName;
  final String characterDescription;
  final String? characterImageUrl;
  final List<String> characterTraits;

  const MascotResultScreen({
    Key? key,
    required this.characterName,
    required this.characterDescription,
    this.characterImageUrl,
    this.characterTraits = const [],
  }) : super(key: key);

  @override
  State<MascotResultScreen> createState() => _MascotResultScreenState();
}

class _MascotResultScreenState extends State<MascotResultScreen> {
  @override
  void initState() {
    super.initState();
    // Save mascot to profile when result screen is shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _saveMascotToProfile();
    });
  }

  Future<void> _saveMascotToProfile() async {
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );

    // Save character name as mascot
    await profileProvider.updateProfile(mascot: widget.characterName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.orangePinkGradient,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(AppDimensions.paddingXL),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                    child: Image.asset(
                      'assets/images/artifacts/kartu2.jpeg',
                      width: 250,
                      height: 250,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
                          ),
                          child: Icon(
                            Icons.person,
                            size: 100,
                            color: AppColors.orange700,
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: AppDimensions.spaceXL + AppDimensions.spaceS),
                  Text(
                    'Selamat!',
                    style: AppTextStyles.h2.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: AppDimensions.spaceXS),
                  Text(
                    'Karakter kepribadianmu adalah',
                    style: AppTextStyles.h5.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  SizedBox(height: AppDimensions.spaceXS),
                  Text(
                    widget.characterName,
                    style: AppTextStyles.h1.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: AppDimensions.buttonHeightL,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to MainScreen and remove all previous routes
                        // User cannot go back to personality test
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MainScreen(),
                          ),
                          (route) => false, // Remove all previous routes
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.orange700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Mulai Petualangan!',
                        style: AppTextStyles.h5.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
