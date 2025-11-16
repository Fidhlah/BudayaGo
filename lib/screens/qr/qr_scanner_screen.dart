import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/geofencing_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_dimensions.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  late MobileScannerController cameraController;
  final GeofencingService _geofencingService = GeofencingService();
  bool isScanned = false;
  bool isProcessing = false;
  
  bool isCameraPermissionGranted = false;
  bool isLocationPermissionGranted = false;
  bool isCheckingPermission = true;
  
  DateTime? _lastScanTime;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _checkAllPermissions();
  }

  void _initCamera() {
    cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
      // ✅ TAMBAH INI: Auto start false
      autoStart: false,
    );
  }

  // ✅ START CAMERA SETELAH PERMISSION GRANTED
  Future<void> _startCamera() async {
    try {
      print('📷 Starting camera...');
      await cameraController.start();
      print('✅ Camera started');
    } catch (e) {
      print('❌ Error starting camera: $e');
    }
  }

  Future<void> _checkAllPermissions() async {
    setState(() => isCheckingPermission = true);

    try {
      print('🔍 Checking permissions...');

      // 1. Check Camera Permission
      var cameraStatus = await Permission.camera.status;
      print('📷 Camera status: $cameraStatus');

      if (cameraStatus.isDenied) {
        print('⚠️ Camera denied, requesting...');
        cameraStatus = await Permission.camera.request();
        print('📷 After request: $cameraStatus');
      }

      if (cameraStatus.isPermanentlyDenied) {
        setState(() => isCheckingPermission = false);
        _showPermissionDialog(
          icon: Icons.camera_alt_outlined,
          title: '📷 Izin Kamera Diblokir',
          message: 'Izin kamera telah diblokir secara permanen.\n\nSilakan aktifkan di:\nPengaturan > Aplikasi > BudayaGo > Izin > Kamera',
          canRetry: false,
          showSettingsButton: true,
        );
        return;
      }

      if (!cameraStatus.isGranted) {
        setState(() => isCheckingPermission = false);
        _showPermissionDialog(
          icon: Icons.camera_alt_outlined,
          title: '📷 Izin Kamera Diperlukan',
          message: 'Aplikasi membutuhkan akses kamera untuk scan QR code.',
          canRetry: true,
          showSettingsButton: false,
        );
        return;
      }

      setState(() => isCameraPermissionGranted = true);
      print('✅ Camera permission granted');

      // 2. Check Location Permission
      var locationStatus = await Permission.location.status;
      print('📍 Location status: $locationStatus');

      if (locationStatus.isDenied) {
        print('⚠️ Location denied, requesting...');
        locationStatus = await Permission.location.request();
        print('📍 After request: $locationStatus');
      }

      if (locationStatus.isPermanentlyDenied) {
        setState(() => isCheckingPermission = false);
        _showPermissionDialog(
          icon: Icons.location_off,
          title: '📍 Izin Lokasi Diblokir',
          message: 'Izin lokasi telah diblokir secara permanen.\n\nSilakan aktifkan di:\nPengaturan > Aplikasi > BudayaGo > Izin > Lokasi',
          canRetry: false,
          showSettingsButton: true,
        );
        return;
      }

      if (!locationStatus.isGranted) {
        setState(() => isCheckingPermission = false);
        _showPermissionDialog(
          icon: Icons.location_off,
          title: '📍 Izin Lokasi Diperlukan',
          message: 'Aplikasi membutuhkan akses lokasi untuk memverifikasi bahwa Anda berada di lokasi wisata yang benar.',
          canRetry: true,
          showSettingsButton: false,
        );
        return;
      }

      setState(() => isLocationPermissionGranted = true);
      print('✅ Location permission granted');

      // 3. All permissions granted!
      setState(() => isCheckingPermission = false);
      print('🎉 All permissions granted!');
      
      // ✅ START CAMERA SETELAH PERMISSION GRANTED
      await _startCamera();

    } catch (e) {
      print('❌ Error checking permissions: $e');
      setState(() => isCheckingPermission = false);
      _showPermissionDialog(
        icon: Icons.error_outline,
        title: '❌ Error',
        message: 'Terjadi kesalahan saat memeriksa izin:\n$e',
        canRetry: true,
        showSettingsButton: false,
      );
    }
  }

  void _showPermissionDialog({
    required IconData icon,
    required String title,
    required String message,
    required bool canRetry,
    required bool showSettingsButton,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(icon, color: AppColors.warning, size: AppDimensions.iconL),
            SizedBox(width: AppDimensions.spaceS),
            Expanded(child: Text(title, style: AppTextStyles.h6)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            SizedBox(height: AppDimensions.spaceM),
            Container(
              padding: EdgeInsets.all(AppDimensions.paddingS),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                border: Border.all(color: AppColors.info.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.info, size: AppDimensions.iconS),
                  SizedBox(width: AppDimensions.spaceXS),
                  Expanded(
                    child: Text(
                      'Fitur ini memastikan Anda berada di lokasi wisata yang benar sebelum melakukan check-in.',
                      style: AppTextStyles.caption,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (!canRetry)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Kembali'),
            ),
          if (showSettingsButton)
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                await openAppSettings();
              },
              icon: const Icon(Icons.settings),
              label: const Text('Buka Pengaturan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.white,
              ),
            ),
          if (canRetry)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
          if (canRetry)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _checkAllPermissions();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ LOADING STATE
    if (isCheckingPermission) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Scan QR Code'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Memeriksa izin...'),
            ],
          ),
        ),
      );
    }

    // ✅ PERMISSION NOT GRANTED STATE
    if (!isCameraPermissionGranted || !isLocationPermissionGranted) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Scan QR Code'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(AppDimensions.paddingL),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  !isCameraPermissionGranted 
                    ? Icons.camera_alt_outlined 
                    : Icons.location_off,
                  size: AppDimensions.iconXL * 1.67, // 80px
                  color: AppColors.error.withOpacity(0.6),
                ),
                SizedBox(height: AppDimensions.spaceL),
                Text(
                  !isCameraPermissionGranted 
                    ? 'Izin Kamera Diperlukan'
                    : 'Izin Lokasi Diperlukan',
                  style: AppTextStyles.h4,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppDimensions.spaceS),
                Text(
                  !isCameraPermissionGranted
                    ? 'Aplikasi membutuhkan akses kamera untuk scan QR code.'
                    : 'Aplikasi membutuhkan akses lokasi untuk memverifikasi bahwa Anda berada di lokasi wisata yang benar.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppDimensions.spaceXL),
                ElevatedButton.icon(
                  onPressed: _checkAllPermissions,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Izinkan Akses'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingL,
                      vertical: AppDimensions.paddingS,
                    ),
                  ),
                ),
                SizedBox(height: AppDimensions.spaceS),
                TextButton.icon(
                  onPressed: () async {
                    await openAppSettings();
                  },
                  icon: const Icon(Icons.settings),
                  label: const Text('Buka Pengaturan'),
                ),
                SizedBox(height: AppDimensions.spaceS),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Kembali'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ✅ SCANNER ACTIVE STATE (Permission granted)
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        actions: [
          IconButton(
            icon: Icon(
              cameraController.torchEnabled ? Icons.flash_on : Icons.flash_off,
            ),
            onPressed: () async {
              await cameraController.toggleTorch();
              setState(() {});
            },
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            errorBuilder: (context, error, child) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: AppDimensions.iconXL * 1.67, color: AppColors.error),
                    SizedBox(height: AppDimensions.spaceM),
                    Text(
                      'Error Kamera',
                      style: AppTextStyles.h5,
                    ),
                    SizedBox(height: AppDimensions.spaceXS),
                    Text(
                      error.errorDetails?.message ?? 'Gagal membuka kamera',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium,
                    ),
                    SizedBox(height: AppDimensions.spaceM),
                    ElevatedButton(
                      onPressed: () async {
                        // ✅ FIX: Stop dulu sebelum restart
                        try {
                          await cameraController.stop();
                          await Future.delayed(const Duration(milliseconds: 500));
                          await cameraController.start();
                        } catch (e) {
                          print('❌ Error restarting camera: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Gagal restart kamera: $e')),
                          );
                        }
                      },
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              );
            },
            onDetect: (capture) {
              final now = DateTime.now();
              if (_lastScanTime != null && 
                  now.difference(_lastScanTime!).inSeconds < 3) {
                return;
              }

              if (!isScanned && !isProcessing) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null) {
                    print('🔍 QR Code Scanned: "${barcode.rawValue}"');
                    setState(() {
                      isScanned = true;
                      _lastScanTime = now;
                    });
                    _handleQRCode(barcode.rawValue!);
                    break;
                  }
                }
              }
            },
          ),
          CustomPaint(
            painter: ScannerOverlay(),
            child: const SizedBox.expand(),
          ),
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingL,
                  vertical: AppDimensions.paddingS,
                ),
                decoration: BoxDecoration(
                  color: AppColors.overlay,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: Text(
                  'Arahkan kamera ke QR Code',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleQRCode(String qrCode) async {
    if (isProcessing) return;
    setState(() => isProcessing = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final position = await _geofencingService.getCurrentLocation();

      if (position == null) {
        if (!mounted) return;
        Navigator.pop(context);
        await _showErrorDialog(
          '❌ Gagal Mendapatkan Lokasi',
          'Pastikan GPS aktif dan izin lokasi sudah diberikan',
        );
        _resetScanState();
        return;
      }

      final result = await _geofencingService.validateQRCode(
        qrString: qrCode,
        userPosition: position,
      );

      if (!mounted) return;
      Navigator.pop(context);

      if (result['valid']) {
        _showSuccessDialog(result);
      } else {
        String title;
        switch (result['error']) {
          case 'INVALID_PREFIX':
            title = '❌ QR Code Tidak Valid';
            break;
          case 'INVALID_FORMAT':
            title = '❌ Format QR Rusak';
            break;
          case 'UNSUPPORTED_VERSION':
            title = '⚠️ Versi Tidak Didukung';
            break;
          case 'LOCATION_NOT_FOUND':
            title = '❌ Lokasi Tidak Ditemukan';
            break;
          case 'OUT_OF_RANGE':
            title = '📍 Lokasi Terlalu Jauh';
            break;
          default:
            title = '❌ Error';
        }

        await _showErrorDialog(
          title,
          result['message'],
          details: result['error'] == 'OUT_OF_RANGE'
              ? 'Jarak Anda: ${result['distance'].toStringAsFixed(0)} meter\n'
                'Maksimal: ${result['radius']} meter'
              : result['details'],
        );
        _resetScanState();
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      await _showErrorDialog('❌ Error', 'Terjadi kesalahan: $e');
      _resetScanState();
    }
  }

  void _resetScanState() {
    if (mounted) {
      setState(() {
        isProcessing = false;
        isScanned = false;
      });
    }
  }

  Future<void> _showErrorDialog(String title, String message, {String? details}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.error, size: AppDimensions.iconL),
            SizedBox(width: AppDimensions.spaceS),
            Expanded(child: Text(title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            if (details != null) ...[
              SizedBox(height: AppDimensions.spaceS),
              Container(
                padding: EdgeInsets.all(AppDimensions.paddingXS),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
                ),
                child: Text(
                  details,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(Map<String, dynamic> result) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: AppDimensions.iconL),
            SizedBox(width: AppDimensions.spaceS),
            const Text('Berhasil!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '✅ QR Code Valid!',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
            ),
            SizedBox(height: AppDimensions.spaceM),
            Container(
              padding: EdgeInsets.all(AppDimensions.paddingS),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, size: AppDimensions.iconS, color: AppColors.success),
                      SizedBox(width: AppDimensions.spaceXS),
                      Expanded(
                        child: Text(
                          result['locationName'],
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppDimensions.spaceXS),
                  Text(
                    result['description'] ?? '',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Divider(height: 16),
                  Text(
                    'UUID: ${result['uuid']}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    'Jarak Anda: ${result['distance'].toStringAsFixed(1)} m',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    'Radius: ${result['radius']} m',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetScanState();
            },
            child: const Text('Scan Lagi'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, result);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}

class ScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scanArea = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: 250,
      height: 250,
    );

    final cutOutPath = Path.combine(
      PathOperation.difference,
      Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
      Path()..addRRect(RRect.fromRectAndRadius(scanArea, Radius.circular(AppDimensions.radiusM))),
    );

    canvas.drawPath(cutOutPath, Paint()..color = AppColors.overlay);

    final paint = Paint()
      ..color = AppColors.secondary
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    const cornerLength = 30.0;

    canvas.drawLine(Offset(scanArea.left, scanArea.top), Offset(scanArea.left + cornerLength, scanArea.top), paint);
    canvas.drawLine(Offset(scanArea.left, scanArea.top), Offset(scanArea.left, scanArea.top + cornerLength), paint);
    canvas.drawLine(Offset(scanArea.right, scanArea.top), Offset(scanArea.right - cornerLength, scanArea.top), paint);
    canvas.drawLine(Offset(scanArea.right, scanArea.top), Offset(scanArea.right, scanArea.top + cornerLength), paint);
    canvas.drawLine(Offset(scanArea.left, scanArea.bottom), Offset(scanArea.left + cornerLength, scanArea.bottom), paint);
    canvas.drawLine(Offset(scanArea.left, scanArea.bottom), Offset(scanArea.left, scanArea.bottom - cornerLength), paint);
    canvas.drawLine(Offset(scanArea.right, scanArea.bottom), Offset(scanArea.right - cornerLength, scanArea.bottom), paint);
    canvas.drawLine(Offset(scanArea.right, scanArea.bottom), Offset(scanArea.right, scanArea.bottom - cornerLength), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}