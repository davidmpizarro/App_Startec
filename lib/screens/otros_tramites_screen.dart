import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/main_scaffold.dart';

// ============================================================
// PALETA Y ESTILOS COMPARTIDOS
// ============================================================
class _C {
  static const purple = Color.fromARGB(255, 185, 109, 255);
  static const purpleDark = Color(0xFF7C3AED);
  static const slateDark = Color(0xFF1E293B);
  static const slateMuted = Color(0xFF64748B);
  static const border = Color(0xFFE2E8F0);
  static const bg = Color(0xFFF8FAFC);
}

class _Txt {
  static const subtitle = TextStyle(
    fontSize: 13,
    color: _C.slateMuted,
    height: 1.35,
  );
  static const sectionHeader = TextStyle(
    fontSize: 15.5,
    fontWeight: FontWeight.w700,
    color: _C.slateDark,
  );
  static const cardTitle = TextStyle(
    fontSize: 14.5,
    fontWeight: FontWeight.w700,
    color: _C.slateDark,
    height: 1.2,
  );
  static const body = TextStyle(
    fontSize: 12.5,
    color: _C.slateMuted,
    height: 1.35,
  );
  static const label = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: _C.slateMuted,
  );
  static const value = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w700,
    color: _C.slateDark,
  );
}

// ============================================================
// WIDGETS REUTILIZABLES
// ============================================================

/// Etiqueta/pill con fondo y texto de color (usado en badges de estado,
/// documento oficial y mini-tags del PDF).
class _Badge extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  final double fontSize;
  const _Badge(
    this.text, {
    required this.bg,
    required this.fg,
    this.fontSize = 10,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: fg,
      ),
    ),
  );
}

/// Contenedor circular/rectangular con icono coloreado (usado para el ícono
/// de cada trámite y del modal de detalle).
class _IconBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;
  const _IconBox(this.icon, this.color, {this.size = 10, this.iconSize = 24});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(size),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(icon, color: color, size: iconSize),
  );
}

/// Columna de estadística usada en el banner morado superior.
class _StatPill extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _StatPill(this.icon, this.title, this.subtitle);

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: Colors.white, size: 20),
      const SizedBox(width: 6),
      Flexible(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

/// Bloque "TIEMPO / COSTO" del modal de detalle.
class _StatBlock extends StatelessWidget {
  final String label;
  final String value;
  const _StatBlock(this.label, this.value);

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _Txt.label),
        const SizedBox(height: 2),
        Text(value, style: _Txt.value),
      ],
    ),
  );
}

// ============================================================
// PANTALLA PRINCIPAL
// ============================================================
class OtrosTramitesScreen extends StatefulWidget {
  const OtrosTramitesScreen({super.key});

  @override
  State<OtrosTramitesScreen> createState() => _OtrosTramitesScreenState();
}

class _OtrosTramitesScreenState extends State<OtrosTramitesScreen> {
  static const _urlPdfBecas =
      'https://www.tecsup.edu.pe/wp-content/uploads/2026/05/creditos-y-becas-2026-1.pdf';

