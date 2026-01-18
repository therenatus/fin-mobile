import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/riverpod/providers.dart';
import '../../core/models/material.dart' as mat;

class BarcodeScanScreen extends ConsumerStatefulWidget {
  const BarcodeScanScreen({super.key});

  @override
  ConsumerState<BarcodeScanScreen> createState() => _BarcodeScanScreenState();
}

class _BarcodeScanScreenState extends ConsumerState<BarcodeScanScreen> {
  MobileScannerController? _controller;
  bool _isProcessing = false;
  String? _lastScannedCode;
  bool _torchEnabled = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    final code = barcode.rawValue;

    if (code == null || code == _lastScannedCode) return;

    setState(() {
      _isProcessing = true;
      _lastScannedCode = code;
    });

    // Pause camera while processing
    await _controller?.stop();

    try {
      final notifier = ref.read(materialsNotifierProvider.notifier);
      final material = await notifier.findByBarcode(code);

      if (material != null && mounted) {
        Navigator.pop(context, material);
      } else if (mounted) {
        _showNotFoundDialog(code);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка поиска: $e'),
            backgroundColor: AppColors.error,
          ),
        );
        // Resume camera on error
        await _controller?.start();
      }
    }

    setState(() => _isProcessing = false);
  }

  void _showNotFoundDialog(String barcode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Материал не найден'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Штрих-код: $barcode'),
            const SizedBox(height: 16),
            const Text('Материал с таким штрих-кодом не найден в базе.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _controller?.start();
              setState(() => _lastScannedCode = null);
            },
            child: const Text('Сканировать ещё'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(this.context);
            },
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _toggleTorch() async {
    await _controller?.toggleTorch();
    setState(() {
      _torchEnabled = !_torchEnabled;
    });
  }

  void _switchCamera() async {
    await _controller?.switchCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Сканирование штрих-кода'),
        actions: [
          IconButton(
            icon: Icon(
              _torchEnabled ? Icons.flash_on : Icons.flash_off,
              color: _torchEnabled ? AppColors.warning : Colors.white,
            ),
            onPressed: _toggleTorch,
            tooltip: 'Вспышка',
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: _switchCamera,
            tooltip: 'Переключить камеру',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera view
          if (_controller != null)
            MobileScanner(
              controller: _controller!,
              onDetect: _onDetect,
            ),

          // Scan overlay
          _buildScanOverlay(),

          // Instructions
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    if (_isProcessing)
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    else ...[
                      const Icon(
                        Icons.qr_code_scanner,
                        color: Colors.white,
                        size: 48,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Наведите камеру на штрих-код',
                        style: AppTypography.bodyLarge.copyWith(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Поддерживаются коды EAN-13, EAN-8, Code-128',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanOverlay() {
    return CustomPaint(
      painter: _ScanOverlayPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _ScanOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    // Calculate scan area
    final scanWidth = size.width * 0.8;
    final scanHeight = scanWidth * 0.6;
    final scanRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 - 50),
      width: scanWidth,
      height: scanHeight,
    );

    // Draw dark overlay with cutout
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(
        scanRect,
        const Radius.circular(16),
      ))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // Draw scan area border
    final borderPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawRRect(
      RRect.fromRectAndRadius(scanRect, const Radius.circular(16)),
      borderPaint,
    );

    // Draw corner accents
    final cornerPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    const cornerLength = 30.0;
    const cornerOffset = 8.0;

    // Top-left corner
    canvas.drawLine(
      Offset(scanRect.left + cornerOffset, scanRect.top + cornerLength),
      Offset(scanRect.left + cornerOffset, scanRect.top + cornerOffset),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanRect.left + cornerOffset, scanRect.top + cornerOffset),
      Offset(scanRect.left + cornerLength, scanRect.top + cornerOffset),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(scanRect.right - cornerLength, scanRect.top + cornerOffset),
      Offset(scanRect.right - cornerOffset, scanRect.top + cornerOffset),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanRect.right - cornerOffset, scanRect.top + cornerOffset),
      Offset(scanRect.right - cornerOffset, scanRect.top + cornerLength),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(scanRect.left + cornerOffset, scanRect.bottom - cornerLength),
      Offset(scanRect.left + cornerOffset, scanRect.bottom - cornerOffset),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanRect.left + cornerOffset, scanRect.bottom - cornerOffset),
      Offset(scanRect.left + cornerLength, scanRect.bottom - cornerOffset),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(scanRect.right - cornerLength, scanRect.bottom - cornerOffset),
      Offset(scanRect.right - cornerOffset, scanRect.bottom - cornerOffset),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanRect.right - cornerOffset, scanRect.bottom - cornerOffset),
      Offset(scanRect.right - cornerOffset, scanRect.bottom - cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
