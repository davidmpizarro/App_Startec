import 'dart:async';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'home_screen.dart';
import 'dart:typed_data';

class FacialScreen extends StatefulWidget {
  const FacialScreen({super.key});

  @override
  State<FacialScreen> createState() => _FacialScreenState();
}

class _FacialScreenState extends State<FacialScreen>
    with SingleTickerProviderStateMixin {
  late CameraController _cameraController;
  bool _isCameraInitialized = false;

  // FIX 3: Usar una sola variable de control atómica
  // _isNavigating reemplaza a _isScanning para evitar doble navegación
  bool _isNavigating = false;
  bool _isProcessing = false;

  // FALLBACK DEBUG: timer que fuerza el avance si el emulador
  // no logra detectar un rostro tras N segundos (solo en debug).
  Timer? _debugFallbackTimer;
  static const Duration _debugFallbackDelay = Duration(seconds: 6);

  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(performanceMode: FaceDetectorMode.fast),
  );

  String _statusMessage =
      'Colócate en un lugar iluminado para validar tu identidad.';

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(_controller);

    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();

    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
    );

    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController.initialize();

    if (!mounted) return;

    setState(() {
      _isCameraInitialized = true;
    });

    _startFaceDetection();
    _startDebugFallbackTimer();
  }

  // FALLBACK DEBUG: si en modo debug (típicamente emulador con
  // cámara sintética poco confiable) no se detecta rostro en
  // _debugFallbackDelay, se avanza igual. En release nunca corre.
  void _startDebugFallbackTimer() {
    if (!kDebugMode) return;

    _debugFallbackTimer = Timer(_debugFallbackDelay, () {
      if (!mounted || _isNavigating) return;
      debugPrint(
        '[DEBUG] No se detectó rostro tras ${_debugFallbackDelay.inSeconds}s. '
        'Avanzando automáticamente (solo debug/emulador).',
      );
      _onFaceDetected();
    });
  }

  void _startFaceDetection() {
    _cameraController.startImageStream((image) async {
      // FIX 3: Guard consolidado — si ya estamos navegando o procesando, ignorar
      if (_isNavigating || _isProcessing) return;
      _isProcessing = true;

      try {
        final inputImage = _inputImageFromCameraImage(image);
        if (inputImage == null) return;
        final faces = await _faceDetector.processImage(inputImage);
        if (faces.isNotEmpty) await _onFaceDetected();
      } catch (e) {
        debugPrint('Face detection error: $e');
      } finally {
        _isProcessing = false;
      }
    });
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    final camera = _cameraController.description;

    // FIX 2: Rotación correcta considerando que es cámara frontal
    final rotation = _getImageRotation(
      camera.sensorOrientation,
      camera.lensDirection == CameraLensDirection.front,
    );

    final int width = image.width;
    final int height = image.height;

    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];

    final int yRowStride = yPlane.bytesPerRow;
    final int uvRowStride = uPlane.bytesPerRow;

    // FIX 1: Usar bytesPerPixel real del plano en lugar de calcularlo manualmente
    // En muchos Android es 2 (semi-planar NV12/NV21), no siempre 1
    final int uvPixelStride = uPlane.bytesPerPixel ?? 1;

    final nv21 = Uint8List(width * height + ((width ~/ 2) * (height ~/ 2) * 2));

    // Copiar plano Y respetando rowStride
    for (int row = 0; row < height; row++) {
      final int srcOffset = row * yRowStride;
      final int dstOffset = row * width;
      // Copiar solo 'width' bytes por fila (ignorar padding del stride)
      for (int col = 0; col < width; col++) {
        if (srcOffset + col < yPlane.bytes.length) {
          nv21[dstOffset + col] = yPlane.bytes[srcOffset + col];
        }
      }
    }

    // FIX 1: Intercalar V y U usando uvPixelStride y uvRowStride reales
    int uvIndex = width * height;
    for (int row = 0; row < height ~/ 2; row++) {
      for (int col = 0; col < width ~/ 2; col++) {
        final int uvOffset = row * uvRowStride + col * uvPixelStride;

        final bool vInBounds = uvOffset < vPlane.bytes.length;
        final bool uInBounds = uvOffset < uPlane.bytes.length;
        final bool dstInBounds = uvIndex + 1 < nv21.length;

        if (dstInBounds && vInBounds && uInBounds) {
          nv21[uvIndex++] = vPlane.bytes[uvOffset];
          nv21[uvIndex++] = uPlane.bytes[uvOffset];
        }
      }
    }

    return InputImage.fromBytes(
      bytes: nv21,
      metadata: InputImageMetadata(
        size: Size(width.toDouble(), height.toDouble()),
        rotation: rotation,
        format: InputImageFormat.nv21,
        bytesPerRow: width,
      ),
    );
  }

  // FIX 2: Rotación compensada para cámara frontal en Android
  // La cámara frontal invierte el eje horizontal, por lo que
  // 90° del sensor equivale a 270° efectivos para ML Kit
  InputImageRotation _getImageRotation(int sensorOrientation, bool isFront) {
    if (isFront) {
      switch (sensorOrientation) {
        case 90:
          return InputImageRotation.rotation270deg;
        case 270:
          return InputImageRotation.rotation90deg;
        case 180:
          return InputImageRotation.rotation180deg;
        default:
          return InputImageRotation.rotation0deg;
      }
    } else {
      switch (sensorOrientation) {
        case 90:
          return InputImageRotation.rotation90deg;
        case 180:
          return InputImageRotation.rotation180deg;
        case 270:
          return InputImageRotation.rotation270deg;
        default:
          return InputImageRotation.rotation0deg;
      }
    }
  }

  Future<void> _onFaceDetected() async {
    // FIX 3: Guard atómico — solo el primer llamado pasa
    if (_isNavigating) return;
    _isNavigating = true;

    _debugFallbackTimer?.cancel();

    try {
      await _cameraController.stopImageStream();
    } catch (e) {
      debugPrint('stopImageStream error: $e');
    }

    if (!mounted) return;

    setState(() {
      _statusMessage = '¡Identidad verificada!';
    });

    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _debugFallbackTimer?.cancel();

    // FIX 4: Solo hacer dispose de la cámara si fue inicializada
    if (_isCameraInitialized) {
      _cameraController.dispose();
    }

    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // _isScanning para la UI ahora se deriva de _isNavigating
    final bool isScanning = !_isNavigating;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            const Text(
              'Reconocimiento facial',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Center(
              child: SizedBox(
                width: 220,
                height: 300,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    /// Cámara
                    if (_isCameraInitialized)
                      ClipPath(
                        clipper: _OvalClipper(),
                        child: SizedBox(
                          width: 220,
                          height: 300,
                          child: CameraPreview(_cameraController),
                        ),
                      )
                    else
                      const CircularProgressIndicator(),

                    /// Óvalo animado
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return CustomPaint(
                          size: const Size(220, 300),
                          painter: DashedOvalPainter(
                            color: _statusMessage == '¡Identidad verificada!'
                                ? Colors.green
                                : Color.fromRGBO(
                                    139,
                                    47,
                                    201,
                                    isScanning ? _animation.value : 1.0,
                                  ),
                          ),
                        );
                      },
                    ),

                    /// Línea de escaneo
                    if (isScanning)
                      AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return Positioned(
                            top: 300 * _animation.value - 10,
                            child: Container(
                              width: 180,
                              height: 3,
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF8B2FC9,
                                ).withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          );
                        },
                      ),

                    /// Check final
                    if (!isScanning)
                      const Icon(
                        Icons.check_circle,
                        size: 120,
                        color: Colors.green,
                      ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: _statusMessage == '¡Identidad verificada!'
                      ? Colors.green
                      : Colors.black54,
                  fontWeight: _statusMessage == '¡Identidad verificada!'
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _OvalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) =>
      Path()..addOval(Rect.fromLTWH(0, 0, size.width, size.height));

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class DashedOvalPainter extends CustomPainter {
  final Color color;

  DashedOvalPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    const dashWidth = 10.0;
    const dashSpace = 6.0;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final path = Path()..addOval(rect);
    final metrics = path.computeMetrics().first;

    double distance = 0;

    while (distance < metrics.length) {
      final next = distance + dashWidth;

      canvas.drawPath(
        metrics.extractPath(distance, next.clamp(0, metrics.length)),
        paint,
      );

      distance += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant DashedOvalPainter oldDelegate) =>
      oldDelegate.color != color;
}
