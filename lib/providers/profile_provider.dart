import 'package:flutter/foundation.dart';
import '../config/supabase_config.dart';
import '../services/collectibles_service.dart';
import '../services/visit_service.dart';

class UserProfile {
  final String id;
  final String email;
  final String? displayName;
  final String? mascot;
  final int xp;
  final int level;
  final DateTime createdAt;
  final DateTime? lastActive;
  final bool isPelakuBudaya;
  final bool hideProgress;
  final List<String> uploadedKaryaIds;

  UserProfile({
    required this.id,
    required this.email,
    this.displayName,
    this.mascot,
    required this.xp,
    required this.level,
    required this.createdAt,
    this.lastActive,
    this.isPelakuBudaya = false,
    this.hideProgress = false,
    this.uploadedKaryaIds = const [],
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
      'is_pelaku_budaya': isPelakuBudaya,
      'hide_progress': hideProgress,
      'uploaded_karya_ids': uploadedKaryaIds,
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
      isPelakuBudaya: json['is_pelaku_budaya'] as bool? ?? false,
      hideProgress: json['hide_progress'] as bool? ?? false,
      uploadedKaryaIds:
          (json['uploaded_karya_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
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
    bool? isPelakuBudaya,
    bool? hideProgress,
    List<String>? uploadedKaryaIds,
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
      isPelakuBudaya: isPelakuBudaya ?? this.isPelakuBudaya,
      hideProgress: hideProgress ?? this.hideProgress,
      uploadedKaryaIds: uploadedKaryaIds ?? this.uploadedKaryaIds,
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

class Character {
  final String id;
  final String name;
  final String? description;
  final String? lore;
  final String? imageUrl;
  final List<String> personalityTraits;
  final String? archetype;

  Character({
    required this.id,
    required this.name,
    this.description,
    this.lore,
    this.imageUrl,
    this.personalityTraits = const [],
    this.archetype,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      lore: json['lore'] as String?,
      imageUrl: json['image_url'] as String?,
      personalityTraits:
          (json['personality_traits'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      archetype: json['archetype'] as String?,
    );
  }
}

class ProfileProvider extends ChangeNotifier {
  UserProfile? _profile;
  Character? _character;
  List<Collectible> _collectibles = [];
  List<Map<String, dynamic>> _visitedLocations = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  UserProfile? get profile => _profile;
  Character? get character => _character;
  List<Collectible> get collectibles => List.unmodifiable(_collectibles);
  List<Map<String, dynamic>> get visitedLocations =>
      List.unmodifiable(_visitedLocations);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasProfile => _profile != null;
  bool get hasCharacter => _character != null;

  // Stats
  int get totalCollectibles => _collectibles.length;
  int get totalXPEarned =>
      _collectibles.fold(0, (sum, item) => sum + item.xpEarned);

  /// Get character profile image URL from Supabase storage
  /// Returns URL for "profile-{character-name}.png" format
  String? get characterProfileImageUrl {
    if (_character == null) return null;

    // Convert character name to lowercase and replace spaces with hyphens
    // Example: "Timun Mas" -> "timun-mas"
    final characterSlug = _character!.name.toLowerCase().replaceAll(' ', '-');

    // Construct Supabase storage URL
    // Format: profile-{character-slug}.png
    final fileName = 'profile-$characterSlug.png';

    try {
      final url = SupabaseConfig.client.storage
          .from(
            'Characters',
          ) // Bucket name is just 'Characters', not 'Buckets/Characters'
          .getPublicUrl(fileName);

      debugPrint('📸 Character profile image URL: $url');
      return url;
    } catch (e) {
      debugPrint('❌ Error getting character profile image: $e');
      return null;
    }
  }

  /// Load user profile from Supabase
  Future<void> loadProfile(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Fetch from Supabase
      final userData =
          await SupabaseConfig.client
              .from('users')
              .select('''
          id,
          email,
          username,
          display_name,
          total_exp,
          level,
          created_at,
          updated_at,
          is_pelaku_budaya,
          hide_progress,
          uploaded_karya_ids,
          character_id
        ''')
              .eq('id', userId)
              .single();

      _profile = UserProfile(
        id: userData['id'],
        email: userData['email'] ?? '',
        displayName: userData['display_name'] ?? userData['username'],
        mascot: 'default', // TODO: Get from character assignment
        xp: userData['total_exp'] ?? 0,
        level: userData['level'] ?? 1,
        createdAt: DateTime.parse(userData['created_at']),
        lastActive:
            userData['updated_at'] != null
                ? DateTime.parse(userData['updated_at'])
                : null,
        isPelakuBudaya: userData['is_pelaku_budaya'] ?? false,
        hideProgress: userData['hide_progress'] ?? false,
        uploadedKaryaIds:
            (userData['uploaded_karya_ids'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      );

      // Load character data if character_id exists
      final characterId = userData['character_id'];
      if (characterId != null) {
        await _loadCharacter(characterId);
      } else {
        _character = null;
        debugPrint('⚠️ User has no character assigned yet');
      }

      debugPrint('✅ Profile loaded: ${_profile?.email}');
    } catch (e) {
      _error = 'Failed to load profile: $e';
      debugPrint('❌ ProfileProvider.loadProfile error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load character data from database
  Future<void> _loadCharacter(String characterId) async {
    try {
      debugPrint('🎭 Loading character data: $characterId');

      final characterData =
          await SupabaseConfig.client
              .from('characters')
              .select('*')
              .eq('id', characterId)
              .single();

      _character = Character.fromJson(characterData);

      debugPrint('✅ Character loaded: ${_character?.name}');
    } catch (e) {
      debugPrint('❌ Error loading character: $e');
      _character = null;
    }
  }

  /// Update user profile in database
  Future<void> updateProfile({
    String? displayName,
    String? mascot,
    bool? isPelakuBudaya,
    bool? hideProgress,
  }) async {
    if (_profile == null) {
      _error = 'No profile to update';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = _profile!.id;

      // Build update map
      Map<String, dynamic> updates = {};
      if (displayName != null) updates['display_name'] = displayName;
      if (isPelakuBudaya != null) updates['is_pelaku_budaya'] = isPelakuBudaya;
      if (hideProgress != null) updates['hide_progress'] = hideProgress;

      if (updates.isNotEmpty) {
        await SupabaseConfig.client
            .from('users')
            .update(updates)
            .eq('id', userId);
      }

      // Reload profile dari database untuk memastikan data terbaru
      await loadProfile(userId);

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

  /// Load user's collectibles from database
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
      final userId = _profile!.id;

      // Fetch ALL collectibles (both locked and unlocked) from Supabase
      final collectiblesData = await CollectiblesService.loadUserCollectibles(
        userId,
      );

      // Convert to Collectible model - include ALL items
      _collectibles =
          collectiblesData.map((item) {
            return Collectible(
              id: item['id'],
              name: item['name'],
              category: 'Artifact', // Default category
              imageUrl: item['imageUrl'],
              collectedAt:
                  item['unlockedAt'] != null
                      ? DateTime.parse(item['unlockedAt'])
                      : DateTime.now(),
              xpEarned: item['xpEarned'],
            );
          }).toList();

      debugPrint('✅ Loaded ${_collectibles.length} collectibles (all items)');
    } catch (e) {
      _error = 'Failed to load collectibles: $e';
      debugPrint('❌ ProfileProvider.loadCollectibles error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get collectibles data as Map for backward compatibility
  List<Map<String, dynamic>> get collectiblesAsMap {
    return _collectibles.map((c) => c.toJson()).toList();
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

  /// Load visited locations from database
  Future<void> loadVisitedLocations(String userId) async {
    try {
      final visits = await VisitService.getUserVisits(userId);

      _visitedLocations =
          visits.map((visit) {
            final partner = visit['cultural_partners'] as Map<String, dynamic>?;

            final locationData = {
              'id': visit['id'],
              'partner_id': visit['partner_id'],
              'user_id': visit['user_id'],
              'visited_at': visit['visited_at'],
              'visitedAt': DateTime.parse(
                visit['visited_at'] as String,
              ), // Parse for UI
              'exp_gained': visit['exp_gained'],
              'expEarned': visit['exp_gained'], // old camelCase
              'expGained': visit['exp_gained'], // correct camelCase for UI
              'name': partner?['name'] ?? 'Unknown Location', // for UI
              'location_name': partner?['name'] ?? 'Unknown Location',
              'locationName':
                  partner?['name'] ?? 'Unknown Location', // camelCase for UI
              'city': partner?['city'] ?? '',
              'province': partner?['province'] ?? '',
              'description':
                  partner != null
                      ? '${partner['city']}, ${partner['province']}'
                      : 'No details available',
            };

            return locationData;
          }).toList();

      notifyListeners();
    } catch (e, stackTrace) {
      _error = 'Failed to load visited locations: $e';
      debugPrint('Error loading visited locations: $e');
      notifyListeners();
    }
  }

  /// Upgrade user to Pelaku Budaya
  Future<void> upgradeToPelakuBudaya() async {
    if (_profile == null) {
      _error = 'No profile loaded';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Update in Supabase database
      await SupabaseConfig.client
          .from('users')
          .update({
            'is_pelaku_budaya': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', _profile!.id);

      debugPrint(
        '✅ Database updated: is_pelaku_budaya = true for user ${_profile!.id}',
      );

      _profile = _profile!.copyWith(
        isPelakuBudaya: true,
        lastActive: DateTime.now(),
      );

      debugPrint('✅ User upgraded to Pelaku Budaya');

      // Notify listeners immediately after updating profile
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to upgrade: $e';
      debugPrint('❌ ProfileProvider.upgradeToPelakuBudaya error: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add uploaded karya ID
  Future<void> addUploadedKarya(String karyaId) async {
    if (_profile == null) return;

    final updatedIds = List<String>.from(_profile!.uploadedKaryaIds)
      ..add(karyaId);
    _profile = _profile!.copyWith(uploadedKaryaIds: updatedIds);
    notifyListeners();

    // Sync to Supabase (now properly implemented)
    try {
      await SupabaseConfig.client
          .from('users')
          .update({'uploaded_karya_ids': updatedIds})
          .eq('id', _profile!.id);

      debugPrint('✅ Synced karya to database: $karyaId');
    } catch (e) {
      debugPrint('❌ Error syncing uploaded_karya_ids: $e');
      // Note: Keep local state even if sync fails
    }
  }

  /// Clear all data (for logout)
  void clear() {
    _profile = null;
    _character = null;
    _collectibles = [];
    _error = null;
    notifyListeners();
    debugPrint('🔄 ProfileProvider cleared');
  }
}
