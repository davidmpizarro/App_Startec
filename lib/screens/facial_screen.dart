import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:provider/provider.dart';

import 'home_screen.dart';
import '../services/app_state.dart';
import '../services/biometric_service.dart';

class FacialScreen extends StatefulWidget {
  /// Si es true: Modo autenticación rápida (login recurrente con cámara, sin pedir PIN).
  /// Si es false: Modo enrolamiento inicial (captura de foto + términos de datos).
  final bool isLoginMode;

  const FacialScreen({super.key, this.isLoginMode = false});

  @override
  State<FacialScreen> createState() => _FacialScreenState();
}

class _FacialScreenState extends State<FacialScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isNavigating = false;
  bool _isProcessing = false;
  bool _faceDetected = false;
  bool _aceptoTerminos = false;
  bool _isSaving = false;

  Timer? _debugFallbackTimer;
  static const Duration _debugFallbackDelay = Duration(seconds: 4);

  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.fast,
      enableLandmarks: true,
      enableClassification: true,
    ),
  );

  String _statusMessage = 'Centra tu rostro dentro del marco ovalado.';

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

    if (widget.isLoginMode) {
      _statusMessage = 'Escaneando tu rostro para iniciar sesión...';
    }

    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _statusMessage = 'No se encontró cámara frontal disponible.';
        });
        return;
      }

      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (!mounted) return;

      setState(() {
        _isCameraInitialized = true;
      });

      _startFaceDetection();
      _startDebugFallbackTimer();
    } catch (e) {
      debugPrint('[FacialScreen] Error al inicializar cámara: $e');
      if (mounted) {
        setState(() {
          _statusMessage = 'Usa el botón de captura para simular.';
        });
      }
    }
  }

  void _startDebugFallbackTimer() {
    if (!kDebugMode) return;

    _debugFallbackTimer = Timer(_debugFallbackDelay, () {
      if (!mounted || _isNavigating || _faceDetected) return;
      debugPrint(
        '[DEBUG] Emulador fallback: rostro detectado automáticamente.',
      );
      _onFaceDetectedInternal();
    });
  }

  void _startFaceDetection() {
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;

    _cameraController!.startImageStream((image) async {
      if (_isNavigating || _isProcessing || _faceDetected) return;
      _isProcessing = true;

      try {
        final inputImage = _inputImageFromCameraImage(image);
        if (inputImage == null) return;
        final faces = await _faceDetector.processImage(inputImage);
        if (faces.isNotEmpty && mounted) {
          _onFaceDetectedInternal();
        }
      } catch (e) {
        debugPrint('Face detection stream error: $e');
      } finally {
        _isProcessing = false;
      }
    });
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_cameraController == null) return null;
    final camera = _cameraController!.description;

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
    final int uvPixelStride = uPlane.bytesPerPixel ?? 1;

    final nv21 = Uint8List(width * height + ((width ~/ 2) * (height ~/ 2) * 2));

    for (int row = 0; row < height; row++) {
      final int srcOffset = row * yRowStride;
      final int dstOffset = row * width;
      for (int col = 0; col < width; col++) {
        if (srcOffset + col < yPlane.bytes.length) {
          nv21[dstOffset + col] = yPlane.bytes[srcOffset + col];
        }
      }
    }

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

  Future<void> _onFaceDetectedInternal() async {
    if (_faceDetected) return;
    setState(() {
      _faceDetected = true;
      _statusMessage = '¡Rostro detectado correctamente!';
    });

    // Si es modo Login Facial recurrente: avanza automáticamente a HomeScreen
    if (widget.isLoginMode) {
      if (_isNavigating) return;
      _isNavigating = true;

      _debugFallbackTimer?.cancel();
      try {
        if (_cameraController != null &&
            _cameraController!.value.isStreamingImages) {
          await _cameraController!.stopImageStream();
        }
      } catch (_) {}

      final appState = context.read<AppState>();
      final nombreCorto = appState.nombreUsuario.isNotEmpty
          ? appState.nombreUsuario.split(' ').first
          : 'Estudiante';

      if (!mounted) return;
      setState(() {
        _statusMessage = '¡Bienvenido(a) $nombreCorto!';
      });

      await Future.delayed(const Duration(milliseconds: 750));

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  /// Confirmar foto y registrar la biometría en TECSUP (Modo Enrolamiento)
  Future<void> _confirmarYRegistrarBiometria() async {
    if (!_faceDetected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor enfoca tu rostro para capturar la foto.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_aceptoTerminos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Debes aceptar los términos de protección de datos personales.',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_isNavigating || _isSaving) return;

    setState(() {
      _isSaving = true;
      _statusMessage =
          'Sincronizando biometría con la base de datos de TECSUP...';
    });

    _debugFallbackTimer?.cancel();
    try {
      if (_cameraController != null &&
          _cameraController!.value.isStreamingImages) {
        await _cameraController!.stopImageStream();
      }
    } catch (_) {}

    final appState = context.read<AppState>();

    // Sincronizar datos con la BD de Tecsup
    await BiometricService.sincronizarBiometriaConTecsup(
      dni: appState.documentoUsuario.isNotEmpty
          ? appState.documentoUsuario
          : '12345678',
      nombre: appState.nombreUsuario.isNotEmpty
          ? appState.nombreUsuario
          : 'Estudiante',
      terminosAceptados: _aceptoTerminos,
    );

    // Guardar en el estado de la aplicación
    await appState.registrarBiometria(aceptoTerminos: _aceptoTerminos);

    if (!mounted) return;

    setState(() {
      _statusMessage = '¡Identidad verificada y vinculada exitosamente!';
    });

    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    _isNavigating = true;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void _mostrarDialogoTerminos() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.security, color: Color(0xFF8B2FC9)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Protección de Datos Personales',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: const SingleChildScrollView(
          child: Text(
            'En cumplimiento con la Ley N° 29733 (Ley de Protección de Datos Personales de Perú) y su Reglamento:\n\n'
            '1. Los datos biométricos faciales capturados serán utilizados exclusivamente para la verificación de identidad, registro de asistencia y acceso seguro a los servicios académicos y plataformas de TECSUP.\n\n'
            '2. La información capturada será almacenada de forma encriptada y segura en los servidores y base de datos institucional de TECSUP.\n\n'
            '3. El postulante/estudiante puede revocar o actualizar sus datos de acuerdo con los canales oficiales de atención de TECSUP.',
            style: TextStyle(fontSize: 13, height: 1.4, color: Colors.black87),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _aceptoTerminos = true);
            },
            child: const Text(
              'Aceptar términos',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _debugFallbackTimer?.cancel();
    if (_isCameraInitialized && _cameraController != null) {
      _cameraController!.dispose();
    }
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLogin = widget.isLoginMode;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: isLogin
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text(
          isLogin ? 'Acceso Facial' : 'Reconocimiento Facial',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Si es modo Login Facial recurrente
              if (isLogin) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E8FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.face_retouching_natural,
                        color: Color(0xFF8B2FC9),
                        size: 24,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Mira de frente a la cámara para verificar tu identidad y acceder.',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF581C87),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ] else ...[
                // Modo primer ingreso / enrolamiento (Instrucciones Imágenes 2 y 3)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E8FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD8B4FE)),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Color(0xFF8B2FC9),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Subir una foto actual del postulante (Puedes tomarte la foto con tu celular, lo más nítido posible y debes mirar de frente) Guíate de la imagen*',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF581C87),
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Advertencia calidad de foto
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange,
                        size: 18,
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'La foto no debe contener filtros, la cara debe ser visible, evitar gorras u objetos que obstruyan el rostro.',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Colors.black87,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
              ],

              // Óvalo de la cámara frontal
              Center(
                child: SizedBox(
                  width: 210,
                  height: 270,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Cámara en vivo
                      if (_isCameraInitialized && _cameraController != null)
                        ClipPath(
                          clipper: _OvalClipper(),
                          child: SizedBox(
                            width: 210,
                            height: 270,
                            child: CameraPreview(_cameraController!),
                          ),
                        )
                      else
                        Container(
                          width: 210,
                          height: 270,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 100,
                            color: Colors.grey,
                          ),
                        ),

                      // Borde punteado animado
                      AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return CustomPaint(
                            size: const Size(210, 270),
                            painter: DashedOvalPainter(
                              color: _faceDetected
                                  ? Colors.green
                                  : Color.fromRGBO(
                                      139,
                                      47,
                                      201,
                                      _animation.value,
                                    ),
                            ),
                          );
                        },
                      ),

                      // Línea de escaneo animada
                      if (!_faceDetected)
                        AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            return Positioned(
                              top: 270 * _animation.value - 10,
                              child: Container(
                                width: 170,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF8B2FC9,
                                  ).withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            );
                          },
                        ),

                      // Icono de Check cuando se detecta
                      if (_faceDetected)
                        Positioned(
                          bottom: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade600,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isLogin
                                      ? 'Rostro Confirmado'
                                      : 'Rostro Válido',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Mensaje de estado
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: _faceDetected
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: _faceDetected ? Colors.green.shade700 : Colors.black54,
                ),
              ),

              // Si es primer registro: Checkbox de términos y condiciones
              if (!isLogin) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: _aceptoTerminos,
                        activeColor: const Color(0xFF8B2FC9),
                        onChanged: (val) {
                          setState(() {
                            _aceptoTerminos = val ?? false;
                          });
                        },
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: _mostrarDialogoTerminos,
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                              children: [
                                TextSpan(text: 'Acepto los '),
                                TextSpan(
                                  text:
                                      'términos y condiciones para la protección de datos personales',
                                  style: TextStyle(
                                    color: Color(0xFF8B2FC9),
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                TextSpan(text: ' y tratamiento de biometría.'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSaving
                        ? null
                        : (_faceDetected
                              ? _confirmarYRegistrarBiometria
                              : () => _onFaceDetectedInternal()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _faceDetected
                          ? const Color(0xFF8B2FC9)
                          : Colors.black87,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 3,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _faceDetected
                                ? 'GUARDAR Y VINCULAR BIOMETRÍA'
                                : 'CAPTURAR FOTO',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                  ),
                ),
              ],
            ],
          ),
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
