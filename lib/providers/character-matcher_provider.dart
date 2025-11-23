import 'package:flutter/material.dart';
import '../models/character-matcher_questions_model.dart';
import '../services/character-matcher_service.dart';
import '../services/quiz_service.dart';
import '../config/supabase_config.dart';

/// Provider untuk manage personality test state
class PersonalityTestProvider with ChangeNotifier {
  final PersonalityTestService _testService = PersonalityTestService();

  List<TestQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  TestResult? _testResult;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _assignedCharacter;

  // Getters
  List<TestQuestion> get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  TestQuestion? get currentQuestion =>
      _questions.isNotEmpty &&
              _currentQuestionIndex >= 0 &&
              _currentQuestionIndex < _questions.length
          ? _questions[_currentQuestionIndex]
          : null;
  TestResult? get testResult => _testResult;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isTestComplete => _currentQuestionIndex >= _questions.length;
  double get progress => _testService.getProgress(_currentQuestionIndex);
  int get totalQuestions => _testService.totalQuestions;
  Map<String, dynamic>? get assignedCharacter => _assignedCharacter;

  /// Load test questions
  Future<void> loadTest() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _questions = await _testService.loadQuestions();
      _currentQuestionIndex = 0;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Submit answer and move to next question
  Future<void> submitAnswer(String selectedOption) async {
    if (currentQuestion == null) return;

    debugPrint('\n' + '=' * 80);
    debugPrint(
      '📋 PERSONALITY TEST - Question ${_currentQuestionIndex + 1}/${_questions.length}',
    );
    debugPrint('=' * 80);
    debugPrint('❓ Question: ${currentQuestion!.text.substring(0, 50)}...');

    // Record answer
    _testService.recordAnswer(selectedOption, currentQuestion!);

    // Move to next question
    _currentQuestionIndex++;

    debugPrint('➡️  Moving to question ${_currentQuestionIndex + 1}');
    debugPrint('=' * 80 + '\n');

    // If test is complete, calculate result (await to finish before UI navigates)
    if (isTestComplete) {
      await _calculateResult();
    } else {
      notifyListeners();
    }
  }

  /// Calculate final result and submit to database
  Future<void> _calculateResult() async {
    try {
      _isLoading = true;
      // Don't notify here - let UI handle based on isTestComplete
      // notifyListeners();

      // Get user ID from auth
      final userId = SupabaseConfig.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      debugPrint('📊 Calculating personality test result...');
      debugPrint('   Dimension Scores: ${_testService.dimensionScores}');

      // Get local test result (for display purposes)
      _testResult = _testService.calculateResult(userId);

      // Submit raw scores to database and call process_personality_test():
      // 1. Save raw scores to personality_test_results
      // 2. Call process_personality_test() function which will:
      //    - Calculate max scores from quiz_answers table
      //    - Normalize scores (raw/max * 100)
      //    - Calculate Euclidean Distance with all characters
      //    - Assign character with minimum distance
      //    - Update users.character_id and users.quiz_completed = true
      debugPrint('📤 Submitting raw scores to database...');

      final result = await QuizService.submitTestResults(
        userId: userId,
        scores: _testService.dimensionScores,
        answers: _testService.userAnswers,
      );

      if (result['success'] == true) {
        _assignedCharacter = result['character'];
        debugPrint('✅ Character matched: ${_assignedCharacter!['name']}');
        debugPrint('   Description: ${_assignedCharacter!['description']}');
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error calculating result: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Reset test for retake
  void resetTest() {
    _currentQuestionIndex = 0;
    _testResult = null;
    _assignedCharacter = null;
    _error = null;
    _testService.resetTest();
    notifyListeners();
  }

  /// Go to specific question (for review)
  void goToQuestion(int index) {
    if (index >= 0 && index < _questions.length) {
      _currentQuestionIndex = index;
      notifyListeners();
    }
  }
}
