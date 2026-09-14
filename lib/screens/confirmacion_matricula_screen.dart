import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/app_state.dart';
import '../widgets/main_scaffold.dart';
import 'career_screen.dart';

class ConfirmacionMatriculaScreen extends StatefulWidget {
  const ConfirmacionMatriculaScreen({super.key});

  @override
  State<ConfirmacionMatriculaScreen> createState() =>
      _ConfirmacionMatriculaScreenState();
}

class _ConfirmacionMatriculaScreenState
    extends State<ConfirmacionMatriculaScreen> {
  // Paleta de colores institucional Tecsup / Startec
  static const Color _primaryPurple = Color(0xFF9E4DFE);
  static const Color _brandPurple = Color(0xFFB96DFF);
  static const Color _darkPurple = Color(0xFF751FD6);
  static const Color _deepDark = Color(0xFF1E1435);
  static const Color _lightBg = Color(0xFFF7F5FC);
  static const Color _surfaceCard = Colors.white;

  // Enlace oficial al portal SIS Tecsup (UMASNET)
  static const String _urlConfirmacion =
      'https://sis.tecsup.edu.pe/umasnet/Home2.aspx';

  bool _isConfirmando = false;
  bool _mostrarFaq = false;

  Future<void> _abrirEnlace() async {
    final uri = Uri.parse(_urlConfirmacion);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Expanded(child: Text('No se pudo abrir el navegador web.')),
              ],
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text('Error al intentar abrir el enlace del SIS.'),
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
      }
    }
  }

  void _mostrarModalConstancia({
    required String nombre,
    required String documento,
    required String carrera,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _primaryPurple.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.verified_rounded,
                          color: _primaryPurple,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Constancia de Matrícula Digital',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: _deepDark,
                              ),
                            ),
                            Text(
                              'Documento Preliminar Oficial 2026-I',
                              style: TextStyle(
                                fontSize: 12,
                                color: _primaryPurple,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _lightBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFECE8F7)),
                    ),
                    child: Column(
                      children: [
                        _filaConstancia(
                          'Estudiante',
                          nombre.isNotEmpty ? nombre : 'Estudiante Admitido',
                        ),
                        const Divider(height: 16),
                        _filaConstancia(
                          'Documento DNI',
                          documento.isNotEmpty ? documento : 'Pendiente',
                        ),
                        const Divider(height: 16),
                        _filaConstancia(
                          'Programa Académico',
                          carrera.isNotEmpty
                              ? carrera
                              : 'Diseño y Desarrollo de Software',
                        ),
                        const Divider(height: 16),
                        _filaConstancia('Semestre', '2026-II (Ciclo I)'),
                        const Divider(height: 16),
                        _filaConstancia('Condición', 'Ingresante Regular'),
                        const Divider(height: 16),
                        _filaConstancia(
                          'Código de Registro',
                          'TEC-2026-I-${documento.isNotEmpty ? documento.substring(0, documento.length > 4 ? 4 : documento.length) : '0849'}',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.shield_rounded,
                          color: Color(0xFF047857),
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Autenticidad respaldada por los servidores institucionales de Tecsup.',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF064E3B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Cerrar Vista Previa',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _filaConstancia(String label, String valor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        Flexible(
          child: Text(
            valor,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: _deepDark,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _completarPaso() async {
    setState(() => _isConfirmando = true);
    final appState = context.read<AppState>();
    final navigator = Navigator.of(context);

    await appState.completarPaso6Confirmacion();

    if (!mounted) return;
    setState(() => _isConfirmando = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                '¡Matrícula confirmada! Ahora conoce los detalles de tu carrera.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    navigator.push(MaterialPageRoute(builder: (_) => const CareerScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final nombreUsuario = appState.nombreUsuario.trim();
    final documentoUsuario = appState.documentoUsuario.trim();
    final carreraUsuario = appState.carreraUsuario.isNotEmpty
        ? appState.carreraUsuario
        : 'Diseño y Desarrollo de Software';

    return MainScaffold(
      backgroundColor: _lightBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Navigation Bar ─────────────────────────────────────────
            _buildAppBar(context),

            // ── Contenido con Scroll ───────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  18,
                  12,
                  18,
                  MainScaffold.bottomBarHeight(context) + 30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ficha de Matrícula del Estudiante
                    _buildStudentCard(
                      nombre: nombreUsuario,
                      documento: documentoUsuario,
                      carrera: carreraUsuario,
                    ),

                    const SizedBox(height: 16),

                    // Checklist de validación institucional
                    _buildChecklistSection(appState),

                    const SizedBox(height: 16),

                    // Tarjeta Principal Portal SIS Tecsup (UMASNET)
                    _buildSisPortalCard(),

                    const SizedBox(height: 16),

                    // Vista previa de Constancia de Matrícula
                    _buildConstanciaActionCard(
                      nombre: nombreUsuario,
                      documento: documentoUsuario,
                      carrera: carreraUsuario,
                    ),

                    const SizedBox(height: 16),

                    // Preguntas frecuentes
                    // Preguntas frecuentes
                    _buildFaqSection(),

                    const SizedBox(height: 16),

                    // Botón de confirmación (dentro del scroll)
                    _buildBottomActionBar(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
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
          const Expanded(
            child: Text(
              'Confirmación de Matrícula',
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
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

  Widget _buildStudentCard({
    required String nombre,
    required String documento,
    required String carrera,
  }) {
    final nombreMostrar = nombre.isNotEmpty ? nombre : 'Estudiante Ingresante';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _brandPurple,
            _brandPurple.withValues(alpha: 0.85),
            _darkPurple,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _brandPurple.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nombreMostrar,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Carrera: $carrera',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Colors.white70,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.verified_user_rounded,
                          color: Colors.lightGreenAccent,
                          size: 15,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Estado: Matrícula Lista para Confirmación',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistSection(AppState appState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFECE8F7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.checklist_rounded, color: _primaryPurple, size: 20),
              SizedBox(width: 8),
              Text(
                'Requisitos Previos Cumplidos',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: _deepDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _itemChecklist(
            titulo: 'Perfil y Datos Personales',
            subtitulo: 'Información del alumno y contacto registrados',
            completado: appState.paso2Perfil,
          ),
          const Divider(height: 16),
          _itemChecklist(
            titulo: 'Documentación Académica',
            subtitulo: 'DNI y Certificados de Estudios entregados',
            completado: appState.paso3Documentos,
          ),
          const Divider(height: 16),
          _itemChecklist(
            titulo: 'Pago de Matrícula',
            subtitulo: 'Derechos académicos cancelados exitosamente',
            completado: appState.paso4PagoMatricula || appState.paso5Pasarela,
          ),
          const Divider(height: 16),
          _itemChecklist(
            titulo: 'Firma de Acta en Portal SIS Tecsup',
            subtitulo: 'Confirmación final en el sistema institucional',
            completado: true,
            destacado: true,
          ),
        ],
      ),
    );
  }

  Widget _itemChecklist({
    required String titulo,
    required String subtitulo,
    required bool completado,
    bool destacado = false,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: completado
                ? const Color(0xFF059669).withValues(alpha: 0.12)
                : Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            completado ? Icons.check_circle_rounded : Icons.pending_outlined,
            size: 18,
            color: completado ? const Color(0xFF059669) : Colors.grey.shade400,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: destacado ? _primaryPurple : _deepDark,
                ),
              ),
              Text(
                subtitulo,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        if (completado)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Listo',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF059669),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSisPortalCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFECE8F7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: _brandPurple.withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/isis.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.language_rounded,
                      color: _primaryPurple,
                      size: 32,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'U+',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _deepDark,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Sistema de Información de Alumnos',
                      style: TextStyle(
                        fontSize: 12,
                        color: _primaryPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Ingresa al portal institucional con tu cuenta para validar la firma de tu acta digital y asegurar tu asignación de horarios:',
            style: TextStyle(
              fontSize: 12.5,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: _abrirEnlace,
            child: Container(
              width: double.infinity,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _brandPurple,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(255, 132, 57, 231),
                    offset: Offset(2, 4),
                    blurRadius: 3,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.open_in_new_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Abrir Portal SIS Tecsup',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConstanciaActionCard({
    required String nombre,
    required String documento,
    required String carrera,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFECE8F7)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0284C7).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.article_rounded,
              color: Color(0xFF0284C7),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Constancia Digital',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _deepDark,
                  ),
                ),
                Text(
                  'Visualiza tu récord preliminar oficial',
                  style: TextStyle(fontSize: 11.5, color: Colors.black54),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () => _mostrarModalConstancia(
              nombre: nombre,
              documento: documento,
              carrera: carrera,
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF0284C7)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            ),
            child: const Text(
              'Ver Ficha',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0284C7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFECE8F7)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: _mostrarFaq,
          onExpansionChanged: (v) => setState(() => _mostrarFaq = v),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _primaryPurple.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.help_outline_rounded,
              color: _primaryPurple,
              size: 20,
            ),
          ),
          title: const Text(
            'Preguntas Frecuentes de Matrícula',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _deepDark,
            ),
          ),
          subtitle: Text(
            'Dudas sobre horarios, accesos y pasos siguientes',
            style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
          ),
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  Divider(height: 1),
                  SizedBox(height: 8),
                  _FaqItem(
                    pregunta: '¿Cuándo se publicarán mis horarios y sección?',
                    respuesta:
                        'Los horarios finales de clases y grupos asignados se publicarán en la 2da fase antes del inicio del semestre en tu Dashboard y portal SIS.',
                  ),
                  _FaqItem(
                    pregunta: '¿Cómo accedo al aula virtual Canvas?',
                    respuesta:
                        'Podrás ingresar con tu correo institucional @tecsup.edu.pe. Recibirás tu credencial activa días previos a la primera semana de clases.',
                  ),
                  _FaqItem(
                    pregunta: '¿Qué paso sigue después de confirmar?',
                    respuesta:
                        'Continuarás al Paso 7 para conocer el plan de estudios completo, competencias y tecnologías de tu carrera.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Sticky Bottom Action Bar ──────────────────────────────────────────────
  Widget _buildBottomActionBar() {
    return GestureDetector(
      onTap: _isConfirmando ? null : _completarPaso,
      child: Container(
        width: double.infinity,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _brandPurple,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(255, 132, 57, 231),
              offset: Offset(3, 6),
              blurRadius: 3,
              spreadRadius: 1,
            ),
          ],
        ),
        child: _isConfirmando
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'CONFIRMAR Y CONOCER MI CARRERA',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ],
              ),
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  final String pregunta;
  final String respuesta;

  const _FaqItem({required this.pregunta, required this.respuesta});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                size: 16,
                color: Color(0xFF9E4DFE),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  pregunta,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1435),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Text(
              respuesta,
              style: TextStyle(
                fontSize: 11.5,
                color: Colors.grey.shade700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
