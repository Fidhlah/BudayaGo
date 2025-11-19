import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class Question {
  final int id;
  final String question;
  final List<Answer> answers;

  Question({required this.id, required this.question, required this.answers});

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as int,
      question: json['question'] as String,
      answers:
          (json['answers'] as List)
              .map((a) => Answer.fromJson(a as Map<String, dynamic>))
              .toList(),
    );
  }
}

class Answer {
  final String id;
  final String text;
  final Map<String, int> weights;

  Answer({required this.id, required this.text, required this.weights});

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      id: json['id'] as String,
      text: json['text'] as String,
      weights: Map<String, int>.from(json['weights'] as Map),
    );
  }
}

class TestResult {
  final String mascot;
  final Map<String, int> scores;
  final String description;
  final List<String> traits;

  TestResult({
    required this.mascot,
    required this.scores,
    required this.description,
    required this.traits,
  });
}

class PersonalityTestProvider extends ChangeNotifier {
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  final Map<int, String> _answers = {}; // questionId -> answerId
  Map<String, int> _scores = {
    'logic': 0,
    'courage': 0,
    'spirituality': 0,
    'creativity': 0,
    'empathy': 0,
    'social': 0,
    'principle': 0,
  };
  bool _isLoading = false;
  String? _error;
  TestResult? _result;

  // Getters
  List<Question> get questions => List.unmodifiable(_questions);
  int get currentQuestionIndex => _currentQuestionIndex;
  int get totalQuestions => _questions.length;
  bool get isLoading => _isLoading;
  String? get error => _error;
  TestResult? get result => _result;
  bool get isTestComplete => _answers.length == _questions.length;
  double get progress =>
      _questions.isEmpty ? 0 : _answers.length / _questions.length;

  Question? get currentQuestion =>
      _currentQuestionIndex < _questions.length
          ? _questions[_currentQuestionIndex]
          : null;

  /// Load questions from assets
  Future<void> loadQuestions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/personality_questions.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      _questions =
          (jsonData['questions'] as List)
              .map((q) => Question.fromJson(q as Map<String, dynamic>))
              .toList();

      _currentQuestionIndex = 0;
      _answers.clear();
      _scores = {
        'logic': 0,
        'courage': 0,
        'spirituality': 0,
        'creativity': 0,
        'empathy': 0,
        'social': 0,
        'principle': 0,
      };

      debugPrint('✅ Loaded ${_questions.length} questions');
    } catch (e) {
      _error = 'Failed to load questions: $e';
      debugPrint('❌ PersonalityTestProvider.loadQuestions error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Answer current question and move to next
  void answerQuestion(String answerId) {
    if (currentQuestion == null) return;

    final question = currentQuestion!;
    final answer = question.answers.firstWhere((a) => a.id == answerId);

    // Save answer
    _answers[question.id] = answerId;

    // Update scores
    answer.weights.forEach((key, value) {
      _scores[key] = (_scores[key] ?? 0) + value;
    });

    debugPrint('✅ Answered Q${question.id}: ${answer.text}');
    debugPrint('   Current scores: $_scores');

    // Move to next question
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
    }

    notifyListeners();

    // If test is complete, calculate result
    if (isTestComplete) {
      calculateResult();
    }
  }

  /// Go to previous question
  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  /// Go to specific question (for review)
  void goToQuestion(int index) {
    if (index >= 0 && index < _questions.length) {
      _currentQuestionIndex = index;
      notifyListeners();
    }
  }

  /// Calculate personality result
  void calculateResult() {
    // Find the highest score trait
    String topTrait =
        _scores.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    // Determine mascot based on top trait
    String mascot = _getMascotForTrait(topTrait);
    String description = _getDescriptionForMascot(mascot);
    List<String> traits = _getTraitsForMascot(mascot);

    _result = TestResult(
      mascot: mascot,
      scores: Map.from(_scores),
      description: description,
      traits: traits,
    );

    debugPrint('✅ Test complete! Mascot: $mascot');
    debugPrint('   Final scores: $_scores');

    notifyListeners();
  }

  String _getMascotForTrait(String trait) {
    switch (trait) {
      case 'logic':
        return 'Komodo';
      case 'courage':
        return 'Harimau';
      case 'spirituality':
        return 'Garuda';
      case 'creativity':
        return 'Merak';
      case 'empathy':
        return 'Orangutan';
      case 'social':
        return 'Gajah';
      case 'principle':
        return 'Banteng';
      default:
        return 'Komodo';
    }
  }

  String _getDescriptionForMascot(String mascot) {
    switch (mascot) {
      case 'Komodo':
        return 'Kamu adalah pemikir yang tajam dan analitis! Seperti komodo yang sabar dan strategis dalam berburu.';
      case 'Harimau':
        return 'Kamu adalah jiwa pemberani dan penuh semangat! Seperti harimau yang gagah dan tidak takut menghadapi tantangan.';
      case 'Garuda':
        return 'Kamu memiliki jiwa spiritual yang dalam! Seperti garuda yang bijaksana dan visioner.';
      case 'Merak':
        return 'Kamu adalah pribadi kreatif dan inovatif! Seperti merak yang indah dan penuh ekspresi.';
      case 'Orangutan':
        return 'Kamu memiliki empati yang tinggi! Seperti orangutan yang peduli dan penuh kasih sayang.';
      case 'Gajah':
        return 'Kamu adalah sosok yang ramah dan suka bersosialisasi! Seperti gajah yang hidup berkelompok.';
      case 'Banteng':
        return 'Kamu memegang teguh prinsip dan nilai! Seperti banteng yang kuat dan konsisten.';
      default:
        return 'Kamu memiliki kepribadian yang unik!';
    }
  }

  List<String> _getTraitsForMascot(String mascot) {
    switch (mascot) {
      case 'Komodo':
        return ['Logis', 'Analitis', 'Strategis', 'Sabar'];
      case 'Harimau':
        return ['Berani', 'Tegas', 'Kompetitif', 'Percaya Diri'];
      case 'Garuda':
        return ['Bijaksana', 'Visioner', 'Spiritual', 'Idealis'];
      case 'Merak':
        return ['Kreatif', 'Artistik', 'Ekspresif', 'Inovatif'];
      case 'Orangutan':
        return ['Empatik', 'Peduli', 'Pendengar Baik', 'Supportif'];
      case 'Gajah':
        return ['Sosial', 'Ramah', 'Komunikatif', 'Kolaboratif'];
      case 'Banteng':
        return ['Berprinsip', 'Konsisten', 'Jujur', 'Dapat Dipercaya'];
      default:
        return ['Unik', 'Menarik'];
    }
  }

  /// Save test result (to backend in future)
  Future<void> saveResult() async {
    if (_result == null) return;

    try {
      // TODO: Save to Supabase
      await Future.delayed(const Duration(milliseconds: 300));
      debugPrint('✅ Test result saved');
    } catch (e) {
      debugPrint('❌ PersonalityTestProvider.saveResult error: $e');
    }
  }

  /// Reset test for retake
  void resetTest() {
    _currentQuestionIndex = 0;
    _answers.clear();
    _scores = {
      'logic': 0,
      'courage': 0,
      'spirituality': 0,
      'creativity': 0,
      'empathy': 0,
      'social': 0,
      'principle': 0,
    };
    _result = null;
    notifyListeners();
    debugPrint('🔄 Test reset');
  }

  /// Clear all data
  void clear() {
    _questions = [];
    _currentQuestionIndex = 0;
    _answers.clear();
    _scores.clear();
    _result = null;
    _error = null;
    notifyListeners();
    debugPrint('🔄 PersonalityTestProvider cleared');
  }
}
