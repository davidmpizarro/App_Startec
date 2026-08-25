import 'dart:math';
import 'package:flutter/material.dart';
import 'package:startec/screens/document_upload_screen.dart';
import 'package:startec/screens/dashboard_screen.dart';
import 'package:startec/screens/confirmacion_matricula_screen.dart';
import 'package:startec/screens/pasarela_pagos_screen.dart';
import 'package:startec/screens/pagomatricula_screen.dart';
import 'profile_screen.dart';
import 'career_screen.dart';
import 'home_screen.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../widgets/app_drawer.dart';

class _StepData {
  final String label;
  final bool completed;
  final bool available;
  final Widget? destino;
  final String? mensajeBloqueo;
  final bool labelOnTop;

  _StepData({
    required this.label,
    required this.completed,
    required this.available,
    this.destino,
    this.mensajeBloqueo,
    this.labelOnTop = false,
  });
}

class RoadmapScreen extends StatelessWidget {
  const RoadmapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 👈 en vez de MainScaffold
      drawer: const AppDrawer(), // 👈 mismo drawer, sin barra inferior
      backgroundColor: const Color(0xFF9E4DFE),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFA259FF), Color(0xFF8B35EA), Color(0xFF751FD6)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    Material(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: const CircleBorder(),
                      child: Builder(
                        builder: (context) => InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => Scaffold.of(context).openDrawer(),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.menu_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Título institucional premium
              const Text(
                '¡Inicia tu experiencia\nen Tecsup!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                  color: Colors.white,
                  height: 1.2,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              // Roadmap interactivo con curvas suaves y adaptables
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final availableH = constraints.maxHeight;
                    // Altura óptima para dar respiro y curvatura natural al camino
                    final totalH = max(availableH, 760.0);
                    final w = constraints.maxWidth;
                    final leftPos = (w * 0.13) - 27;
                    final rightPos = (w * 0.87) - 27;
                    final state = context.watch<AppState>();

                    final pasos = <_StepData>[
                      _StepData(
                        label: 'Bienvenida',
                        completed: state.paso1Bienvenida,
                        available: true,
                        destino: const HomeScreen(),
                        labelOnTop: true,
                      ),
                      _StepData(
                        label: 'Actualiza tu perfil',
                        completed: state.paso2Perfil,
                        available: true,
                        destino: const ProfileScreen(),
                      ),
                      _StepData(
                        label: 'Carga tus\ndocumentos',
                        completed: state.paso3Documentos,
                        available: state.paso2Perfil,
                        destino: const DocumentUploadScreen(),
                        mensajeBloqueo:
                            'Primero completa "Actualiza tu perfil"',
                      ),
                      _StepData(
                        label: 'Pago de\nMatrícula',
                        completed: state.paso4PagoMatricula,
                        available: state.paso3Documentos,
                        destino: const PagoMatriculaScreen(),
                        mensajeBloqueo:
                            'Primero completa "Carga tus documentos"',
                      ),
                      _StepData(
                        label: 'Pasarela de\npagos',
                        completed: state.paso5Pasarela,
                        available: state.paso4PagoMatricula,
                        destino: const PasarelaPagosScreen(),
                        mensajeBloqueo: 'Primero completa "Pago de Matrícula"',
                      ),
                      _StepData(
                        label: 'Confirmación de\nmatrícula',
                        completed: state.paso6Confirmacion,
                        available: state.paso5Pasarela,
                        destino: const ConfirmacionMatriculaScreen(),
                        mensajeBloqueo: 'Primero completa "Pasarela de pagos"',
                      ),
                      _StepData(
                        label: 'Conoce tu\ncarrera',
                        completed: state.paso7Carrera,
                        available: state.paso6Confirmacion,
                        destino: const CareerScreen(),
                        mensajeBloqueo:
                            'Primero completa "Confirmación de matrícula"',
                      ),
                      _StepData(
                        label: 'Conquista el\ncampus',
                        completed: state.paso8Campus,
                        available: state.paso7Carrera,
                        destino: const DashboardScreen(),
                        mensajeBloqueo: 'Primero completa "Conoce tu carrera"',
                      ),
                    ];

                    final borderColors = [
                      const Color(0xFF0F28B4), // Azul Tecsup
                      const Color(0xFF00BCD4), // Cyan Tech
                      const Color(0xFF028090), // Teal Esmeralda
                      const Color(0xFFFFB703), // Ámbar dorado
                      const Color(0xFFFB8500), // Naranja Coral
                      const Color(0xFF2EC4B6), // Verde Éxito
                      const Color(0xFFE056FD), // Rosa Magenta
                      const Color(0xFF48CAE4), // Azul Cielo
                    ];

                    final n = pasos.length;
                    const startFrac = 0.04;
                    const endFrac = 0.84;
                    final yFractions = List<double>.generate(
                      n,
                      (i) => startFrac + i * ((endFrac - startFrac) / (n - 1)),
                    );

                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 480),
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 40,
                              ), // espacio para que "Bienvenida" no se recorte
                              SizedBox(
                                width: w,
                                height: totalH,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    CustomPaint(
                                      size: Size(w, totalH),
                                      painter: RoadPainter(
                                        pointCount: n,
                                        startFraction: startFrac,
                                        endFraction: endFrac,
                                      ),
                                    ),
                                    for (int i = 0; i < n; i++)
                                      _buildStep(
                                        context: context,
                                        left: i.isEven ? leftPos : rightPos,
                                        top: totalH * yFractions[i] - 27,
                                        paso: pasos[i],
                                        borderColor:
                                            borderColors[i %
                                                borderColors.length],
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep({
    required BuildContext context,
    required double left,
    required double top,
    required _StepData paso,
    required Color borderColor,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onTap: () {
          if (!paso.available) {
            if (paso.mensajeBloqueo != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(paso.mensajeBloqueo!),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }
            return;
          }
          if (paso.destino != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => paso.destino!),
            );
          }
        },
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            _circle(borderColor, paso.completed, paso.available),
            if (paso.labelOnTop)
              Positioned(
                bottom: 58,
                left: -48,
                width: 150,
                child: _label(paso.label, TextAlign.center),
              )
            else
              Positioned(
                top: 58,
                left: -48,
                width: 150,
                child: _label(paso.label, TextAlign.center),
              ),
          ],
        ),
      ),
    );
  }

  Widget _circle(Color borderColor, bool completed, bool available) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
          if (available && !completed)
            BoxShadow(
              color: borderColor.withValues(alpha: 0.45),
              blurRadius: 12,
              spreadRadius: 2,
            ),
        ],
        border: Border.all(
          color: completed
              ? const Color(0xFF22C55E)
              : available
              ? borderColor
              : Colors.grey.shade400,
          width: 4.5,
        ),
      ),
      child: Center(
        child: completed
            ? const Icon(
                Icons.check_rounded,
                color: Color(0xFF22C55E),
                size: 30,
              )
            : !available
            ? Icon(Icons.lock_rounded, color: Colors.grey.shade400, size: 22)
            : Icon(Icons.play_arrow_rounded, color: borderColor, size: 28),
      ),
    );
  }

  Widget _label(String text, TextAlign align) {
    return Text(
      text,
      textAlign: align,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
        shadows: [
          Shadow(blurRadius: 4, color: Colors.black54, offset: Offset(0, 1.5)),
        ],
      ),
    );
  }
}

