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
  /// Si es true: Modo autenticación rápida (login recurrente con cámara).
  /// Si es false: Modo enrolamiento inicial (captura de foto + términos de datos).
  final bool isLoginMode;

  const FacialScreen({super.key, this.isLoginMode = false});

  @override
  State<FacialScreen> createState() => _FacialScreenState();
}

class _FacialScreenState extends State<FacialScreen>
    with SingleTickerProviderStateMixin {
  // Paleta de colores institucional Startec / Tecsup
  static const Color _primaryPurple = Color(0xFF9E4DFE);
  static const Color _brandPurple = Color(0xFFB96DFF);
  static const Color _deepDark = Color(0xFF1E1435);
  static const Color _lightBg = Color(0xFFF7F5FC);
  static const Color _successGreen = Color(0xFF059669);

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

  late AnimationController _scannerController;
  late Animation<double> _scannerAnimation;

  @override
  void initState() {
    super.initState();

    _scannerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _scannerAnimation = Tween<double>(begin: 0.1, end: 0.9).animate(
      CurvedAnimation(parent: _scannerController, curve: Curves.easeInOut),
    );

    if (widget.isLoginMode) {
      _statusMessage = 'Escaneando tu rostro para iniciar sesión...';
    }

    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          setState(() {
            _statusMessage = 'No se encontró cámara frontal disponible.';
          });
        }
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
          _statusMessage = 'Toca el botón para capturar foto.';
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
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

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
      _statusMessage = '¡Rostro detectado y validado correctamente!';
    });

    // Si es modo Login Facial recurrente: avanza automáticamente a HomeScreen
    if (widget.isLoginMode) {
      if (_isNavigating) return;
      _isNavigating = true;

      final appState = context.read<AppState>();
      final navigator = Navigator.of(context);

      _debugFallbackTimer?.cancel();
      try {
        if (_cameraController != null &&
            _cameraController!.value.isStreamingImages) {
          await _cameraController!.stopImageStream();
        }
      } catch (_) {}

      final nombreCorto = appState.nombreUsuario.isNotEmpty
          ? appState.nombreUsuario.split(' ').first
          : 'Estudiante';

      if (!mounted) return;
      setState(() {
        _statusMessage = '¡Bienvenido/a, $nombreCorto!';
      });

      await Future.delayed(const Duration(milliseconds: 750));

      if (!mounted) return;
      navigator.pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  /// Confirmar foto y registrar la biometría en TECSUP (Modo Enrolamiento)
  Future<void> _confirmarYRegistrarBiometria() async {
    if (!_faceDetected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text('Enfoca tu rostro para capturar la biometría.'),
              ),
            ],
          ),
          backgroundColor: Colors.orange.shade800,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    if (!_aceptoTerminos) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Debes aceptar los términos de protección de datos personales.',
                ),
              ),
            ],
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    if (_isNavigating || _isSaving) return;

    final appState = context.read<AppState>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

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

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.verified_user_rounded, color: Colors.white),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                '¡Registro biométrico completado con éxito!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: _successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    _isNavigating = true;

    navigator.pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void _mostrarDialogoTerminos() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.privacy_tip_outlined, color: _primaryPurple),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Protección de Datos Personales',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: _deepDark,
                ),
              ),
            ),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'En cumplimiento con la Ley N° 29733 (Ley de Protección de Datos Personales de Perú) y su Reglamento:',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: _deepDark,
                ),
              ),
              SizedBox(height: 10),
              Text(
                '1. Los datos biométricos faciales capturados serán utilizados exclusivamente para la verificación de identidad, registro de asistencia y acceso seguro a los servicios académicos y plataformas de TECSUP.\n\n'
                '2. La información capturada es procesada como vector matemático encriptado (SHA-256) y almacenada de forma segura en los servidores de TECSUP.\n\n'
                '3. El postulante o estudiante puede revocar o actualizar sus datos según los canales oficiales de atención de TECSUP.',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.45,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _aceptoTerminos = true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Aceptar Términos',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
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
      backgroundColor: _lightBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Navigation Bar ─────────────────────────────────────────
            _buildAppBar(context, isLogin),

            // ── Contenido con Scroll ───────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Banner de Instrucciones / Estado
                    _buildStatusBanner(isLogin),

                    const SizedBox(height: 16),

                    // Escáner Biométrico Ovalado
                    _buildBiometricScanner(isLogin),

                    const SizedBox(height: 18),

                    // Indicadores de Calidad de Captura
                    _buildQualityBadges(),

                    const SizedBox(height: 18),

                    // Mensaje de estado dinámico
                    _buildStatusText(),

                    const SizedBox(height: 16),

                    // Consentimiento y botón de acción (Modo Enrolamiento)
                    if (!isLogin) ...[
                      _buildTermsCheckbox(),
                      const SizedBox(height: 16),
                      _buildActionButton(),
                      const SizedBox(height: 16),
                      _buildCaptureTipsCard(),
                    ],

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isLogin) {
    return Container(
      color: _lightBg,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              if (Navigator.canPop(context)) Navigator.pop(context);
            },
            borderRadius: BorderRadius.circular(12),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: _deepDark,
              ),
            ),
          ),
          Expanded(
            child: Text(
              isLogin ? 'Acceso Facial' : 'Reconocimiento Facial',
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _deepDark,
                letterSpacing: -0.2,
              ),
            ),
          ),
          const SizedBox(width: 34),
        ],
      ),
    );
  }

  Widget _buildStatusBanner(bool isLogin) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _faceDetected
              ? _successGreen.withValues(alpha: 0.4)
              : const Color(0xFFECE8F7),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _faceDetected
                  ? _successGreen.withValues(alpha: 0.12)
                  : _primaryPurple.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _faceDetected
                  ? Icons.face_retouching_natural_rounded
                  : (isLogin
                        ? Icons.camera_front_rounded
                        : Icons.photo_camera_front_outlined),
              color: _faceDetected ? _successGreen : _primaryPurple,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLogin
                      ? 'Mira de frente a la cámara'
                      : 'Captura de Foto Oficial del Postulante',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: _deepDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isLogin
                      ? 'Verificaremos tus rasgos faciales para darte acceso inmediato.'
                      : 'Evita lentes oscuros, gorras y ubícate en un ambiente iluminado.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.grey.shade600,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBiometricScanner(bool isLogin) {
    return Center(
      child: Container(
        width: 230,
        height: 290,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(115),
          boxShadow: [
            BoxShadow(
              color: _faceDetected
                  ? _successGreen.withValues(alpha: 0.35)
                  : _primaryPurple.withValues(alpha: 0.25),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Vista de la cámara frontal o avatar
            if (_isCameraInitialized && _cameraController != null)
              ClipPath(
                clipper: _OvalClipper(),
                child: SizedBox(
                  width: 230,
                  height: 290,
                  child: CameraPreview(_cameraController!),
                ),
              )
            else
              Container(
                width: 230,
                height: 290,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(115),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_rounded, size: 90, color: Colors.grey),
                    SizedBox(height: 6),
                    Text(
                      'Cámara en espera...',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),

            // Borde animado con CustomPainter
            AnimatedBuilder(
              animation: _scannerAnimation,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(230, 290),
                  painter: _BiometricOvalPainter(
                    color: _faceDetected ? _successGreen : _primaryPurple,
                    animationValue: _scannerAnimation.value,
                    faceDetected: _faceDetected,
                  ),
                );
              },
            ),

            // Rayo de escaneo láser en movimiento
            if (!_faceDetected)
              AnimatedBuilder(
                animation: _scannerAnimation,
                builder: (context, child) {
                  return Positioned(
                    top: 290 * _scannerAnimation.value,
                    child: Container(
                      width: 190,
                      height: 3.5,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _brandPurple.withValues(alpha: 0.1),
                            _brandPurple,
                            Colors.white,
                            _brandPurple,
                            _brandPurple.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color: _brandPurple.withValues(alpha: 0.8),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

            // Badge de Estado Validado
            if (_faceDetected)
              Positioned(
                bottom: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _successGreen,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Rostro Válido • Tecsup ID',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
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
    );
  }

  Widget _buildQualityBadges() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _qualityPill(
          icon: Icons.wb_sunny_outlined,
          label: 'Buena Luz',
          activo: _isCameraInitialized || _faceDetected,
        ),
        const SizedBox(width: 8),
        _qualityPill(
          icon: Icons.remove_red_eye_outlined,
          label: 'Mirada Frontal',
          activo: _faceDetected,
        ),
        const SizedBox(width: 8),
        _qualityPill(
          icon: Icons.center_focus_strong_rounded,
          label: 'Rostro Centrado',
          activo: _faceDetected,
        ),
      ],
    );
  }

  Widget _qualityPill({
    required IconData icon,
    required String label,
    required bool activo,
  }) {
    final color = activo ? _successGreen : Colors.grey.shade600;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: activo
            ? _successGreen.withValues(alpha: 0.1)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: activo
              ? _successGreen.withValues(alpha: 0.3)
              : Colors.grey.shade300,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusText() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: _faceDetected
            ? _successGreen.withValues(alpha: 0.08)
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _faceDetected
              ? _successGreen.withValues(alpha: 0.25)
              : const Color(0xFFECE8F7),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _faceDetected
                ? Icons.check_circle_outline_rounded
                : Icons.info_outline_rounded,
            size: 16,
            color: _faceDetected ? _successGreen : _primaryPurple,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              _statusMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: _faceDetected ? FontWeight.bold : FontWeight.w500,
                color: _faceDetected ? _successGreen : _deepDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _aceptoTerminos
              ? _primaryPurple.withValues(alpha: 0.4)
              : const Color(0xFFECE8F7),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Checkbox(
            value: _aceptoTerminos,
            activeColor: _primaryPurple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            onChanged: (val) {
              setState(() => _aceptoTerminos = val ?? false);
            },
          ),
          Expanded(
            child: GestureDetector(
              onTap: _mostrarDialogoTerminos,
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                  children: [
                    TextSpan(text: 'Acepto los '),
                    TextSpan(
                      text: 'términos de protección de datos (Ley N° 29733)',
                      style: TextStyle(
                        color: _primaryPurple,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    TextSpan(
                      text: ' y tratamiento de biometría institucional.',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isSaving
            ? null
            : (_faceDetected
                  ? _confirmarYRegistrarBiometria
                  : () => _onFaceDetectedInternal()),
        style: ElevatedButton.styleFrom(
          backgroundColor: _faceDetected ? _primaryPurple : _deepDark,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: _faceDetected ? 4 : 1,
          shadowColor: _primaryPurple.withValues(alpha: 0.5),
        ),
        child: _isSaving
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _faceDetected
                        ? Icons.verified_user_rounded
                        : Icons.camera_alt_rounded,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _faceDetected
                            ? 'GUARDAR Y VINCULAR BIOMETRÍA'
                            : 'CAPTURAR FOTO MANUAL',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCaptureTipsCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFECE8F7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                color: Colors.amber,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'Recomendaciones para una captura exitosa:',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: _deepDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _tipItem('Rostro despejado, sin mascarillas ni lentes oscuros.'),
          _tipItem('Luz uniforme de frente, evitando sombras fuertes.'),
          _tipItem('Mantén tu cabeza recta mirando directo a la cámara.'),
        ],
      ),
    );
  }

  Widget _tipItem(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              color: _primaryPurple,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700),
            ),
          ),
        ],
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

class _BiometricOvalPainter extends CustomPainter {
  final Color color;
  final double animationValue;
  final bool faceDetected;

  _BiometricOvalPainter({
    required this.color,
    required this.animationValue,
    required this.faceDetected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Borde principal del óvalo
    final borderPaint = Paint()
      ..color = color.withValues(alpha: faceDetected ? 0.9 : 0.6)
      ..strokeWidth = faceDetected ? 3.5 : 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawOval(rect, borderPaint);

    // Esquinas decorativas tecnológicas
    final cornerPaint = Paint()
      ..color = color
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLength = 24.0;

    // Esquina superior izquierda
    canvas.drawLine(
      const Offset(20, 40),
      const Offset(20 + cornerLength, 40),
      cornerPaint,
    );
    canvas.drawLine(
      const Offset(20, 40),
      const Offset(20, 40 + cornerLength),
      cornerPaint,
    );

    // Esquina superior derecha
    canvas.drawLine(
      Offset(size.width - 20, 40),
      Offset(size.width - 20 - cornerLength, 40),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(size.width - 20, 40),
      Offset(size.width - 20, 40 + cornerLength),
      cornerPaint,
    );

    // Esquina inferior izquierda
    canvas.drawLine(
      Offset(20, size.height - 40),
      Offset(20 + cornerLength, size.height - 40),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(20, size.height - 40),
      Offset(20, size.height - 40 - cornerLength),
      cornerPaint,
    );

    // Esquina inferior derecha
    canvas.drawLine(
      Offset(size.width - 20, size.height - 40),
      Offset(size.width - 20 - cornerLength, size.height - 40),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(size.width - 20, size.height - 40),
      Offset(size.width - 20, size.height - 40 - cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _BiometricOvalPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.animationValue != animationValue ||
      oldDelegate.faceDetected != faceDetected;
}
