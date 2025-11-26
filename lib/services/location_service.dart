import '../config/supabase_config.dart';
import '../config/test_locations.dart';

/// Service untuk fetch location data
/// DATABASE mode with LOCAL fallback
class LocationService {
  // Toggle between DATABASE and LOCAL mode
  static const bool _useDatabaseMode = true;

  /// Get location by UUID
  /// Returns: Map dengan keys: name, latitude, longitude, geofence_radius, description
  static Future<Map<String, dynamic>?> getLocationByUUID(String uuid) async {
    if (_useDatabaseMode) {
      print('📍 [DATABASE MODE] Looking up UUID: "$uuid"');
      return _getDatabaseLocation(uuid);
    } else {
      print('📍 [LOCAL MODE] Looking up UUID: "$uuid"');
      return _getLocalLocation(uuid);
    }
  }

  /// Check if location exists
  static Future<bool> locationExists(String uuid) async {
    final location = await getLocationByUUID(uuid);
    return location != null;
  }

  /// Get all locations
  static Future<List<Map<String, dynamic>>> getAllLocations() async {
    if (_useDatabaseMode) {
      print('📍 [DATABASE MODE] Getting all locations');
      return _getAllDatabaseLocations();
    } else {
      print('📍 [LOCAL MODE] Getting all locations');
      return _getAllLocalLocations();
    }
  }

  /// Get location count
  static Future<int> getLocationCount() async {
    final locations = await getAllLocations();
    return locations.length;
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // PRIVATE METHODS - DATABASE
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static Future<Map<String, dynamic>?> _getDatabaseLocation(String uuid) async {
    try {
      final data =
          await SupabaseConfig.client
              .from('cultural_partners')
              .select(
                'id, name, latitude, longitude, geofence_radius, description',
              )
              .eq('id', uuid)
              .maybeSingle();

      if (data == null) {
        print('❌ UUID not found in database');
        print('   Falling back to local data...');
        return _getLocalLocation(uuid);
      }

      print('✅ Found in database: ${data['name']}');
      return {
        'uuid': data['id'],
        'name': data['name'],
        'latitude': data['latitude'],
        'longitude': data['longitude'],
        'geofence_radius': data['geofence_radius'] ?? 100,
        'description': data['description'] ?? '',
      };
    } catch (e) {
      print('❌ Database error: $e');
      print('   Falling back to local data...');
      return _getLocalLocation(uuid);
    }
  }

  static Future<List<Map<String, dynamic>>> _getAllDatabaseLocations() async {
    try {
      final data = await SupabaseConfig.client
          .from('cultural_partners')
          .select(
            'id, name, latitude, longitude, geofence_radius, description, city, province',
          )
          .order('province')
          .order('city')
          .order('name');

      if (data.isEmpty) {
        print('⚠️ No locations in database, using local data');
        return _getAllLocalLocations();
      }

      return List<Map<String, dynamic>>.from(
        data.map(
          (item) => {
            'uuid': item['id'],
            'name': item['name'],
            'latitude': item['latitude'],
            'longitude': item['longitude'],
            'geofence_radius': item['geofence_radius'] ?? 100,
            'description': item['description'] ?? '',
            'city': item['city'] ?? '',
            'province': item['province'] ?? '',
          },
        ),
      );
    } catch (e) {
      print('❌ Database error: $e');
      print('   Falling back to local data...');
      return _getAllLocalLocations();
    }
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // PRIVATE METHODS - LOCAL DATA (FALLBACK)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  static Future<Map<String, dynamic>?> _getLocalLocation(String uuid) async {
    final localData = TestLocations.getLocationByUUID(uuid);

    if (localData == null) {
      print('❌ UUID not found in test_locations.dart');
      print('📋 Available UUIDs:');
      for (var availableUuid in TestLocations.getAllUUIDs()) {
        final loc = TestLocations.getLocationByUUID(availableUuid);
        print('   - "$availableUuid" => ${loc?['name']}');
      }
      return null;
    }

    print('✅ Found in test_locations.dart: ${localData['name']}');
    // Normalize keys to standard format
    return {
      'uuid': uuid,
      'name': localData['name'],
      'latitude': localData['lat'],
      'longitude': localData['lng'],
      'geofence_radius': localData['radius'],
      'description': localData['description'],
    };
  }

  static Future<List<Map<String, dynamic>>> _getAllLocalLocations() async {
    final List<Map<String, dynamic>> results = [];

    for (var entry in TestLocations.locations.entries) {
      results.add({
        'uuid': entry.key,
        'name': entry.value['name'],
        'latitude': entry.value['lat'],
        'longitude': entry.value['lng'],
        'geofence_radius': entry.value['radius'],
        'description': entry.value['description'],
      });
    }

    return results;
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // UTILITY METHODS
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  /// Print service info
  static void printServiceInfo() {
    print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📍 LOCATION SERVICE');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    if (_useDatabaseMode) {
      print('Mode: 💾 DATABASE (with LOCAL fallback)');
    } else {
      print('Mode: 📍 LOCAL (test_locations.dart)');
    }
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
  }

  /// Debug: Print all available locations
  static Future<void> debugPrintAllLocations() async {
    print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('📋 DEBUG: ALL LOCATIONS');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    final locations = await getAllLocations();

    if (locations.isEmpty) {
      print('❌ No locations found');
    } else {
      print('✅ Found ${locations.length} locations:\n');

      for (var i = 0; i < locations.length; i++) {
        final loc = locations[i];
        print('${i + 1}. ${loc['name']}');
        print('   UUID: ${loc['uuid']}');
        print('   Coords: ${loc['latitude']}, ${loc['longitude']}');
        print('   Radius: ${loc['geofence_radius']} m');
        print('   Desc: ${loc['description']}\n');
      }
    }

    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
  }
}