class RoadPainter extends CustomPainter {
  final int pointCount;
  final double startFraction;
  final double endFraction;

  RoadPainter({
    required this.pointCount,
    this.startFraction = 0.04,
    this.endFraction = 0.84,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double radius = 46.0;

    final double leftX = w * 0.29;
    final double rightX = w * 0.71;

    final yFractions = List<double>.generate(
      pointCount,
      (i) =>
          startFraction +
          i * ((endFraction - startFraction) / (pointCount - 1)),
    );
    final ys = yFractions.map((f) => h * f).toList();

    // 1. Capa de Sombras Profundas
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.32)
      ..strokeWidth = 56
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    // 2. Capa Borde Izquierdo 3D (Luz directa)
    final borderLeftPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.82)
      ..strokeWidth = 46
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // 3. Capa Borde Derecho 3D (Reflejo suave)
    final borderRightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 40
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // 4. Superficie Asfáltica (Gris Carbón Tecnológico)
    final roadPaint = Paint()
      ..color = const Color(0xFF33353D)
      ..strokeWidth = 42
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // 5. Línea Central Discontinua
    final dashPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;

    final double lastX = (pointCount - 1).isEven ? leftX : rightX;
    final double lastY = ys.last;
    final double roadExtY = lastY + 16.0;
    final double arrowTipY = roadExtY + 38.0;
    const double roadHalfW = 21.0;
    const double arrowHalfW = 34.0;