  final List<_Tramite> _tramites = const [
    _Tramite(
      titulo: 'Becas Socioeconómicas Tecsup',
      subtitulo:
          'Descuentos del 25% al 100% en la pensión según evaluación socioeconómica y mérito académico.',
      icon: Icons.school_rounded,
      color: Color(0xFF8B5CF6),
      badgeText: 'Convocatoria Abierta',
      badgeBg: Color(0xFFECFDF5),
      badgeFg: Color(0xFF059669),
      tiempo: '5 a 7 días hábiles',
      costo: 'Gratuito',
      descripcion:
          'Programa de ayuda económica propio de Tecsup dirigido a estudiantes con dificultades socioeconómicas que demuestren un adecuado rendimiento académico.',
      requisitos: [
        'Estar matriculado en el periodo académico vigente.',
        'Promedio ponderado acumulado igual o mayor a 13.00.',
        'No tener sanciones disciplinarias en el historial académico.',
        'Ficha socioeconómica completa con sustento de ingresos familiares (boletas, recibos de servicios).',
      ],
      pasos: [
        'Descarga y completa la Ficha Socioeconómica en la Intranet.',
        'Adjunta la documentación de sustento en formato PDF.',
        'Entrevista personal virtual con la trabajadora social de tu sede.',
        'Publicación de resultados en tu portal estudiantil.',
      ],
      email: 'bienestar@tecsup.edu.pe',
    ),
    _Tramite(
      titulo: 'Crédito Educativo Tecsup',
      subtitulo:
          'Financiamiento de estudios con cuotas flexibles y tasa preferencial desde el 1er ciclo.',
      icon: Icons.account_balance_wallet_rounded,
      color: Color(0xFF0EA5E9),
      badgeText: 'Financiamiento 0% Interés Inicial',
      badgeBg: Color(0xFFEFF6FF),
      badgeFg: Color(0xFF2563EB),
      tiempo: '3 a 5 días hábiles',
      costo: 'Sujeto a evaluación',
      descripcion:
          'Mecanismo de financiamiento educativo que permite postergar el pago de un porcentaje de las cuotas del semestre para ser canceladas posteriormente con facilidades.',
      requisitos: [
        'Ser alumno regular o ingresante matriculado.',
        'Contar con un garante o apoderado con solvencia económica acreditada.',
        'Copia de DNI del alumno y apoderado.',
        'Últimos 3 recibos de ingresos o boletas de pago del garante.',
      ],
      pasos: [
        'Presentar solicitud de crédito a través del módulo de Tesorería.',
        'Envío de documentos del garante para verificación crediticia.',
        'Firma de pagaré y convenio de financiamiento virtual.',
        'Activación de matrícula con el nuevo cronograma fraccionado.',
      ],
      email: 'creditos@tecsup.edu.pe',
    ),
    _Tramite(
      titulo: 'Becas PRONABEC',
      subtitulo:
          'Beca integral del Estado peruano: cubre pensión, matrícula, laptop y asignación mensual.',
      icon: Icons.volunteer_activism_rounded,
      color: Color(0xFFEC4899),
      badgeText: 'Programa Estatal',
      badgeBg: Color(0xFFFDF2F8),
      badgeFg: Color(0xFFDB2777),
      tiempo: 'Según cronograma',
      costo: 'Gratuito',
      descripcion:
          'Convenio institucional con el Ministerio de Educación / PRONABEC para la validación y acompañamiento integral de los becarios adjudicados.',
      requisitos: [
        'Haber obtenido constancia de preselección o adjudicación de PRONABEC.',
        'Constancia de ingreso a Tecsup en una carrera elegible.',
        'Documentos de identidad vigentes.',
        'Cumplir con el perfil socioeconómico SISFOH.',
      ],
      pasos: [
        'Postulación oficial a través del portal de PRONABEC.',
        'Solicitar en Tecsup la constancia de admisión o constancia de matrícula.',
        'Cargar la aceptación institucional en la plataforma SIBEC.',
        'Acreditación y bienvenida en la Oficina de Bienestar Tecsup.',
      ],
      email: 'pronabec@tecsup.edu.pe',
    ),
  ];

  static const _faqs = [
    (
      q: '¿Puedo postular a una beca si estoy en primer ciclo?',
      a: 'Sí. Los ingresantes pueden postular al Crédito Educativo Tecsup y a las convocatorias estatales de PRONABEC (Beca 18). Para Becas Socioeconómicas propias se requiere evaluación al término del 1er ciclo con promedio mínimo.',
    ),
    (
      q: '¿Puedo combinar una beca con el crédito educativo?',
      a: 'Depende del porcentaje de cobertura otorgado. Consulta con Bienestar Estudiantil o el módulo de Tesorería para evaluar la compatibilidad de ambos beneficios en tu caso.',
    ),
    (
      q: '¿Cuándo se publican los resultados de las convocatorias?',
      a: 'Las Becas Socioeconómicas Tecsup publican resultados de 5 a 7 días hábiles tras la entrevista. Las convocatorias PRONABEC siguen su propio cronograma oficial.',
    ),
  ];

