import 'package:flutter/material.dart';
import '../models/character-matcher_questions_model.dart';
import '../services/character-matcher_service.dart';

/// Provider untuk manage personality test state
class PersonalityTestProvider with ChangeNotifier {
  final PersonalityTestService _testService = PersonalityTestService();

  List<TestQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  TestResult? _testResult;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<TestQuestion> get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  TestQuestion? get currentQuestion => 
      _questions.isNotEmpty ? _questions[_currentQuestionIndex] : null;
  TestResult? get testResult => _testResult;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isTestComplete => _currentQuestionIndex >= _questions.length;
  double get progress => _testService.getProgress(_currentQuestionIndex);
  int get totalQuestions => _testService.totalQuestions;

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
  void submitAnswer(String selectedOption) {
    if (currentQuestion == null) return;

    // Record answer
    _testService.recordAnswer(selectedOption, currentQuestion!);

    // Move to next question
    _currentQuestionIndex++;

    // If test is complete, calculate result
    if (isTestComplete) {
      _calculateResult();
    }

    notifyListeners();
  }

  /// Calculate final result
  void _calculateResult() {
    // TODO: Get actual user ID from auth provider
    _testResult = _testService.calculateResult('user_123');
  }

  /// Reset test for retake
  void resetTest() {
    _currentQuestionIndex = 0;
    _testResult = null;
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