import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../mascot_result/mascot_result_screen.dart';
import '../../models/question_model.dart';

class PersonalityTestScreen extends StatefulWidget {
  const PersonalityTestScreen({Key? key}) : super(key: key);

  @override
  State<PersonalityTestScreen> createState() => _PersonalityTestScreenState();
}

class _PersonalityTestScreenState extends State<PersonalityTestScreen> {
  int currentQuestion = 0;
  Map<String, int> scores = {
    'Wayang': 0,
    'Batik': 0,
    'Keris': 0,
    'Angklung': 0,
  };

  List<Question> questions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    print('Starting to load questions from JSON...');
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/personality_questions.json',
      );
      print('JSON string loaded successfully');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      print('JSON decoded successfully');
      final QuestionData questionData = QuestionData.fromJson(jsonData);

      setState(() {
        questions = questionData.questions;
        isLoading = false;
      });
      print('Successfully loaded ${questions.length} questions from JSON');
    } catch (e) {
      print('Error loading questions: $e');
      print('Using fallback questions instead');
      setState(() {
        isLoading = false;
      });
    }
  }

  final List<Map<String, dynamic>> _fallbackQuestions = [
    {
      'question': 'Bagaimana cara kamu belajar hal baru?',
      'answers': [
        {'text': 'Melalui cerita dan narasi', 'type': 'Wayang'},
        {'text': 'Dengan praktik langsung', 'type': 'Batik'},
        {'text': 'Meneliti secara mendalam', 'type': 'Keris'},
        {'text': 'Belajar bersama teman', 'type': 'Angklung'},
      ],
    },
    {
      'question': 'Aktivitas yang paling kamu sukai?',
      'answers': [
        {'text': 'Menonton film atau teater', 'type': 'Wayang'},
        {'text': 'Menggambar atau crafting', 'type': 'Batik'},
        {'text': 'Membaca dan menulis', 'type': 'Keris'},
        {'text': 'Bermain musik atau bernyanyi', 'type': 'Angklung'},
      ],
    },
    {
      'question': 'Bagaimana kamu menghadapi masalah?',
      'answers': [
        {'text': 'Mencari makna dibaliknya', 'type': 'Wayang'},
        {'text': 'Mencari solusi kreatif', 'type': 'Batik'},
        {'text': 'Menganalisis secara detail', 'type': 'Keris'},
        {'text': 'Meminta bantuan orang lain', 'type': 'Angklung'},
      ],
    },
    {
      'question': 'Tempat favoritmu saat santai?',
      'answers': [
        {'text': 'Galeri seni atau museum', 'type': 'Wayang'},
        {'text': 'Workshop atau studio', 'type': 'Batik'},
        {'text': 'Perpustakaan atau kafe tenang', 'type': 'Keris'},
        {'text': 'Konser atau acara komunitas', 'type': 'Angklung'},
      ],
    },
    {
      'question': 'Apa yang membuatmu bangga?',
      'answers': [
        {'text': 'Menceritakan kisah inspiratif', 'type': 'Wayang'},
        {'text': 'Membuat sesuatu dengan tangan', 'type': 'Batik'},
        {'text': 'Menguasai pengetahuan baru', 'type': 'Keris'},
        {'text': 'Berkolaborasi dalam tim', 'type': 'Angklung'},
      ],
    },
  ];

  // Mapping untuk konversi jawaban A,B,C,D ke tipe maskot
  String _mapAnswerToMascot(String answerType, int questionIndex) {
    // Untuk sementara, gunakan mapping sederhana
    // A -> Wayang, B -> Batik, C -> Keris, D -> Angklung
    switch (answerType) {
      case 'A':
        return 'Wayang';
      case 'B':
        return 'Batik';
      case 'C':
        return 'Keris';
      case 'D':
        return 'Angklung';
      default:
        return answerType; // fallback untuk format lama
    }
  }

  void selectAnswer(String type) {
    setState(() {
      // Convert A,B,C,D to mascot types
      String mascotType = _mapAnswerToMascot(type, currentQuestion);
      scores[mascotType] = (scores[mascotType] ?? 0) + 1;

      if (currentQuestion <
          (questions.isNotEmpty
              ? questions.length - 1
              : _fallbackQuestions.length - 1)) {
        currentQuestion++;
      } else {
        String mascot =
            scores.entries.reduce((a, b) => a.value > b.value ? a : b).key;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MascotResultScreen(mascot: mascot),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
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

    // Debug: print apakah questions loaded
    print('Questions loaded: ${questions.length}, Current: $currentQuestion');

    final questionText =
        questions.isNotEmpty
            ? questions[currentQuestion].question
            : _fallbackQuestions[currentQuestion]['question'];

    // Debug: print pertanyaan yang ditampilkan
    print('Displaying question: $questionText');
    final answers =
        questions.isNotEmpty
            ? questions[currentQuestion].answers
            : (_fallbackQuestions[currentQuestion]['answers'] as List)
                .map((a) => Answer(text: a['text'], type: a['type']))
                .toList();

    final totalQuestions =
        questions.isNotEmpty ? questions.length : _fallbackQuestions.length;
    final progress = (currentQuestion + 1) / totalQuestions;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Tes Kepribadian',
          style: TextStyle(color: Colors.black87),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                'Pertanyaan ${currentQuestion + 1}/$totalQuestions',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 32),
              Text(
                questionText,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.builder(
                  itemCount: answers.length,
                  itemBuilder: (context, index) {
                    final answer = answers[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          onTap: () => selectAnswer(answer.type),
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
                                      String.fromCharCode(65 + index),
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
                                    answer.text,
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
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
