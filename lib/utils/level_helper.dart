import 'package:flutter/material.dart';

/// Helper untuk calculate level progression dengan XP yang meningkat
class LevelHelper {
  /// Get level dari total XP
  /// NEW EASIER PROGRESSION SYSTEM:
  /// Level 1: 0 XP
  /// Level 2: 100 XP (cumulative: 100)
  /// Level 3: 200 XP (cumulative: 300)
  /// Level 4: 300 XP (cumulative: 600)
  /// Level 5: 400 XP (cumulative: 1,000)
  /// Level 6: 500 XP (cumulative: 1,500)
  /// Level 7: 600 XP (cumulative: 2,100)
  /// Level 8: 700 XP (cumulative: 2,800)
  /// Level 9: 800 XP (cumulative: 3,600)
  /// Level 10: 900 XP (cumulative: 4,500)
  /// Level 11+: 1,000 XP each
  static int getLevelFromXP(int totalXP) {
    int level = 1;
    int cumulativeXP = 0;

    while (cumulativeXP <= totalXP) {
      final xpRequired = getXPRequiredForLevel(level);
      cumulativeXP += xpRequired;

      if (cumulativeXP <= totalXP) {
        level++;
      }
    }

    return level;
  }

  /// Get XP required untuk level up dari level saat ini
  static int getXPRequiredForLevel(int currentLevel) {
    if (currentLevel == 1) {
      return 100; // Level 1 → 2: only 100 XP (easy start!)
    } else if (currentLevel <= 10) {
      return currentLevel * 100; // Level 2-10: 200, 300, 400, ..., 1000
    } else {
      return 1000; // Level 11+: 1000 XP each
    }
  }

  /// Get cumulative XP untuk mencapai level tertentu
  static int getCumulativeXPForLevel(int targetLevel) {
    int cumulativeXP = 0;

    for (int level = 1; level < targetLevel; level++) {
      cumulativeXP += getXPRequiredForLevel(level);
    }

    return cumulativeXP;
  }

  /// Get XP progress menuju level berikutnya
  static Map<String, int> getXPProgress(int totalXP) {
    final currentLevel = getLevelFromXP(totalXP);
    final cumulativeXPForCurrentLevel = getCumulativeXPForLevel(currentLevel);
    final xpRequiredForNextLevel = getXPRequiredForLevel(currentLevel);
    final currentXPInLevel = totalXP - cumulativeXPForCurrentLevel;

    return {
      'currentLevel': currentLevel,
      'currentXP': currentXPInLevel,
      'requiredXP': xpRequiredForNextLevel,
      'remainingXP': xpRequiredForNextLevel - currentXPInLevel,
    };
  }

  /// Get collectible unlock levels
  static Map<int, int> getCollectibleUnlockLevels() {
    return {
      1: 2, // Collectible 1 unlock at level 2 (100 XP)
      2: 4, // Collectible 2 unlock at level 4 (600 XP)
      3: 6, // Collectible 3 unlock at level 6 (1,500 XP)
      4: 8, // Collectible 4 unlock at level 8 (3,600 XP)
      5: 10, // Collectible 5 unlock at level 10 (4,500 XP)
    };
  }

  /// Get XP required untuk unlock collectible
  static int getCollectibleUnlockXP(int orderNumber) {
    final levelMap = {
      1: 100, // Level 2
      2: 600, // Level 4
      3: 1500, // Level 6
      4: 3600, // Level 8
      5: 4500, // Level 10
    };

    return levelMap[orderNumber] ?? 0;
  }

  /// Get display text untuk level progress
  static String getLevelProgressText(int totalXP) {
    final progress = getXPProgress(totalXP);
    return '${progress['currentXP']}/${progress['requiredXP']} XP';
  }

  /// Get percentage progress menuju level berikutnya
  static double getLevelProgressPercentage(int totalXP) {
    final progress = getXPProgress(totalXP);
    final currentXP = progress['currentXP']!;
    final requiredXP = progress['requiredXP']!;

    if (requiredXP == 0) return 1.0;
    return (currentXP / requiredXP).clamp(0.0, 1.0);
  }

  /// Debug: Print level progression table
  static void printLevelTable() {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('📊 LEVEL PROGRESSION TABLE');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    for (int level = 1; level <= 15; level++) {
      final cumulativeXP = getCumulativeXPForLevel(level);
      final xpToNext = getXPRequiredForLevel(level);

      String collectibleInfo = '';
      if (level == 2) collectibleInfo = '🎁 Collectible #1';
      if (level == 4) collectibleInfo = '🎁 Collectible #2';
      if (level == 6) collectibleInfo = '🎁 Collectible #3';
      if (level == 8) collectibleInfo = '🎁 Collectible #4';
      if (level == 10) collectibleInfo = '🎁 Collectible #5';

      debugPrint(
        'Level $level: ${cumulativeXP.toString().padLeft(6)} XP total | +${xpToNext.toString().padLeft(5)} to next $collectibleInfo',
      );
    }

    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }
}
