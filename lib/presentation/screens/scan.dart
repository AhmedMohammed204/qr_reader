import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_reader/core/qr_bloc/qr_cubit.dart';
import 'package:qr_reader/presentation/theme/colors.dart';
import 'package:qr_reader/presentation/widgets/wid_scanning_handler.dart';

class QrScannerWidget extends StatefulWidget {
  const QrScannerWidget({super.key});

  @override
  State<QrScannerWidget> createState() => _QrScannerWidgetState();
}

class _QrScannerWidgetState extends State<QrScannerWidget>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _scannerController = MobileScannerController();
  late AnimationController _animationController;

  bool _isProcessing = false;
  bool _isAnalyzingImage = false;
  TorchState _torchState = TorchState.off;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scannerController.torchState.addListener(() {
      if (mounted) {
        setState(() {
          _torchState = _scannerController.torchState.value;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final rawValue = capture.barcodes.first.rawValue;
    if (rawValue != null) {
      setState(() {
        _isProcessing = true;
      });
      context.read<QrCubit>().detectQr(rawValue);
    }
  }

  Future<void> _pickImageFromGallery() async {
    if (_isProcessing || _isAnalyzingImage) return;

    final messenger = ScaffoldMessenger.of(context);
    final ImagePicker picker = ImagePicker();

    try {
      setState(() {
        _isAnalyzingImage = true;
      });

      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) {
        _resetImageAnalyzer();
        return;
      }
      if (!mounted) return;

      final bool found = await _scannerController.analyzeImage(image.path);

      if (!mounted) return;

      if (!found) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('No QR code found in the selected image.'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      _resetImageAnalyzer();
    }
  }

  void _resetScanner() {
    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _resetImageAnalyzer() {
    if (mounted) {
      setState(() {
        _isAnalyzingImage = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scanWindow = Rect.fromCenter(
      center: MediaQuery.of(context).size.center(const Offset(0, -50)),
      width: 260,
      height: 260,
    );

    return widScanningHandler(
      onScanFlowComplete: _resetScanner,
      child: Scaffold(
        backgroundColor: clsColors.background,
        body: Stack(
          fit: StackFit.expand,
          children: [
            MobileScanner(
              controller: _scannerController,
              onDetect: _onDetect,
              scanWindow: scanWindow,
            ),
            CustomPaint(
              painter: _ScannerOverlayPainter(scanWindow: scanWindow),
            ),
            _buildAnimatedScanLine(scanWindow),
            _buildTopBar(),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              
              const Text(
                "Scan QR Code",
                style: TextStyle(
                  color: clsColors.primaryText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 48), 
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 30, left: 20, right: 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24.0),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: clsColors.cardBackground.withValues(alpha: .5),
                  borderRadius: BorderRadius.circular(24.0),
                  border: Border.all(
                    color: clsColors.secondaryText.withValues(alpha: .2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildGlassIconButton(
                      icon: _torchState == TorchState.on
                          ? Icons.flash_on_rounded
                          : Icons.flash_off_rounded,
                      onPressed: () => _scannerController.toggleTorch(),
                    ),
                    _buildGalleryButton(),
                    _buildGlassIconButton(
                      icon: Icons.cameraswitch_rounded,
                      onPressed: () => _scannerController.switchCamera(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGalleryButton() {
    return SizedBox(
      width: 64,
      height: 64,
      child: _isAnalyzingImage
          ? const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: clsColors.linkBlue,
                ),
              ),
            )
          : _buildGlassIconButton(
              icon: Icons.image_rounded,
              onPressed: _pickImageFromGallery,
              isPrimary: true,
            ),
    );
  }

  Widget _buildGlassIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(isPrimary ? 22.0 : 18.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          width: isPrimary ? 64 : 56,
          height: isPrimary ? 64 : 56,
          decoration: BoxDecoration(
            color: isPrimary
                ? clsColors.linkBlue.withValues(alpha: 0.3)
                : clsColors.cardBackground.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(isPrimary ? 22.0 : 18.0),
            border: Border.all(color: clsColors.secondaryText.withValues(alpha: 0.1)),
          ),
          child: IconButton(
            icon: Icon(icon, color: clsColors.primaryText),
            onPressed: onPressed,
            iconSize: isPrimary ? 28 : 24,
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedScanLine(Rect scanWindow) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Positioned(
          top:
              scanWindow.top + (scanWindow.height * _animationController.value),
          left: scanWindow.left,
          child: Container(
            width: scanWindow.width,
            height: 3,
            decoration: BoxDecoration(
              gradient: clsColors.buttonGradient,
              boxShadow: [
                BoxShadow(
                  color: clsColors.gradientEnd.withValues(alpha: 0.7),
                  blurRadius: 8.0,
                  spreadRadius: 2.0,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  final Rect scanWindow;
  _ScannerOverlayPainter({required this.scanWindow});

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(scanWindow, const Radius.circular(24)),
      );

    final overlayPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    final paint = Paint()
      ..color = clsColors.background.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    canvas.drawPath(overlayPath, paint);

    final borderPaint = Paint()
      ..color = clsColors.linkBlue.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    const cornerLength = 30.0;
    final roundedRect = RRect.fromRectAndRadius(
      scanWindow,
      const Radius.circular(24),
    );

    Path cornerPath = Path()
      ..moveTo(roundedRect.left, roundedRect.top + cornerLength)
      ..lineTo(roundedRect.left, roundedRect.top + roundedRect.tlRadiusY)
      ..arcToPoint(
        Offset(roundedRect.left + roundedRect.tlRadiusX, roundedRect.top),
        radius: roundedRect.tlRadius,
      )
      ..lineTo(roundedRect.left + cornerLength, roundedRect.top)
      ..moveTo(roundedRect.right - cornerLength, roundedRect.top)
      ..lineTo(roundedRect.right - roundedRect.trRadiusX, roundedRect.top)
      ..arcToPoint(
        Offset(roundedRect.right, roundedRect.top + roundedRect.trRadiusY),
        radius: roundedRect.trRadius,
      )
      ..lineTo(roundedRect.right, roundedRect.top + cornerLength)
      ..moveTo(roundedRect.right, roundedRect.bottom - cornerLength)
      ..lineTo(roundedRect.right, roundedRect.bottom - roundedRect.brRadiusY)
      ..arcToPoint(
        Offset(roundedRect.right - roundedRect.brRadiusX, roundedRect.bottom),
        radius: roundedRect.brRadius,
      )
      ..lineTo(roundedRect.right - cornerLength, roundedRect.bottom)
      ..moveTo(roundedRect.left + cornerLength, roundedRect.bottom)
      ..lineTo(roundedRect.left + roundedRect.blRadiusX, roundedRect.bottom)
      ..arcToPoint(
        Offset(roundedRect.left, roundedRect.bottom - roundedRect.blRadiusY),
        radius: roundedRect.blRadius,
      )
      ..lineTo(roundedRect.left, roundedRect.bottom - cornerLength);

    canvas.drawPath(cornerPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
