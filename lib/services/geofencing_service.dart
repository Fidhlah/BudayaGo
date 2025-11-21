import 'package:geolocator/geolocator.dart';
import 'dart:math';
import '../models/qr_code_model.dart';
import '../config/qr_config.dart';
import '../config/supabase_config.dart';

/// Service untuk handle geofencing logic
class GeofencingService {
  /// Get current user location
  Future<Position?> getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return position;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  /// Validate QR Code dengan geofencing
  ///
  /// Process:
  /// 1. Decode QR string ke QRCodeModel
  /// 2. Validate UUID exists di database/test_locations
  /// 3. Check user location dalam radius
  Future<Map<String, dynamic>> validateQRCode({
    required String qrString,
    required Position userPosition,
  }) async {
    try {
      print('🔍 Validating QR Code');
      print('   Raw QR: "$qrString"');

      // Step 1: Decode QR Code
      QRCodeModel qrCode;
      try {
        // Decode otomatis pakai QRConfig.qrPrefix
        qrCode = QRCodeModel.decode(
          qrString: qrString.trim(),
          // ✅ Tidak perlu specify expectedPrefix, otomatis pakai config!
        );
        print('✅ QR decoded successfully');
        print('   UUID: ${qrCode.uuid}');
        print('   Version: ${qrCode.version}');
      } on QRCodePrefixException catch (e) {
        return {
          'valid': false,
          'error': 'INVALID_PREFIX',
          'message': 'QR Code tidak valid.\n\nIni bukan QR Code BudayaGo!',
          'details': e.message,
        };
      } on QRCodeFormatException catch (e) {
        return {
          'valid': false,
          'error': 'INVALID_FORMAT',
          'message':
              'Format QR Code tidak valid.\n\nPastikan QR Code dalam kondisi baik.',
          'details': e.message,
        };
      }

      // Step 2: Check version compatibility
      if (!QRConfig.isVersionSupported(qrCode.version)) {
        return {
          'valid': false,
          'error': 'UNSUPPORTED_VERSION',
          'message':
              'Versi QR Code tidak didukung.\n\nSilakan update aplikasi ke versi terbaru.',
          'qrVersion': qrCode.version,
          'supportedVersions': QRConfig.supportedVersions,
        };
      }

      // Step 3: Check if UUID exists in database (fetch from Supabase)
      final locationData =
          await SupabaseConfig.client
              .from('cultural_partners')
              .select()
              .eq('id', qrCode.uuid)
              .maybeSingle();

      if (locationData == null) {
        print('❌ UUID not found in database');
        return {
          'valid': false,
          'error': 'LOCATION_NOT_FOUND',
          'message':
              'Lokasi tidak ditemukan.\n\nQR Code mungkin sudah tidak aktif.',
          'uuid': qrCode.uuid,
        };
      }

      // Step 4: Get target location data
      print('✅ Location found: ${locationData['name']}');

      // Step 5: Calculate distance
      double distanceInMeters = calculateDistance(
        userLat: userPosition.latitude,
        userLng: userPosition.longitude,
        targetLat: locationData['latitude'],
        targetLng: locationData['longitude'],
      );

      // Default radius if not set
      final radius = locationData['radius'] ?? 200.0;

      print('📏 Distance: ${distanceInMeters.toStringAsFixed(2)}m');
      print('📏 Max radius: ${radius}m');

      // Step 6: Check if within radius
      if (distanceInMeters <= radius) {
        return {
          'valid': true,
          'uuid': qrCode.uuid,
          'qrVersion': qrCode.version,
          'locationName': locationData['name'],
          'locationId': locationData['id'],
          'description': locationData['description'] ?? '',
          'distance': distanceInMeters,
          'radius': radius,
          'coordinates': {
            'lat': locationData['latitude'],
            'lng': locationData['longitude'],
          },
        };
      } else {
        return {
          'valid': false,
          'error': 'OUT_OF_RANGE',
          'message':
              'Anda terlalu jauh dari lokasi.\n\nMohon datang ke lokasi terlebih dahulu.',
          'locationName': locationData['name'],
          'distance': distanceInMeters,
          'radius': radius,
        };
      }
    } catch (e) {
      print('❌ Error validating QR: $e');
      return {
        'valid': false,
        'error': 'UNKNOWN_ERROR',
        'message': 'Terjadi kesalahan.\n\nSilakan coba lagi.',
        'details': e.toString(),
      };
    }
  }

  /// Calculate distance between two coordinates (Haversine formula)
  double calculateDistance({
    required double userLat,
    required double userLng,
    required double targetLat,
    required double targetLng,
  }) {
    const earthRadius = 6371000; // meter

    final dLat = _toRadians(targetLat - userLat);
    final dLng = _toRadians(targetLng - userLng);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(userLat)) *
            cos(_toRadians(targetLat)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }
}