  void _snack(String msg, IconData icon) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _abrirPdf() async {
    try {
      final ok = await launchUrl(
        Uri.parse(_urlPdfBecas),
        mode: LaunchMode.externalApplication,
      );
      if (!ok)
        _snack(
          'No se pudo abrir el documento PDF. Intenta nuevamente.',
          Icons.error_outline,
        );
    } catch (_) {
      _snack(
        'Error de conexión al abrir el documento.',
        Icons.wifi_off_rounded,
      );
    }
  }

  Future<void> _contactarEmail(String email) async {
    final uri = Uri.parse(
      'mailto:$email?subject=Consulta%20de%20Tr%C3%A1mite%20Tecsup',
    );
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Escríbenos a: $email'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _abrirDetalle(_Tramite t) => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _DetalleTramiteSheet(
      tramite: t,
      onContactar: () => _contactarEmail(t.email),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header fijo (no hace scroll) ────────────────────────────
            _buildAppBar(context),

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
                    const Text(
                      'Consulta requisitos y postula a becas o financiamiento educativo de forma 100% digital.',
                      style: _Txt.subtitle,
                    ),
                    const SizedBox(height: 16),
                    _statsBanner(),
                    const SizedBox(height: 18),
                    Text(
                      'Becas y Créditos Educativos (${_tramites.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _C.slateDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final t in _tramites) _tramiteCard(t),
                    const SizedBox(height: 24),
                    _pdfCard(),
                    const SizedBox(height: 24),
                    _faqSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Secciones ----------

  Widget _buildAppBar(BuildContext context) {
    return Container(
      color: _C.bg,
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
                color: _C.slateDark,
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'Otros Trámites',
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _C.slateDark,
                letterSpacing: -0.2,
              ),
            ),
          ),
          const SizedBox(width: 34),
        ],
      ),
    );
  }

  Widget _statsBanner() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF7C3AED), Color(0xFF9333EA), Color(0xFFA855F7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: _C.purpleDark.withValues(alpha: 0.25),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        const _StatPill(Icons.stars_rounded, '3 Becas', 'Disponibles'),
        _divider(),
        const _StatPill(
          Icons.electric_bolt_rounded,
          '100% Digital',
          'Trámites en línea',
        ),
        _divider(),
        const _StatPill(
          Icons.support_agent_rounded,
          'Soporte',
          'Bienestar Tecsup',
        ),
      ],
    ),
  );

  Widget _divider() => Container(
    height: 32,
    width: 1,
    color: Colors.white.withValues(alpha: 0.25),
  );

  Widget _tramiteCard(_Tramite t) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _C.purple.withValues(alpha: 0.35), width: 1.2),
      boxShadow: [
        BoxShadow(
          color: _C.purple.withValues(alpha: 0.06),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _abrirDetalle(t),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _IconBox(t.icon, t.color),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _Badge(t.badgeText, bg: t.badgeBg, fg: t.badgeFg),
                            const Spacer(),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: Color(0xFF94A3B8),
                              size: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(t.titulo, style: _Txt.cardTitle),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(t.subtitulo, style: _Txt.body.copyWith(fontSize: 12.5)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _C.bg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 13,
                      color: _C.slateMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Respuesta: ${t.tiempo}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: _C.slateMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'Ver requisitos →',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _C.purpleDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _pdfCard() => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFFFAF5FF), Color(0xFFF3E8FF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: _C.purple.withValues(alpha: 0.45), width: 1.5),
      boxShadow: [
        BoxShadow(
          color: _C.purple.withValues(alpha: 0.1),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.picture_as_pdf_rounded,
                  color: Color(0xFFDC2626),
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Badge(
                      'DOCUMENTO OFICIAL',
                      bg: _C.purple.withValues(alpha: 0.15),
                      fg: _C.purpleDark,
                      fontSize: 10,
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Cifras Oficiales 2026-I',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _C.slateDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Consulta la resolución de adjudicación, estadísticas de becas asignadas y créditos otorgados por cada sede en el periodo 2026-I.',
            style: TextStyle(
              fontSize: 12.5,
              color: Color(0xFF475569),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _abrirPdf,
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: const Text(
                'Descargar / Ver Documento PDF',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.purpleDark,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _faqSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Row(
        children: [
          Icon(Icons.quiz_rounded, color: _C.purpleDark, size: 20),
          SizedBox(width: 8),
          Text('Preguntas Frecuentes', style: _Txt.sectionHeader),
        ],
      ),
      const SizedBox(height: 10),
      for (final f in _faqs)
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _C.border),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              title: Text(
                f.q,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _C.slateDark,
                ),
              ),
              iconColor: _C.purpleDark,
              collapsedIconColor: _C.slateMuted,
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              children: [
                Text(
                  f.a,
                  style: const TextStyle(
                    fontSize: 12,
                    color: _C.slateMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
    ],
  );
}

// ============================================================
// MODAL DE DETALLE
// ============================================================
class _DetalleTramiteSheet extends StatelessWidget {
  final _Tramite tramite;
  final VoidCallback onContactar;
  const _DetalleTramiteSheet({
    required this.tramite,
    required this.onContactar,
  });

  @override
  Widget build(BuildContext context) {
    final t = tramite;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 12,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _IconBox(t.icon, t.color, size: 12, iconSize: 28),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Badge(
                        t.badgeText,
                        bg: t.badgeBg,
                        fg: t.badgeFg,
                        fontSize: 10.5,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t.titulo,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: _C.slateDark,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Becas y Créditos Educativos',
                        style: TextStyle(fontSize: 12, color: _C.slateMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _C.bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _C.border),
              ),
              child: Row(
                children: [
                  _StatBlock('TIEMPO ESTIMADO', t.tiempo),
                  Container(height: 28, width: 1, color: _C.border),
                  const SizedBox(width: 12),
                  _StatBlock('COSTO / TASA', t.costo),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Descripción del Trámite',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: _C.slateDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              t.descripcion,
              style: const TextStyle(
                fontSize: 12.5,
                color: _C.slateMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '📋 Requisitos y Documentación',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: _C.slateDark,
              ),
            ),
            const SizedBox(height: 8),
            for (final req in t.requisitos)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF10B981),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        req,
                        style: const TextStyle(
                          fontSize: 12,
                          color: _C.slateDark,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            const Text(
              '🚀 Proceso de Solicitud',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: _C.slateDark,
              ),
            ),
            const SizedBox(height: 8),
            for (final (i, paso) in t.pasos.indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: _C.purpleDark,
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        paso,
                        style: const TextStyle(
                          fontSize: 12,
                          color: _C.slateDark,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: _C.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Cerrar',
                      style: TextStyle(color: _C.slateMuted, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onContactar();
                    },
                    icon: const Icon(Icons.email_outlined, size: 16),
                    label: const Text(
                      'Consultar / Solicitar',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _C.purpleDark,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// MODELO DE DATOS
// ============================================================
class _Tramite {
  final String titulo;
  final String subtitulo;
  final IconData icon;
  final Color color;
  final String badgeText;
  final Color badgeBg;
  final Color badgeFg;
  final String tiempo;
  final String costo;
  final String descripcion;
  final List<String> requisitos;
  final List<String> pasos;
  final String email;

  const _Tramite({
    required this.titulo,
    required this.subtitulo,
    required this.icon,
    required this.color,
    required this.badgeText,
    required this.badgeBg,
    required this.badgeFg,
    required this.tiempo,
    required this.costo,
    required this.descripcion,
    required this.requisitos,
    required this.pasos,
    required this.email,
  });
}
