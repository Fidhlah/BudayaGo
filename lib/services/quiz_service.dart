import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../config/supabase_config.dart';
import '../models/character-matcher_questions_model.dart';

/// Service untuk handle quiz/personality test integration dengan Supabase
class QuizService {
  /// Load questions dari Supabase database
  static Future<List<TestQuestion>> loadQuestionsFromDatabase() async {
    try {
      debugPrint('📚 Loading quiz questions from Supabase...');

      final questionsData = await SupabaseConfig.client
          .from('quiz_questions')
          .select('''
          id,
          question_number,
          question_text,
          quiz_answers (
            id,
            option_key,
            option_text,
            weight_spirituality,
            weight_courage,
            weight_empathy,
            weight_logic,
            weight_creativity,
            weight_social,
            weight_principle
          )
        ''')
          .order('question_number', ascending: true);

      debugPrint('✅ Loaded ${questionsData.length} questions from database');
      debugPrint('📋 Raw data type: ${questionsData.runtimeType}');

      // Convert to TestQuestion model
      List<TestQuestion> questions = [];

      for (var qData in questionsData) {
        Map<String, TestOption> options = {};

        // Parse answers - handle both List and dynamic type
        final answersRaw = qData['quiz_answers'];
        final answers = answersRaw is List ? answersRaw : [];

        for (var answerRaw in answers) {
          // Convert to Map if needed
          final answer =
              answerRaw is Map<String, dynamic>
                  ? answerRaw
                  : Map<String, dynamic>.from(answerRaw as Map);

          final optionKey = answer['option_key'] as String;

          // Build weights map - safely cast to int
          Map<String, int> weights = {
            'spirituality':
                (answer['weight_spirituality'] as num?)?.toInt() ?? 0,
            'courage': (answer['weight_courage'] as num?)?.toInt() ?? 0,
            'empathy': (answer['weight_empathy'] as num?)?.toInt() ?? 0,
            'logic': (answer['weight_logic'] as num?)?.toInt() ?? 0,
            'creativity': (answer['weight_creativity'] as num?)?.toInt() ?? 0,
            'social': (answer['weight_social'] as num?)?.toInt() ?? 0,
            'principle': (answer['weight_principle'] as num?)?.toInt() ?? 0,
          };

          options[optionKey] = TestOption(
            text: answer['option_text'] as String,
            weights: weights,
          );
        }

        questions.add(
          TestQuestion(
            id: (qData['question_number'] as num).toInt(),
            text: qData['question_text'] as String,
            options: options,
          ),
        );
      }

      return questions;
    } catch (e) {
      debugPrint('❌ Error loading questions from database: $e');
      rethrow;
    }
  }

  /// Submit test results ke Supabase - ONLY save raw scores
  /// Character matching will be done by Flutter background service (PersonalityMatcherService)
  static Future<Map<String, dynamic>> submitTestResults({
    required String userId,
    required Map<String, int> scores,
    required Map<int, String> answers,
  }) async {
    try {
      debugPrint('📤 Submitting test results to Supabase...');
      debugPrint('   User ID: $userId');
      debugPrint('   Scores: $scores');

      // Convert answers Map<int, String> to JSON-compatible format
      final answersJson = answers.map(
        (key, value) => MapEntry(key.toString(), value),
      );

      // Save raw scores ONLY - background service will process
      final resultData =
          await SupabaseConfig.client
              .from('personality_test_results')
              .upsert({
                'user_id': userId,
                'raw_spirituality': scores['spirituality'] ?? 0,
                'raw_courage': scores['courage'] ?? 0,
                'raw_empathy': scores['empathy'] ?? 0,
                'raw_logic': scores['logic'] ?? 0,
                'raw_creativity': scores['creativity'] ?? 0,
                'raw_social': scores['social'] ?? 0,
                'raw_principle': scores['principle'] ?? 0,
                'answers': jsonEncode(answersJson),
                'completed_at': DateTime.now().toIso8601String(),
              }, onConflict: 'user_id')
              .select()
              .single();

      debugPrint('✅ Test results saved with ID: ${resultData['id']}');
      debugPrint('⏳ Background service will process character matching...');

      // Wait for background service to assign character (polling with timeout)
      final maxAttempts = 30; // 30 seconds max
      int attempts = 0;
      String? characterId;

      while (attempts < maxAttempts) {
        await Future.delayed(const Duration(seconds: 1));
        attempts++;

        // Check if character has been assigned by background service
        final testResult =
            await SupabaseConfig.client
                .from('personality_test_results')
                .select('assigned_character_id')
                .eq('user_id', userId)
                .single();

        characterId = testResult['assigned_character_id'];
        
        if (characterId != null) {
          debugPrint('✅ Character assigned by background service after ${attempts}s');
          break;
        }
        
        if (attempts % 5 == 0) {
          debugPrint('⏳ Still waiting... (${attempts}/${maxAttempts}s)');
        }
      }

      if (characterId == null) {
        throw Exception(
          'Character matching timeout. Background service did not assign character within 30 seconds. '
          'Please check if PersonalityMatcherService is running.',
        );
      }

      // Get assigned character details
      final characterData =
          await SupabaseConfig.client
              .from('characters')
              .select('''
            id,
            name,
            description,
            lore,
            archetype,
            image_url,
            personality_traits
          ''')
              .eq('id', characterId)
              .single();

      debugPrint('✅ Character assigned: ${characterData['name']}');

      return {
        'success': true,
        'character': {
          'id': characterData['id'],
          'name': characterData['name'],
          'description': characterData['description'],
          'lore': characterData['lore'],
          'archetype': characterData['archetype'],
          'image_url': characterData['image_url'],
          'personality_traits': characterData['personality_traits'] ?? [],
        },
        'testResultId': resultData['id'],
      };
    } catch (e) {
      debugPrint('❌ Error submitting test results: $e');
      rethrow;
    }
  }

  /// Get user's assigned character
  static Future<Map<String, dynamic>?> getUserCharacter(String userId) async {
    try {
      final userData =
          await SupabaseConfig.client
              .from('users')
              .select('''
          character_id,
          characters (
            id,
            name,
            description,
            lore,
            archetype,
            image_url
          )
        ''')
              .eq('id', userId)
              .single();

      if (userData['character_id'] == null) {
        return null;
      }

      final characterData = userData['characters'];

      return {
        'id': characterData['id'],
        'name': characterData['name'],
        'description': characterData['description'],
        'lore': characterData['lore'],
        'archetype': characterData['archetype'],
        'imageUrl': characterData['image_url'],
      };
    } catch (e) {
      debugPrint('❌ Error getting user character: $e');
      return null;
    }
  }

  /// Check if user has completed quiz
  static Future<bool> hasCompletedQuiz(String userId) async {
    try {
      final userData =
          await SupabaseConfig.client
              .from('users')
              .select('quiz_completed')
              .eq('id', userId)
              .single();

      return userData['quiz_completed'] == true;
    } catch (e) {
      debugPrint('❌ Error checking quiz status: $e');
      return false;
    }
  }
}
