import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'home_screen.dart';

class FacialScreen extends StatefulWidget {
  const FacialScreen({super.key});

  @override
  State<FacialScreen> createState() => _FacialScreenState();
}

class _FacialScreenState extends State<FacialScreen> {
  final LocalAuthentication _auth = LocalAuthentication();
  bool _isAuthenticating = false;
  String _statusMessage =
      'Colócate en un lugar iluminado para validar tu identidad.';

  @override
  void initState() {
    super.initState();
    // Inicia automáticamente al entrar a la pantalla
    Future.delayed(const Duration(milliseconds: 800), () {
      _authenticate();
    });
  }

  Future<void> _authenticate() async {
    setState(() {
      _isAuthenticating = true;
      _statusMessage = 'Verificando tu identidad...';
    });

    try {
      final bool canAuth = await _auth.canCheckBiometrics;
      if (!canAuth) {
        setState(() {
          _statusMessage = 'Este dispositivo no soporta biometría.';
          _isAuthenticating = false;
        });
        return;
      }

      final bool authenticated = await _auth.authenticate(
        localizedReason: 'Verifica tu identidad para continuar',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );

      if (authenticated && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        setState(() {
          _statusMessage = 'No se pudo verificar. Intenta de nuevo.';
          _isAuthenticating = false;
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error al verificar. Intenta de nuevo.';
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),

            // Título
            const Text(
              'Reconocimiento facial',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const Spacer(),

            // Óvalo punteado con ícono de persona
            Center(
              child: SizedBox(
                width: 220,
                height: 300,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Óvalo punteado
                    CustomPaint(
                      size: const Size(220, 300),
                      painter: DashedOvalPainter(
                        color: _isAuthenticating
                            ? const Color(0xFF8B2FC9)
                            : const Color(0xFF8B2FC9),
                      ),
                    ),
                    // Ícono persona
                    Icon(Icons.person, size: 140, color: Colors.grey.shade400),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Mensaje de estado
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: Colors.black54),
              ),
            ),

            const SizedBox(height: 24),

            // Botón reintentar (solo si falló)
            if (!_isAuthenticating)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _authenticate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B2FC9),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Intentar de nuevo',
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ),
              ),

            // Botón temporal para saltar en emulador
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              },
              child: const Text(
                'Saltar (solo emulador)',
                style: TextStyle(color: Colors.grey),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// Painter para el óvalo punteado
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
