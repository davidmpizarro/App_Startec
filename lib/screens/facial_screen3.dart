import 'package:flutter/material.dart';
import 'home_screen.dart';

class FacialScreen extends StatefulWidget {
  const FacialScreen({super.key});

  @override
  State<FacialScreen> createState() => _FacialScreenState();
}

class _FacialScreenState extends State<FacialScreen>
    with SingleTickerProviderStateMixin {
  bool _isScanning = true;
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

    Future.delayed(const Duration(milliseconds: 800), () {
      _simulateScan();
    });
  }

  Future<void> _simulateScan() async {
    setState(() {
      _isScanning = true;
      _statusMessage = 'Verificando tu identidad...';
    });

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _statusMessage = 'Analizando rostro...';
    });

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _statusMessage = '¡Identidad verificada!';
      _isScanning = false;
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            const Text(
              'Reconocimiento facial',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const Spacer(),
            Center(
              child: SizedBox(
                width: 220,
                height: 300,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Óvalo punteado animado
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
                                    _isScanning ? _animation.value : 1.0,
                                  ),
                          ),
                        );
                      },
                    ),
                    // Línea de escaneo animada
                    if (_isScanning)
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
                    // Ícono
                    Icon(
                      _statusMessage == '¡Identidad verificada!'
                          ? Icons.check_circle
                          : Icons.person,
                      size: 140,
                      color: _statusMessage == '¡Identidad verificada!'
                          ? Colors.green
                          : Colors.grey.shade400,
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
