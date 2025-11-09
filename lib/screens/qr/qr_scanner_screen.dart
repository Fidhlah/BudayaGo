import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/geofencing_service.dart';

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
            Icon(icon, color: Colors.orange, size: 28),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 18))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Fitur ini memastikan Anda berada di lokasi wisata yang benar sebelum melakukan check-in.',
                      style: TextStyle(fontSize: 12),
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
                backgroundColor: Colors.orange,
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
                backgroundColor: Colors.blue,
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
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  !isCameraPermissionGranted 
                    ? Icons.camera_alt_outlined 
                    : Icons.location_off,
                  size: 80,
                  color: Colors.red.shade300,
                ),
                const SizedBox(height: 24),
                Text(
                  !isCameraPermissionGranted 
                    ? 'Izin Kamera Diperlukan'
                    : 'Izin Lokasi Diperlukan',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  !isCameraPermissionGranted
                    ? 'Aplikasi membutuhkan akses kamera untuk scan QR code.'
                    : 'Aplikasi membutuhkan akses lokasi untuk memverifikasi bahwa Anda berada di lokasi wisata yang benar.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _checkAllPermissions,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Izinkan Akses'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () async {
                    await openAppSettings();
                  },
                  icon: const Icon(Icons.settings),
                  label: const Text('Buka Pengaturan'),
                ),
                const SizedBox(height: 12),
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
                    const Icon(Icons.error_outline, size: 80, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text(
                      'Error Kamera',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.errorDetails?.message ?? 'Gagal membuka kamera',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Arahkan kamera ke QR Code',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
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
            const Icon(Icons.error_outline, color: Colors.red, size: 32),
            const SizedBox(width: 12),
            Expanded(child: Text(title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            if (details != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  details,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red.shade900,
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
              backgroundColor: Colors.red,
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
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 12),
            Text('Berhasil!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '✅ QR Code Valid!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 20, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          result['locationName'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    result['description'] ?? '',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                  const Divider(height: 16),
                  Text(
                    'UUID: ${result['uuid']}',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                  ),
                  Text(
                    'Jarak Anda: ${result['distance'].toStringAsFixed(1)} m',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                  ),
                  Text(
                    'Radius: ${result['radius']} m',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
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
              backgroundColor: Colors.green,
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
      Path()..addRRect(RRect.fromRectAndRadius(scanArea, const Radius.circular(12))),
    );

    canvas.drawPath(cutOutPath, Paint()..color = Colors.black54);

    final paint = Paint()
      ..color = Colors.white
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