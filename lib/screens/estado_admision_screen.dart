import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../widgets/main_scaffold.dart';
import 'profile_screen.dart';
import 'document_upload_screen.dart';
import 'pagomatricula_screen.dart';
import 'pasarela_pagos_screen.dart';
import 'confirmacion_matricula_screen.dart';
import 'career_screen.dart';
import 'dashboard_screen.dart';

class EstadoAdmisionScreen extends StatelessWidget {
  const EstadoAdmisionScreen({super.key});

  static const Color _brandPurple = Color.fromARGB(255, 185, 109, 255);
  static const Color _darkBlue = Color.fromARGB(255, 26, 29, 46);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    final pasos = <_Paso>[
      _Paso('Bienvenida', state.paso1Bienvenida, null),
      _Paso('Actualiza tu perfil', state.paso2Perfil, const ProfileScreen()),
      _Paso(
        'Carga tus documentos',
        state.paso3Documentos,
        const DocumentUploadScreen(),
      ),
      _Paso(
        'Pago de Matrícula',
        state.paso4PagoMatricula,
        const PagoMatriculaScreen(),
      ),
      _Paso(
        'Pasarela de pagos',
        state.paso5Pasarela,
        const PasarelaPagosScreen(),
      ),
      _Paso(
        'Confirmación de matrícula',
        state.paso6Confirmacion,
        const ConfirmacionMatriculaScreen(),
      ),
      _Paso('Conoce tu carrera', state.paso7Carrera, const CareerScreen()),
      _Paso('Conquista el campus', state.paso8Campus, const DashboardScreen()),
    ];

    final completados = pasos.where((p) => p.completado).length;
    final total = pasos.length;
    final progreso = completados / total;

    final proximoPaso = pasos.firstWhere(
      (p) => !p.completado,
      orElse: () => _Paso('¡Todo completo!', true, null),
    );

    return MainScaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Header fijo con fondo sólido (no se transparenta al scrollear) ──
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                        color: _darkBlue,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Estado de Admisión',
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _darkBlue,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 34),
                ],
              ),
            ),

            // ── Contenido con scroll ─────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  MainScaffold.bottomBarHeight(context) + 30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Revisa tu condición académica y completa los pasos pendientes de tu matrícula.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Card 1: Condición académica (fija, ya eres ingresante admitido)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: _brandPurple.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _brandPurple.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Condición académica',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _brandPurple.withValues(alpha: 0.85),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text(
                                'Ingresante',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade600,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Admitido',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Card 2: Siguiente etapa (dinámica, progreso de matrícula)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Siguiente etapa',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Proceso de matrícula habilitado',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 14),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: progreso,
                              minHeight: 10,
                              backgroundColor: Colors.white,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                _brandPurple,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$completados de $total pasos completados',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Card de próximo paso
                    if (completados < total)
                      GestureDetector(
                        onTap: proximoPaso.pantalla == null
                            ? null
                            : () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => proximoPaso.pantalla!,
                                ),
                              ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _brandPurple,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(255, 132, 57, 231),
                                offset: const Offset(2, 4),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.flag, color: Colors.white),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Tu próximo paso',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      proximoPaso.titulo,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),

                    const Text(
                      'Checklist para consolidar tu condición de alumno regular',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),

                    ...pasos.map((p) => _buildPasoItem(context, p)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasoItem(BuildContext context, _Paso paso) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: paso.completado ? Colors.green.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: paso.completado ? Colors.green.shade200 : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Icon(
            paso.completado ? Icons.check_circle : Icons.radio_button_unchecked,
            color: paso.completado ? Colors.green : Colors.grey,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              paso.titulo,
              style: TextStyle(
                fontSize: 14,
                fontWeight: paso.completado
                    ? FontWeight.w600
                    : FontWeight.normal,
                color: paso.completado ? Colors.green.shade800 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Paso {
  final String titulo;
  final bool completado;
  final Widget? pantalla;

  _Paso(this.titulo, this.completado, this.pantalla);
}
