import '../config/test_locations.dart';

/// Service untuk fetch location data
/// Full LOCAL mode - menggunakan test_locations.dart
class LocationService {
  /// Get location by UUID
  /// Returns: Map dengan keys: name, latitude, longitude, geofence_radius, description
  static Future<Map<String, dynamic>?> getLocationByUUID(String uuid) async {
    print('📍 [LOCAL MODE] Looking up UUID: "$uuid"');
    return _getLocalLocation(uuid);
  }

  /// Check if location exists
  static Future<bool> locationExists(String uuid) async {
    final location = await getLocationByUUID(uuid);
    return location != null;
  }

  /// Get all locations
  static Future<List<Map<String, dynamic>>> getAllLocations() async {
    print('📍 [LOCAL MODE] Getting all locations');
    return _getAllLocalLocations();
  }

  /// Get location count
  static Future<int> getLocationCount() async {
    return TestLocations.locations.length;
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // PRIVATE METHODS - LOCAL DATA
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
    print('Mode: 📍 LOCAL (test_locations.dart)');
    print('Total Locations: ${TestLocations.locations.length}');
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