import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/character-matcher_provider.dart' as character_matcher;
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
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: false, // Remove back button
              title: const Text(
                'Tes Kepribadian',
                style: TextStyle(color: Colors.black87),
              ),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (testProvider.error != null) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: false, // Remove back button
              title: const Text(
                'Tes Kepribadian',
                style: TextStyle(color: Colors.black87),
              ),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${testProvider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => testProvider.loadTest(),
                    child: const Text('Retry'),
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
          return const Scaffold(
            body: Center(
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
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading:
                false, // Remove back button - user must complete test
            title: const Text(
              'Tes Kepribadian',
              style: TextStyle(color: Colors.black87),
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.orange.shade50, Colors.white],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.orange.shade100,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.orange.shade600,
                      ),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Pertanyaan ${testProvider.currentQuestionIndex + 1}/${testProvider.totalQuestions}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      currentQuestion!.text,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Expanded(
                      child: ListView(
                        children:
                            currentQuestion.options.entries.map((entry) {
                              final optionKey = entry.key;
                              final option = entry.value;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Material(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  child: InkWell(
                                    onTap: () => _selectAnswer(optionKey),
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.orange.shade200,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: Colors.orange.shade50,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: Text(
                                                optionKey,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.orange.shade700,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Text(
                                              option.text,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.black87,
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
          ),
        );
      },
    );
  }
}
