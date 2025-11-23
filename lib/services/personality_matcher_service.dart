import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../config/supabase_config.dart';

/// Background service untuk assign character berdasarkan personality test
/// Menggantikan Python backend dengan pure Dart implementation
class PersonalityMatcherService {
  static Timer? _pollingTimer;
  static final Set<String> _processedTestIds = {};
  static bool _isRunning = false;

  // Dimension names
  static const List<String> dimensions = [
    'spirituality',
    'courage',
    'empathy',
    'logic',
    'creativity',
    'social',
    'principle',
  ];

  /// Start background polling service
  static void startPolling({Duration interval = const Duration(seconds: 3)}) {
    if (_isRunning) {
      debugPrint('⚠️  PersonalityMatcher already running');
      return;
    }

    _isRunning = true;
    debugPrint('🤖 PersonalityMatcher service started');
    debugPrint('⏰ Polling interval: ${interval.inSeconds}s');

    // Initial check
    _pollForNewTests();

    // Start periodic polling
    _pollingTimer = Timer.periodic(interval, (_) {
      _pollForNewTests();
    });
  }

  /// Stop polling service
  static void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _isRunning = false;
    debugPrint('🛑 PersonalityMatcher service stopped');
  }

  /// Poll database for tests that need character assignment
  static Future<void> _pollForNewTests() async {
    try {
      // Query for tests without assigned character
      final response = await SupabaseConfig.client
          .from('personality_test_results')
          .select('*')
          .isFilter('assigned_character_id', null)
          .order('completed_at', ascending: true);

      final pendingTests = response as List<dynamic>;

      // Filter out already processed
      final newTests =
          pendingTests
              .where(
                (test) => !_processedTestIds.contains(test['id'] as String),
              )
              .toList();

      if (newTests.isEmpty) {
        // Quiet mode when no tests
        return;
      }

      debugPrint(
        '📥 Found ${newTests.length} new personality test(s) to process',
      );

      for (var test in newTests) {
        try {
          await _processPersonalityTest(test);
          _processedTestIds.add(test['id'] as String);
        } catch (e, stack) {
          debugPrint('❌ Error processing test ${test['id']}: $e');
          debugPrint('Stack trace: $stack');
        }
      }
    } catch (e, stack) {
      debugPrint('❌ Error polling database: $e');
      debugPrint('Stack trace: $stack');
    }
  }

  /// Calculate max possible scores for each dimension from quiz_answers
  static Future<Map<String, int>> _calculateMaxScores() async {
    debugPrint('📊 Calculating max scores from quiz_answers...');

    final response = await SupabaseConfig.client
        .from('quiz_answers')
        .select('*');

    final answers = response as List<dynamic>;

    final maxScores = <String, int>{for (var dim in dimensions) dim: 0};

    // Sum all positive weights for each dimension
    for (var answer in answers) {
      for (var dim in dimensions) {
        final weightKey = 'weight_$dim';
        final weight = (answer[weightKey] as int?) ?? 0;
        if (weight > 0) {
          maxScores[dim] = maxScores[dim]! + weight;
        }
      }
    }

    debugPrint('✅ Max scores: $maxScores');
    return maxScores;
  }

  /// Normalize raw scores to percentages (0-100)
  static Map<String, double> _normalizeScores(
    Map<String, int> rawScores,
    Map<String, int> maxScores,
  ) {
    final percentages = <String, double>{};

    for (var dim in dimensions) {
      final raw = rawScores[dim] ?? 0;
      final maxVal = maxScores[dim] ?? 1; // Prevent division by zero

      if (maxVal > 0) {
        percentages[dim] = (raw / maxVal) * 100.0;
      } else {
        percentages[dim] = 0.0;
      }
    }

    return percentages;
  }

  /// Calculate Euclidean distance between user and character personalities
  static double _calculateEuclideanDistance(
    Map<String, double> userPercentages,
    Map<String, dynamic> character,
  ) {
    double sumSquaredDiff = 0.0;

    for (var dim in dimensions) {
      final userVal = userPercentages[dim] ?? 0.0;
      final charVal = (character[dim] as num?)?.toDouble() ?? 0.0;
      sumSquaredDiff += pow(userVal - charVal, 2);
    }

    return sqrt(sumSquaredDiff);
  }

  /// Get all characters from database
  static Future<List<Map<String, dynamic>>> _getAllCharacters() async {
    debugPrint('🎭 Loading characters from Supabase...');

    final response = await SupabaseConfig.client.from('characters').select('*');

    final characters =
        (response as List<dynamic>).cast<Map<String, dynamic>>().toList();

    debugPrint('✅ Loaded ${characters.length} characters');
    return characters;
  }

  /// Find character with minimum Euclidean distance (closest match)
  static Map<String, dynamic> _findBestCharacterMatch(
    Map<String, double> userPercentages,
    List<Map<String, dynamic>> characters,
  ) {
    Map<String, dynamic>? bestMatch;
    double minDistance = double.infinity;

    debugPrint('\n📏 Calculating distances to all characters:');

    for (var char in characters) {
      final distance = _calculateEuclideanDistance(userPercentages, char);

      final name = char['name'] as String;
      debugPrint(
        '   ${name.padRight(20)} Distance: ${distance.toStringAsFixed(4)}',
      );

      if (distance < minDistance) {
        minDistance = distance;
        bestMatch = char;
      }
    }

    debugPrint(
      '\n🎯 Best match: ${bestMatch!['name']} (distance: ${minDistance.toStringAsFixed(4)})',
    );

    return {'character': bestMatch, 'distance': minDistance};
  }

  /// Process a single personality test
  static Future<void> _processPersonalityTest(
    Map<String, dynamic> testResult,
  ) async {
    final userId = testResult['user_id'] as String;
    final resultId = testResult['id'] as String;

    debugPrint('\n${'=' * 80}');
    debugPrint('🎯 Processing personality test for user: $userId');
    debugPrint('=' * 80);

    // Step 1: Extract raw scores
    final rawScores = <String, int>{
      'spirituality': testResult['raw_spirituality'] as int? ?? 0,
      'courage': testResult['raw_courage'] as int? ?? 0,
      'empathy': testResult['raw_empathy'] as int? ?? 0,
      'logic': testResult['raw_logic'] as int? ?? 0,
      'creativity': testResult['raw_creativity'] as int? ?? 0,
      'social': testResult['raw_social'] as int? ?? 0,
      'principle': testResult['raw_principle'] as int? ?? 0,
    };

    debugPrint('\n📊 Raw scores: $rawScores');

    // Step 2: Calculate max scores
    final maxScores = await _calculateMaxScores();

    // Step 3: Normalize to percentages
    final percentages = _normalizeScores(rawScores, maxScores);

    debugPrint('\n📈 Normalized percentages:');
    for (var entry in percentages.entries) {
      final dim = entry.key;
      final pct = entry.value;
      debugPrint(
        '   ${dim.padRight(15).capitalize()}: ${pct.toStringAsFixed(2).padLeft(6)}%',
      );
    }

    // Step 4: Get all characters
    final characters = await _getAllCharacters();

    // Step 5: Find best match
    final matchResult = _findBestCharacterMatch(percentages, characters);
    final bestCharacter = matchResult['character'] as Map<String, dynamic>;
    final distance = matchResult['distance'] as double;

    // Step 6: Update database
    debugPrint('\n💾 Updating database...');

    // Update personality_test_results
    await SupabaseConfig.client
        .from('personality_test_results')
        .update({
          'norm_spirituality': percentages['spirituality'],
          'norm_courage': percentages['courage'],
          'norm_empathy': percentages['empathy'],
          'norm_logic': percentages['logic'],
          'norm_creativity': percentages['creativity'],
          'norm_social': percentages['social'],
          'norm_principle': percentages['principle'],
          'assigned_character_id': bestCharacter['id'],
          'euclidean_distance': distance,
        })
        .eq('id', resultId);

    // Update users table
    await SupabaseConfig.client
        .from('users')
        .update({'character_id': bestCharacter['id']})
        .eq('id', userId);

    debugPrint('✅ Character assigned: ${bestCharacter['name']}');
    debugPrint('✅ Updated user and test results in database');
    debugPrint('${'=' * 80}\n');
  }
}

/// Extension untuk capitalize string
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
