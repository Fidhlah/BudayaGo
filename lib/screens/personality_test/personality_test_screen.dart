import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/character-matcher_provider.dart' as character_matcher;
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';
import '../../widgets/custom_app_bar.dart';
import '../mascot_result/mascot_result_screen.dart';

class PersonalityTestScreen extends StatefulWidget {
  const PersonalityTestScreen({Key? key}) : super(key: key);

  @override
  State<PersonalityTestScreen> createState() => _PersonalityTestScreenState();
}

class _PersonalityTestScreenState extends State<PersonalityTestScreen> {
  @override
  void initState() {
    super.initState();
    // Load test questions from provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final testProvider =
          Provider.of<character_matcher.PersonalityTestProvider>(
            context,
            listen: false,
          );
      testProvider.loadTest();
    });
  }

  void _selectAnswer(String optionKey) async {
    final testProvider = Provider.of<character_matcher.PersonalityTestProvider>(
      context,
      listen: false,
    );

    // Submit answer and wait for completion if it's the last question
    await testProvider.submitAnswer(optionKey);

    // Check if test is complete
    if (testProvider.isTestComplete) {
      final character = testProvider.assignedCharacter;
      if (character != null) {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => MascotResultScreen(
                  characterName: character['name'],
                  characterDescription: character['description'],
                  characterImageUrl: character['image_url'],
                  characterTraits: List<String>.from(
                    character['personality_traits'] ?? [],
                  ),
                ),
          ),
        );
      } else {
        // Fallback if no character assigned
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mendapatkan hasil karakter')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<character_matcher.PersonalityTestProvider>(
      builder: (context, testProvider, _) {
        if (testProvider.isLoading) {
          return Scaffold(
            backgroundColor: AppColors.orange50,
            appBar: const CustomGradientAppBar(
              title: 'Tes Kepribadian',
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (testProvider.error != null) {
          return Scaffold(
            backgroundColor: AppColors.orange50,
            appBar: const CustomGradientAppBar(
              title: 'Tes Kepribadian',
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${testProvider.error}'),
                  SizedBox(height: AppDimensions.spaceM),
                  ElevatedButton(
                    onPressed: () => testProvider.loadTest(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          );
        }

        final currentQuestion = testProvider.currentQuestion;
        if (currentQuestion == null && !testProvider.isTestComplete) {
          return const Scaffold(
            body: Center(child: Text('No questions available')),
          );
        }

        // Show loading if test is complete and processing
        if (testProvider.isTestComplete) {
          return Scaffold(
            backgroundColor: AppColors.orange50,
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Menghitung hasil...'),
                ],
              ),
            ),
          );
        }

        final progress = testProvider.progress;

        return Scaffold(
          backgroundColor: AppColors.orange50,
          appBar: const CustomGradientAppBar(
            title: 'Tes Kepribadian',
          ),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.batik100,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.batik700,
                    ),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                  SizedBox(height: AppDimensions.spaceS),
                  Text(
                    'Pertanyaan ${testProvider.currentQuestionIndex + 1}/${testProvider.totalQuestions}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: AppDimensions.spaceXL),
                  Text(
                    currentQuestion!.text,
                    style: AppTextStyles.h5.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppDimensions.spaceXL),
                  Expanded(
                    child: ListView(
                      children:
                          currentQuestion.options.entries.map((entry) {
                            final optionKey = entry.key;
                            final option = entry.value;

                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: AppDimensions.spaceM,
                              ),
                              child: Material(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusL,
                                ),
                                elevation: 2,
                                child: InkWell(
                                  onTap: () => _selectAnswer(optionKey),
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusL,
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.all(
                                      AppDimensions.paddingM,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.batik200,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        AppDimensions.radiusL,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: AppColors.batik50,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              optionKey,
                                              style: AppTextStyles.labelLarge.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.batik700,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: AppDimensions.spaceM),
                                        Expanded(
                                          child: Text(
                                            option.text,
                                            style: AppTextStyles.bodyMedium.copyWith(
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
