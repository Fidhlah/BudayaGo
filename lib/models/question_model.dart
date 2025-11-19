class Question {
  final int id;
  final String question;
  final List<Answer> answers;

  Question({required this.id, required this.question, required this.answers});

  factory Question.fromJson(Map<String, dynamic> json) {
    // Handle both formats: "text" or "question"
    String questionText = json['question'] ?? json['text'] ?? '';

    List<Answer> answerList = [];

    // Handle "answers" array format
    if (json['answers'] != null) {
      answerList =
          (json['answers'] as List)
              .map((answer) => Answer.fromJson(answer))
              .toList();
    }
    // Handle "options" object format
    else if (json['options'] != null) {
      Map<String, dynamic> options = json['options'];
      answerList =
          options.entries.map((entry) {
            return Answer(
              text: entry.value['text'],
              type: entry.key, // A, B, C, D as type
            );
          }).toList();
    }

    return Question(
      id: json['id'],
      question: questionText,
      answers: answerList,
    );
  }
}

class Answer {
  final String text;
  final String type;

  Answer({required this.text, required this.type});

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(text: json['text'], type: json['type']);
  }
}

class QuestionData {
  final List<Question> questions;

  QuestionData({required this.questions});

  factory QuestionData.fromJson(Map<String, dynamic> json) {
    return QuestionData(
      questions:
          (json['questions'] as List)
              .map((question) => Question.fromJson(question))
              .toList(),
    );
  }
}
