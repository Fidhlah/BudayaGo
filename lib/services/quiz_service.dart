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
          .order('question_number');

      debugPrint('✅ Loaded ${questionsData.length} questions from database');

      // Convert to TestQuestion model
      List<TestQuestion> questions = [];

      for (var qData in questionsData) {
        Map<String, TestOption> options = {};

        // Parse answers
        final answers = qData['quiz_answers'] as List;
        for (var answer in answers) {
          final optionKey = answer['option_key'] as String;

          // Build weights map
          Map<String, int> weights = {
            'spirituality': answer['weight_spirituality'] ?? 0,
            'courage': answer['weight_courage'] ?? 0,
            'empathy': answer['weight_empathy'] ?? 0,
            'logic': answer['weight_logic'] ?? 0,
            'creativity': answer['weight_creativity'] ?? 0,
            'social': answer['weight_social'] ?? 0,
            'principle': answer['weight_principle'] ?? 0,
          };

          options[optionKey] = TestOption(
            text: answer['option_text'],
            weights: weights,
          );
        }

        questions.add(
          TestQuestion(
            id: qData['question_number'],
            text: qData['question_text'],
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

  /// Submit test results ke Supabase dan trigger character matching
  static Future<Map<String, dynamic>> submitTestResults({
    required String userId,
    required Map<String, int> scores,
    required Map<int, String> answers,
  }) async {
    try {
      debugPrint('📤 Submitting test results to Supabase...');
      debugPrint('   User ID: $userId');
      debugPrint('   Scores: $scores');

      // Step 1: Insert test results
      final resultData =
          await SupabaseConfig.client
              .from('personality_test_results')
              .insert({
                'user_id': userId,
                'raw_spirituality': scores['spirituality'] ?? 0,
                'raw_courage': scores['courage'] ?? 0,
                'raw_empathy': scores['empathy'] ?? 0,
                'raw_logic': scores['logic'] ?? 0,
                'raw_creativity': scores['creativity'] ?? 0,
                'raw_social': scores['social'] ?? 0,
                'raw_principle': scores['principle'] ?? 0,
                'answers': jsonEncode(answers),
              })
              .select()
              .single();

      debugPrint('✅ Test results inserted with ID: ${resultData['id']}');

      // Step 2: Process test (normalization + character matching)
      debugPrint('🎯 Processing personality test...');
      await SupabaseConfig.client.rpc(
        'process_personality_test',
        params: {'p_user_id': userId},
      );

      debugPrint('✅ Personality test processed');

      // Step 3: Get assigned character
      final userData =
          await SupabaseConfig.client
              .from('users')
              .select('''
          character_id,
          quiz_completed,
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

      final characterData = userData['characters'];

      debugPrint('✅ Character assigned: ${characterData['name']}');

      return {
        'success': true,
        'character': {
          'id': characterData['id'],
          'name': characterData['name'],
          'description': characterData['description'],
          'lore': characterData['lore'],
          'archetype': characterData['archetype'],
          'imageUrl': characterData['image_url'],
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
