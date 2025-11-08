import 'package:geolocator/geolocator.dart';
import '../utils/test_locations.dart';

/// Service untuk handle geofencing logic
class GeofencingService {
  /// Get current user location
  Future<Position?> getCurrentLocation() async {
    try {
      // Check GPS aktif
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('❌ GPS tidak aktif');
        return null;
      }

      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('❌ Permission ditolak');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('❌ Permission ditolak permanent');
        return null;
      }

      // Get location
      print('📍 Getting location...');
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      print('✅ User location: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      print('❌ Error getting location: $e');
      return null;
    }
  }

  /// Calculate distance between two coordinates
  double calculateDistance({
    required double userLat,
    required double userLng,
    required double targetLat,
    required double targetLng,
  }) {
    return Geolocator.distanceBetween(
      userLat,
      userLng,
      targetLat,
      targetLng,
    );
  }

  /// Validate QR code with geofencing
  Future<Map<String, dynamic>> validateQRCode({
    required String qrCode,
    required Position userPosition,
  }) async {
    try {
      // 1. Check if QR code exists
      if (!TestLocations.isValidQRCode(qrCode)) {
        return {
          'valid': false,
          'error': 'QR_NOT_FOUND',
          'message': 'QR Code "$qrCode" tidak terdaftar dalam sistem',
        };
      }

      // 2. Get target location
      final targetLocation = TestLocations.getLocation(qrCode)!;

      // 3. Calculate distance
      double distanceInMeters = calculateDistance(
        userLat: userPosition.latitude,
        userLng: userPosition.longitude,
        targetLat: targetLocation['lat'],
        targetLng: targetLocation['lng'],
      );

      print('📏 Distance to ${targetLocation['name']}: ${distanceInMeters.toStringAsFixed(2)}m');

      // 4. Check if within radius
      if (distanceInMeters <= targetLocation['radius']) {
        return {
          'valid': true,
          'qrCode': qrCode,
          'locationName': targetLocation['name'],
          'description': targetLocation['description'],
          'distance': distanceInMeters,
          'radius': targetLocation['radius'],
        };
      } else {
        return {
          'valid': false,
          'error': 'OUT_OF_RANGE',
          'message': 'Anda harus berada di ${targetLocation['name']} untuk scan QR code ini.',
          'locationName': targetLocation['name'],
          'distance': distanceInMeters,
          'radius': targetLocation['radius'],
        };
      }
    } catch (e) {
      return {
        'valid': false,
        'error': 'UNKNOWN_ERROR',
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }
}