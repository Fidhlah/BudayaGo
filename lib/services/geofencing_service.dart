import 'package:geolocator/geolocator.dart';
import '../config/qr_config.dart';
import '../models/qr_code_model.dart';
import 'location_service.dart';

class GeofencingService {
  GeofencingService() {
    // Print service info saat diinisialisasi
    LocationService.printServiceInfo();
  }

  /// Get current location with permission handling
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('❌ Location services are disabled');
      return null;
    }

    // Check location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('❌ Location permissions are denied');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('❌ Location permissions are permanently denied');
      return null;
    }

    // Get current position
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      print('✅ Got position: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      print('❌ Error getting position: $e');
      return null;
    }
  }

  /// Validate QR code and check geofencing
  Future<Map<String, dynamic>> validateQRCode({
    required String qrString,
    required Position userPosition,
  }) async {
    try {
      print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🔍 VALIDATE QR CODE - START');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      
      // Parse QR
      final qrCode = QRCodeModel.decode(qrString: qrString);
      print('✅ QR Decoded - UUID: ${qrCode.uuid}, Version: ${qrCode.version}');

      // Check version
      if (!QRConfig.isVersionSupported(qrCode.version)) {
        print('❌ Unsupported version: ${qrCode.version}');
        return {
          'valid': false,
          'error': 'UNSUPPORTED_VERSION',
          'message': 'Versi QR code (${qrCode.version}) tidak didukung',
        };
      }

      // Lookup location via LocationService
      print('🔍 Looking up UUID: "${qrCode.uuid}"');
      
      final response = await LocationService.getLocationByUUID(qrCode.uuid);
      
      if (response == null) {
        print('❌ LOCATION NOT FOUND');
        print('   Searched UUID: "${qrCode.uuid}"');
        
        // Debug: Show all available locations
        await LocationService.debugPrintAllLocations();
        
        return {
          'valid': false,
          'error': 'LOCATION_NOT_FOUND',
          'message': 'Lokasi wisata tidak ditemukan',
          'details': 'UUID: ${qrCode.uuid}',
        };
      }

      final locationName = response['name'] as String;
      final targetLat = response['latitude'] as double;
      final targetLng = response['longitude'] as double;
      final radius = (response['geofence_radius'] ?? 100) as int;

      print('📍 LOCATION FOUND:');
      print('   Name: $locationName');
      print('   Coords: $targetLat, $targetLng');
      print('   Radius: $radius m');

      // Calculate distance
      final distance = Geolocator.distanceBetween(
        userPosition.latitude,
        userPosition.longitude,
        targetLat,
        targetLng,
      );

      print('📏 DISTANCE CHECK:');
      print('   User: ${userPosition.latitude}, ${userPosition.longitude}');
      print('   Target: $targetLat, $targetLng');
      print('   Distance: ${distance.toStringAsFixed(1)} m');
      print('   Allowed: $radius m');
      print('   Result: ${distance <= radius ? '✅ WITHIN RANGE' : '❌ OUT OF RANGE'}');

      if (distance > radius) {
        return {
          'valid': false,
          'error': 'OUT_OF_RANGE',
          'message': 'Anda terlalu jauh dari $locationName',
          'distance': distance,
          'radius': radius,
        };
      }

      print('✅ VALIDATION SUCCESS!');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      return {
        'valid': true,
        'uuid': qrCode.uuid,
        'locationName': locationName,
        'description': response['description'],
        'distance': distance,
        'radius': radius,
      };
    } catch (e, stackTrace) {
      print('❌ EXCEPTION in validateQRCode:');
      print('   Error: $e');
      print('   Stack: $stackTrace');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      return {
        'valid': false,
        'error': 'EXCEPTION',
        'message': 'Error: ${e.toString()}',
      };
    }
  }
}
