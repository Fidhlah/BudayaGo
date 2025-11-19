import 'package:flutter/foundation.dart';

class UserProfile {
  final String id;
  final String email;
  final String? displayName;
  final String? mascot;
  final int xp;
  final int level;
  final DateTime createdAt;
  final DateTime? lastActive;

  UserProfile({
    required this.id,
    required this.email,
    this.displayName,
    this.mascot,
    required this.xp,
    required this.level,
    required this.createdAt,
    this.lastActive,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'mascot': mascot,
      'xp': xp,
      'level': level,
      'created_at': createdAt.toIso8601String(),
      'last_active': lastActive?.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String?,
      mascot: json['mascot'] as String?,
      xp: json['xp'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastActive:
          json['last_active'] != null
              ? DateTime.parse(json['last_active'] as String)
              : null,
    );
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? displayName,
    String? mascot,
    int? xp,
    int? level,
    DateTime? createdAt,
    DateTime? lastActive,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      mascot: mascot ?? this.mascot,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }
}

class Collectible {
  final String id;
  final String name;
  final String category;
  final String? imageUrl;
  final DateTime collectedAt;
  final int xpEarned;

  Collectible({
    required this.id,
    required this.name,
    required this.category,
    this.imageUrl,
    required this.collectedAt,
    required this.xpEarned,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'image_url': imageUrl,
      'collected_at': collectedAt.toIso8601String(),
      'xp_earned': xpEarned,
    };
  }

  factory Collectible.fromJson(Map<String, dynamic> json) {
    return Collectible(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      imageUrl: json['image_url'] as String?,
      collectedAt: DateTime.parse(json['collected_at'] as String),
      xpEarned: json['xp_earned'] as int? ?? 0,
    );
  }
}

class ProfileProvider extends ChangeNotifier {
  UserProfile? _profile;
  List<Collectible> _collectibles = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  UserProfile? get profile => _profile;
  List<Collectible> get collectibles => List.unmodifiable(_collectibles);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasProfile => _profile != null;

  // Stats
  int get totalCollectibles => _collectibles.length;
  int get totalXPEarned =>
      _collectibles.fold(0, (sum, item) => sum + item.xpEarned);

  /// Load user profile from backend
  Future<void> loadProfile(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Fetch from Supabase
      // For now, create mock profile
      await Future.delayed(const Duration(milliseconds: 500));

      _profile = UserProfile(
        id: userId,
        email: 'user@example.com',
        displayName: 'Penjelajah Budaya',
        mascot: 'default',
        xp: 0,
        level: 1,
        createdAt: DateTime.now(),
        lastActive: DateTime.now(),
      );

      debugPrint('✅ Profile loaded: ${_profile?.email}');
    } catch (e) {
      _error = 'Failed to load profile: $e';
      debugPrint('❌ ProfileProvider.loadProfile error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update user profile
  Future<void> updateProfile({String? displayName, String? mascot}) async {
    if (_profile == null) {
      _error = 'No profile to update';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Update in Supabase
      await Future.delayed(const Duration(milliseconds: 300));

      _profile = _profile!.copyWith(
        displayName: displayName ?? _profile!.displayName,
        mascot: mascot ?? _profile!.mascot,
        lastActive: DateTime.now(),
      );

      debugPrint('✅ Profile updated');
    } catch (e) {
      _error = 'Failed to update profile: $e';
      debugPrint('❌ ProfileProvider.updateProfile error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update XP and level
  void updateProgress(int xp, int level) {
    if (_profile == null) return;

    _profile = _profile!.copyWith(
      xp: xp,
      level: level,
      lastActive: DateTime.now(),
    );
    notifyListeners();

    // TODO: Sync to Supabase in background
  }

  /// Load user's collectibles
  Future<void> loadCollectibles() async {
    if (_profile == null) {
      _error = 'No profile loaded';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Fetch from Supabase
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock data for now
      _collectibles = [];

      debugPrint('✅ Loaded ${_collectibles.length} collectibles');
    } catch (e) {
      _error = 'Failed to load collectibles: $e';
      debugPrint('❌ ProfileProvider.loadCollectibles error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new collectible
  Future<void> addCollectible(Collectible collectible) async {
    try {
      // TODO: Save to Supabase
      _collectibles.add(collectible);
      notifyListeners();

      debugPrint('✅ Added collectible: ${collectible.name}');
    } catch (e) {
      _error = 'Failed to add collectible: $e';
      debugPrint('❌ ProfileProvider.addCollectible error: $e');
      notifyListeners();
    }
  }

  /// Clear all data (for logout)
  void clear() {
    _profile = null;
    _collectibles = [];
    _error = null;
    notifyListeners();
    debugPrint('🔄 ProfileProvider cleared');
  }
}
