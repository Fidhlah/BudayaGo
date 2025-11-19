import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/character-matcher_questions_model.dart';

/// Service untuk handle personality test logic
class PersonalityTestService {
  static const String _testJsonPath = 'assets/text/test.json';
  
  List<TestQuestion>? _questions;
  final Map<String, int> _dimensionScores = {
    'courage': 0,
    'empathy': 0,
    'spirituality': 0,
    'logic': 0,
    'principle': 0,
    'creativity': 0,
    'social': 0,
  };
  final Map<String, int> _dimensionMaxScores = {
    'courage': 0,
    'empathy': 0,
    'spirituality': 0,
    'logic': 0,
    'principle': 0,
    'creativity': 0,
    'social': 0,
  };

  /// Load questions from JSON
  Future<List<TestQuestion>> loadQuestions() async {
    if (_questions != null) return _questions!;

    try {
      final String jsonString = await rootBundle.loadString(_testJsonPath);
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      _questions = (jsonData['questions'] as List)
          .map((q) => TestQuestion.fromJson(q))
          .toList();

      // Calculate max scores for each dimension
      _calculateMaxScores();

      return _questions!;
    } catch (e) {
      throw Exception('Failed to load test questions: $e');
    }
  }

  /// Calculate maximum possible score for each dimension
  void _calculateMaxScores() {
    if (_questions == null) return;

    for (var question in _questions!) {
      for (var option in question.options.values) {
        option.weights.forEach((dimension, weight) {
          _dimensionMaxScores[dimension] = 
              (_dimensionMaxScores[dimension] ?? 0) + weight;
        });
      }
    }
  }

  /// Record user's answer
  void recordAnswer(String selectedOption, TestQuestion question) {
    final option = question.options[selectedOption];
    if (option == null) return;

    option.weights.forEach((dimension, weight) {
      _dimensionScores[dimension] = (_dimensionScores[dimension] ?? 0) + weight;
    });
  }

  /// Calculate final test result
  TestResult calculateResult(String userId) {
    Map<String, DimensionScore> dimensions = {};

    _dimensionScores.forEach((dimension, score) {
      final maxScore = _dimensionMaxScores[dimension] ?? 1;
      dimensions[dimension] = DimensionScore(
        score: score,
        maxScore: maxScore,
      );
    });

    return TestResult(
      userId: userId,
      timestamp: DateTime.now(),
      dimensions: dimensions,
    );
  }

  /// Reset test (for retaking)
  void resetTest() {
    _dimensionScores.updateAll((key, value) => 0);
  }

  /// Get current progress (0.0 to 1.0)
  double getProgress(int currentQuestionIndex) {
    if (_questions == null || _questions!.isEmpty) return 0.0;
    return (currentQuestionIndex + 1) / _questions!.length;
  }

  /// Get total number of questions
  int get totalQuestions => _questions?.length ?? 0;
}