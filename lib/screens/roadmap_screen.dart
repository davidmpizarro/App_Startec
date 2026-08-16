import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:startec/screens/courses_screen.dart';
import 'package:startec/screens/dashboard_screen.dart';
import 'package:startec/screens/payment_confirmed_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';
import 'career_screen.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

class RoadmapScreen extends StatelessWidget {
  const RoadmapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    // ✅ Agrega estas líneas
    final user = FirebaseAuth.instance.currentUser;
    final String nombre = user?.displayName ?? user?.email ?? 'Estudiante';
    final String nombreCorto = nombre.split(' ').first;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color.fromARGB(255, 185, 109, 255),

      // ✅ Drawer igual al HomeScreen
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              color: const Color.fromARGB(255, 185, 109, 255),
              child: SafeArea(
                child: Text(
                  'Hola, $nombreCorto',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            _drawerItem(Icons.assignment, 'Estado de Admisión', () {}),
            _drawerItem(Icons.folder, 'Documentos', () {}),
            _drawerItem(Icons.credit_card, 'Mis Pagos', () {}),
            _drawerItem(Icons.school, 'Explora Tecsup', () {}),
            _drawerItem(Icons.list_alt, 'Otros Trámites', () {}),
            _drawerItem(Icons.schedule, 'Mis Horarios', () {}),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Cerrar sesión',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                await GoogleSignIn().signOut();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            // Header con menú
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => scaffoldKey.currentState?.openDrawer(),
                    child: const Icon(
                      Icons.menu,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),

            // Título
            const Text(
              '¡Inicia tu experiencia\nen Tecsup!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            // Roadmap
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final h = constraints.maxHeight;
                        final w = constraints.maxWidth;
                        final leftPos = (w * 0.14) - 25;
                        final rightPos = (w * 0.86) - 25;
                        final state = context.watch<AppState>();
                        return Stack(
                          children: [
                            CustomPaint(
                              size: Size(w, h),
                              painter: RoadPainter(),
                            ),
                            _buildStep(
                              left: leftPos,
                              top: h * 0.10 - 25,
                              label: 'Bienvenida',
                              labelOnLeft: true,
                              labelOnTop: true,
                              borderColor: const Color.fromARGB(
                                255,
                                15,
                                40,
                                180,
                              ),
                              completed: state.paso1Bienvenida,
                              available: true,
                              onTap: () {},
                            ),
                            _buildStep(
                              left: rightPos,
                              top: h * 0.25 - 25,
                              label: 'Actualiza tu perfil',
                              labelOnLeft: false,
                              borderColor: const Color.fromARGB(
                                255,
                                8,
                                101,
                                189,
                              ),
                              completed: state.paso2Perfil,
                              available: true,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ProfileScreen(),
                                ),
                              ),
                            ),
                            _buildStep(
                              left: leftPos,
                              top: h * 0.40 - 25,
                              label: 'Carga tus\ndocumentos',
                              labelOnLeft: true,
                              borderColor: const Color(0xFF00BCD4),
                              completed: state.paso3Documentos,
                              available: state.paso2Perfil,
                              onTap: () {
                                if (!state.paso2Perfil) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Primero completa "Actualiza tu perfil"',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const CoursesScreen(),
                                  ),
                                );
                              },
                            ),
                            _buildStep(
                              left: rightPos,
                              top: h * 0.55 - 25,
                              label: 'Confirmación de\nmatrícula',
                              labelOnLeft: false,
                              borderColor: Colors.green,
                              completed: state.paso4Matricula,
                              available: state.paso3Documentos,
                              onTap: () {
                                if (!state.paso3Documentos) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Primero completa "Carga tus documentos"',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const PaymentConfirmedScreen(),
                                  ),
                                );
                              },
                            ),
                            _buildStep(
                              left: leftPos,
                              top: h * 0.70 - 25,
                              label: 'Conoce tu\ncarrera',
                              labelOnLeft: true,
                              borderColor: const Color.fromARGB(
                                255,
                                255,
                                158,
                                212,
                              ),
                              completed: state.paso5Carrera,
                              available: state.paso4Matricula,
                              onTap: () {
                                if (!state.paso4Matricula) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Primero completa "Confirmación de matrícula"',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const CareerScreen(),
                                  ),
                                );
                              },
                            ),
                            _buildStep(
                              left: rightPos,
                              top: h * 0.85 - 25,
                              label: 'Conquista el\ncampus',
                              labelOnLeft: false,
                              borderColor: const Color.fromARGB(
                                255,
                                103,
                                212,
                                255,
                              ),
                              completed: state.paso6Campus,
                              available: state.paso5Carrera,
                              onTap: () {
                                if (!state.paso5Carrera) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Primero completa "Conoce tu carrera"',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const DashboardScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep({
    required double left,
    required double top,
    required String label,
    required bool labelOnLeft,
    bool labelOnTop = false, // ← nuevo parámetro
    required Color borderColor,
    required bool completed,
    required bool available,
    required VoidCallback onTap,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            _circle(borderColor, completed, available),
            if (labelOnTop)
              Positioned(
                bottom: 58, // encima del círculo
                left: -42, // centrado
                width: 135,
                child: _label(label, TextAlign.center),
              )
            else
              Positioned(
                top: 58, // debajo del círculo
                left: -42, // centrado
                width: 135,
                child: _label(label, TextAlign.center),
              ),
          ],
        ),
      ),
    );
  }

  Widget _circle(Color borderColor, bool completed, bool available) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: completed
            ? Colors.green.shade100
            : available
            ? Colors.white
            : Colors.white.withValues(alpha: 0.4),
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
        border: Border.all(
          color: completed
              ? Colors.green
              : available
              ? borderColor
              : borderColor.withValues(alpha: 0.4),
          width: 4,
        ),
      ),
      child: completed
          ? const Icon(Icons.check, color: Colors.green, size: 26)
          : !available
          ? const Icon(Icons.lock, color: Colors.white54, size: 22)
          : null,
    );
  }

  Widget _label(String text, TextAlign align) {
    return Text(
      text,
      textAlign: align,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        shadows: [Shadow(blurRadius: 3, color: Colors.black45)],
      ),
    );
  }

  ListTile _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color.fromARGB(255, 185, 109, 255)),
      title: Text(title),
      onTap: onTap,
    );
  }
}

class RoadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double radius = 50.0;

    final double leftX = w * 0.30;
    final double rightX = w * 0.70;

    final double y1 = h * 0.10;
    final double y2 = h * 0.25;
    final double y3 = h * 0.40;
    final double y4 = h * 0.55;
    final double y5 = h * 0.70;
    final double y6 = h * 0.85;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..strokeWidth = 56
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final borderLeftPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..strokeWidth = 46
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final borderRightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 40
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final roadPaint = Paint()
      ..color = const Color(0xFF444444)
      ..strokeWidth = 42
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final dashPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(leftX, y1);

    // 1 → 2
    final double midY12 = (y1 + y2) / 2;
    path.lineTo(leftX, midY12 - radius);
    path.quadraticBezierTo(leftX, midY12, leftX + radius, midY12);
    path.lineTo(rightX - radius, midY12);
    path.quadraticBezierTo(rightX, midY12, rightX, midY12 + radius);
    path.lineTo(rightX, y2);

    // 2 → 3
    final double midY23 = (y2 + y3) / 2;
    path.lineTo(rightX, midY23 - radius);
    path.quadraticBezierTo(rightX, midY23, rightX - radius, midY23);
    path.lineTo(leftX + radius, midY23);
    path.quadraticBezierTo(leftX, midY23, leftX, midY23 + radius);
    path.lineTo(leftX, y3);

    // 3 → 4
    final double midY34 = (y3 + y4) / 2;
    path.lineTo(leftX, midY34 - radius);
    path.quadraticBezierTo(leftX, midY34, leftX + radius, midY34);
    path.lineTo(rightX - radius, midY34);
    path.quadraticBezierTo(rightX, midY34, rightX, midY34 + radius);
    path.lineTo(rightX, y4);

    // 4 → 5
    final double midY45 = (y4 + y5) / 2;
    path.lineTo(rightX, midY45 - radius);
    path.quadraticBezierTo(rightX, midY45, rightX - radius, midY45);
    path.lineTo(leftX + radius, midY45);
    path.quadraticBezierTo(leftX, midY45, leftX, midY45 + radius);
    path.lineTo(leftX, y5);

    // 5 → 6
    final double midY56 = (y5 + y6) / 2;
    path.lineTo(leftX, midY56 - radius);
    path.quadraticBezierTo(leftX, midY56, leftX + radius, midY56);
    path.lineTo(rightX - radius, midY56);
    path.quadraticBezierTo(rightX, midY56, rightX, midY56 + radius);
    path.lineTo(rightX, y6 + 30);

    // Dibujo en capas
    canvas.drawPath(path, shadowPaint);

    canvas.save();
    canvas.translate(-4, 0);
    canvas.drawPath(path, borderLeftPaint);
    canvas.restore();

    canvas.save();
    canvas.translate(4, 0);
    canvas.drawPath(path, borderRightPaint);
    canvas.restore();

    canvas.drawPath(path, roadPaint);
    _drawDashedPath(canvas, path, dashPaint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final extract = metric.extractPath(distance, distance + 10);
        canvas.drawPath(extract, paint);
        distance += 20;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
