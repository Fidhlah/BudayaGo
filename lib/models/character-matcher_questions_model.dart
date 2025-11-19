/// Model untuk pertanyaan test
class TestQuestion {
  final int id;
  final String text;
  final Map<String, TestOption> options;

  TestQuestion({
    required this.id,
    required this.text,
    required this.options,
  });

  factory TestQuestion.fromJson(Map<String, dynamic> json) {
    Map<String, TestOption> optionsMap = {};
    
    (json['options'] as Map<String, dynamic>).forEach((key, value) {
      optionsMap[key] = TestOption.fromJson(value);
    });

    return TestQuestion(
      id: json['id'],
      text: json['text'],
      options: optionsMap,
    );
  }
}

/// Model untuk opsi jawaban
class TestOption {
  final String text;
  final Map<String, int> weights;

  TestOption({
    required this.text,
    required this.weights,
  });

  factory TestOption.fromJson(Map<String, dynamic> json) {
    return TestOption(
      text: json['text'],
      weights: Map<String, int>.from(json['weights']),
    );
  }
}

/// Model untuk hasil test
class TestResult {
  final String userId;
  final DateTime timestamp;
  final Map<String, DimensionScore> dimensions;

  TestResult({
    required this.userId,
    required this.timestamp,
    required this.dimensions,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
      'dimensions': dimensions.map((key, value) => MapEntry(key, value.toJson())),
    };
  }
}

/// Model untuk skor dimensi
class DimensionScore {
  final int score;
  final int maxScore;
  final double percentage;

  DimensionScore({
    required this.score,
    required this.maxScore,
  }) : percentage = (score / maxScore) * 100;

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'maxScore': maxScore,
      'percentage': percentage,
    };
  }
}