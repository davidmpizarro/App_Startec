import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../widgets/main_scaffold.dart';

class MisHorariosScreen extends StatelessWidget {
  const MisHorariosScreen({super.key});

  static const Color _darkBlue = Color.fromARGB(255, 26, 29, 46);
  static const Color _purple = Color.fromARGB(255, 185, 109, 255);

  @override
  Widget build(BuildContext context) {
    // ✅ watch: si el estado de matrícula cambia mientras el usuario está
    // en esta pantalla, se refresca solo (por ejemplo, si confirma su pago
    // en otra pestaña/flujo y vuelve).
    final state = context.watch<AppState>();
    final bool matriculado = state.paso6Confirmacion;

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
                      'Mis Horarios',
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
                  16,
                  12,
                  16,
                  MainScaffold.bottomBarHeight(context) + 30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!matriculado)
                      _tarjetaNoMatriculado()
                    else
                      _tarjetaPendiente(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // Estado 1: el alumno todavía NO completó su matrícula
  // ============================================================
  Widget _tarjetaNoMatriculado() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFCBD5E1)),
    ),
    child: const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.lock_clock_rounded, color: Color(0xFF64748B), size: 22),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Matrícula pendiente',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Aún no has completado tu proceso de matrícula. Cuando lo hagas, '
                'aquí podrás ver el horario con tus cursos y secciones asignadas.',
                style: TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF475569),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  // ============================================================
  // Estado 2: el alumno YA se matriculó, pero el horario todavía
  // no está disponible (llegará en la fase 2, vía API de U+).
  // ============================================================
  Widget _tarjetaPendiente() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFF3E8FF),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFD8B4FE)),
    ),
    child: const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.hourglass_top_rounded, color: _purple, size: 22),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Horario',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF581C87),
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Pendiente',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Tu matrícula fue confirmada. Tus cursos y horario se '
                'publicarán aquí en cuanto estén disponibles.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF6B21A8),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