    // Trazo de la autopista con curvas suaves
    final roadPath = Path();
    roadPath.moveTo(leftX, ys[0]);

    for (int i = 0; i < ys.length - 1; i++) {
      final double fromX = i.isEven ? leftX : rightX;
      final double toX = i.isEven ? rightX : leftX;
      final double midY = (ys[i] + ys[i + 1]) / 2;
      final double dir = (toX - fromX).sign;

      roadPath.lineTo(fromX, midY - radius);
      roadPath.quadraticBezierTo(fromX, midY, fromX + dir * radius, midY);
      roadPath.lineTo(toX - dir * radius, midY);
      roadPath.quadraticBezierTo(toX, midY, toX, midY + radius);
      roadPath.lineTo(toX, ys[i + 1]);
    }
    roadPath.lineTo(lastX, roadExtY);

    // Polígono de la Flecha de Destino
    final arrowHeadPath = Path()
      ..moveTo(lastX - roadHalfW, roadExtY)
      ..lineTo(lastX - arrowHalfW, roadExtY + 3)
      ..lineTo(lastX, arrowTipY)
      ..lineTo(lastX + arrowHalfW, roadExtY + 3)
      ..lineTo(lastX + roadHalfW, roadExtY)
      ..close();

    // Sombra de la flecha
    final arrowShadowPath = Path()
      ..moveTo(lastX - roadHalfW - 6, roadExtY)
      ..lineTo(lastX - arrowHalfW - 8, roadExtY + 5)
      ..lineTo(lastX, arrowTipY + 10)
      ..lineTo(lastX + arrowHalfW + 8, roadExtY + 5)
      ..lineTo(lastX + roadHalfW + 6, roadExtY)
      ..close();

    // --- DIBUJADO POR CAPAS ORDENADAS ---
    // Capa 1: Sombra
    canvas.drawPath(roadPath, shadowPaint);
    canvas.drawPath(
      arrowShadowPath,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.32)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // Capa 2: Borde 3D Izquierdo (Blanco Brillante)
    canvas.save();
    canvas.translate(-4, 0);
    canvas.drawPath(roadPath, borderLeftPaint);
    canvas.restore();

    final arrowLeftBorder = Path()
      ..moveTo(lastX - roadHalfW - 4, roadExtY)
      ..lineTo(lastX - arrowHalfW - 4, roadExtY + 3)
      ..lineTo(lastX - 1, arrowTipY + 1);
    canvas.drawPath(
      arrowLeftBorder,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.82)
        ..strokeWidth = 6.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );

    // Capa 3: Borde 3D Derecho (Translucidez de volumen)
    canvas.save();
    canvas.translate(4, 0);
    canvas.drawPath(roadPath, borderRightPaint);
    canvas.restore();

    final arrowRightBorder = Path()
      ..moveTo(lastX + roadHalfW + 4, roadExtY)
      ..lineTo(lastX + arrowHalfW + 4, roadExtY + 3)
      ..lineTo(lastX + 1, arrowTipY + 1);
    canvas.drawPath(
      arrowRightBorder,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..strokeWidth = 5.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );

    // Capa 4: Relleno de la Pista
    canvas.drawPath(roadPath, roadPaint);
    canvas.drawPath(
      arrowHeadPath,
      Paint()
        ..color = const Color(0xFF33353D)
        ..style = PaintingStyle.fill,
    );

    // Capa 5: Señalización Central Punteada
    _drawDashedPath(canvas, roadPath, dashPaint);
    final arrowDash = Path()
      ..moveTo(lastX, roadExtY)
      ..lineTo(lastX, arrowTipY - 14);
    canvas.drawPath(arrowDash, dashPaint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final extract = metric.extractPath(distance, distance + 11);
        canvas.drawPath(extract, paint);
        distance += 22;
      }
    }
  }

  @override
  bool shouldRepaint(covariant RoadPainter oldDelegate) =>
      oldDelegate.pointCount != pointCount ||
      oldDelegate.startFraction != startFraction ||
      oldDelegate.endFraction != endFraction;
}
