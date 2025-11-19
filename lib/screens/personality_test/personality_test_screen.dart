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

  void _selectAnswer(String optionKey) {
    final testProvider = Provider.of<character_matcher.PersonalityTestProvider>(
      context,
      listen: false,
    );

    testProvider.submitAnswer(optionKey);

    // Check if test is complete
    if (testProvider.isTestComplete) {
      final result = testProvider.testResult;
      if (result != null) {
        // Get highest dimension as mascot type
        String mascot = _getDominantDimension(result.dimensions);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MascotResultScreen(mascot: mascot),
          ),
        );
      }
    }
  }

  String _getDominantDimension(Map<String, dynamic> dimensions) {
    // Convert dimensions to sorted list
    var sortedDimensions =
        dimensions.entries.toList()..sort(
          (a, b) => (b.value.percentage as double).compareTo(
            a.value.percentage as double,
          ),
        );

    // Map dimension to mascot
    final dimensionToMascot = {
      'Spiritual': 'Wayang',
      'Creative': 'Batik',
      'Analytical': 'Keris',
      'Social': 'Angklung',
    };

    return dimensionToMascot[sortedDimensions.first.key] ?? 'Wayang';
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
        if (currentQuestion == null) {
          return const Scaffold(
            body: Center(child: Text('No questions available')),
          );
        }

        final progress = testProvider.progress;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
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
                      currentQuestion.text,
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
