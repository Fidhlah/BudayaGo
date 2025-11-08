import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool isScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        actions: [
          // ✅ GANTI INI - Untuk mobile_scanner 5.x
          IconButton(
            icon: Icon(
              cameraController.torchEnabled ? Icons.flash_on : Icons.flash_off,
            ),
            onPressed: () {
              cameraController.toggleTorch();
              setState(() {}); // Rebuild to update icon
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
            onDetect: (capture) {
              if (!isScanned) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null) {
                    setState(() => isScanned = true);
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

  void _handleQRCode(String qrCode) {
    // ❌ HAPUS INI - Jangan pop dulu
    // Navigator.pop(context, qrCode);
    
    // ✅ Langsung show dialog aja
    showDialog(
      context: context,
      barrierDismissible: false, // ✅ Prevent dismiss by tapping outside
      builder: (context) => AlertDialog(
        title: const Text('QR Code Detected'),
        content: Text(qrCode),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              setState(() => isScanned = false); // Reset scan state
            },
            child: const Text('Scan Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context, qrCode); // ✅ Return to home with result
            },
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

    canvas.drawPath(
      cutOutPath,
      Paint()..color = Colors.black54,
    );

    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    const cornerLength = 30.0;

    // Top-left
    canvas.drawLine(Offset(scanArea.left, scanArea.top), Offset(scanArea.left + cornerLength, scanArea.top), paint);
    canvas.drawLine(Offset(scanArea.left, scanArea.top), Offset(scanArea.left, scanArea.top + cornerLength), paint);

    // Top-right
    canvas.drawLine(Offset(scanArea.right, scanArea.top), Offset(scanArea.right - cornerLength, scanArea.top), paint);
    canvas.drawLine(Offset(scanArea.right, scanArea.top), Offset(scanArea.right, scanArea.top + cornerLength), paint);

    // Bottom-left
    canvas.drawLine(Offset(scanArea.left, scanArea.bottom), Offset(scanArea.left + cornerLength, scanArea.bottom), paint);
    canvas.drawLine(Offset(scanArea.left, scanArea.bottom), Offset(scanArea.left, scanArea.bottom - cornerLength), paint);

    // Bottom-right
    canvas.drawLine(Offset(scanArea.right, scanArea.bottom), Offset(scanArea.right - cornerLength, scanArea.bottom), paint);
    canvas.drawLine(Offset(scanArea.right, scanArea.bottom), Offset(scanArea.right, scanArea.bottom - cornerLength), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}