import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../widgets/main_scaffold.dart';
import 'pasarela_pagos_screen.dart';

/// Modelo de datos para cada concepto de pago
class _ConceptoPago {
  final String id;
  final String titulo;
  final String subtitulo;
  final double precio;
  final IconData icono;
  final String tag;
  final bool obligatorio;
  bool seleccionado;

  _ConceptoPago({
    required this.id,
    required this.titulo,
    required this.subtitulo,
    required this.precio,
    required this.icono,
    required this.tag,
    this.obligatorio = false,
    this.seleccionado = true,
  });
}

/// Modelo para el cronograma de cuotas
class _CuotaCronograma {
  final String numero;
  final String fechaVencimiento;
  final double monto;
  final String estado;

  const _CuotaCronograma({
    required this.numero,
    required this.fechaVencimiento,
    required this.monto,
    required this.estado,
  });
}

class PagoMatriculaScreen extends StatefulWidget {
  const PagoMatriculaScreen({super.key});

  @override
  State<PagoMatriculaScreen> createState() => _PagoMatriculaScreenState();
}

class _PagoMatriculaScreenState extends State<PagoMatriculaScreen> {
  // Paleta de colores institucional Tecsup / Startec
  static const Color _primaryPurple = Color(0xFF9E4DFE);
  static const Color _brandPurple = Color(0xFFB96DFF);
  static const Color _darkPurple = Color(0xFF751FD6);
  static const Color _deepDark = Color(0xFF1E1435);
  static const Color _lightBg = Color(0xFFF7F5FC);
  static const Color _surfaceCard = Colors.white;

  bool _isProcesando = false;
  bool _mostrarCronograma = false;

  // Lista de conceptos a pagar
  late List<_ConceptoPago> _conceptos;

  // Cronograma estimado de cuotas del semestre 2026-I
  final List<_CuotaCronograma> _cronograma = const [
    _CuotaCronograma(
      numero: '1ra Cuota (Matrícula)',
      fechaVencimiento: 'Inmediato',
      monto: 550.00,
      estado: 'Por pagar',
    ),
    _CuotaCronograma(
      numero: '2da Cuota',
      fechaVencimiento: '30 de Setiembre 2026',
      monto: 550.00,
      estado: 'Programado',
    ),
    _CuotaCronograma(
      numero: '3ra Cuota',
      fechaVencimiento: '30 de Octubre 2026',
      monto: 550.00,
      estado: 'Programado',
    ),
    _CuotaCronograma(
      numero: '4ta Cuota',
      fechaVencimiento: '30 de Noviembre 2026',
      monto: 550.00,
      estado: 'Programado',
    ),
    _CuotaCronograma(
      numero: '5ta Cuota',
      fechaVencimiento: '30 de Diciembre 2026',
      monto: 550.00,
      estado: 'Programado',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _conceptos = [
      _ConceptoPago(
        id: 'matricula',
        titulo: 'Derecho de Matrícula 2026-II',
        subtitulo:
            'Apertura de registro académico, carné digital y reserva de vacante.',
        precio: 550.00,
        icono: Icons.school_rounded,
        tag: 'Requisito',
        obligatorio: false,
        seleccionado: true,
      ),
      _ConceptoPago(
        id: 'cuota1',
        titulo: '1° Cuota del Semestre',
        subtitulo: 'Primera mensualidad académica regular del periodo 2026-II.',
        precio: 550.00,
        icono: Icons.calendar_month_rounded,
        tag: 'Pensión',
        obligatorio: false,
        seleccionado: true,
      ),
    ];
  }

  double get _total => _conceptos
      .where((c) => c.seleccionado)
      .fold(0.0, (sum, c) => sum + c.precio);

  int get _cantidadSeleccionados =>
      _conceptos.where((c) => c.seleccionado).length;

  bool get _hayAlgunSeleccionado => _cantidadSeleccionados > 0;

  void _seleccionarTodo(bool todo) {
    setState(() {
      for (var c in _conceptos) {
        if (c.id == 'seguro') {
          c.seleccionado = todo;
        } else {
          c.seleccionado = todo;
        }
      }
    });
  }

  void _seleccionarSoloMatricula() {
    setState(() {
      for (var c in _conceptos) {
        c.seleccionado = (c.id == 'matricula');
      }
    });
  }

  Future<void> _continuarAPasarela() async {
    if (!_hayAlgunSeleccionado) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text('Debes seleccionar al menos un concepto a pagar.'),
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

    setState(() => _isProcesando = true);

    final appState = context.read<AppState>();
    final navigator = Navigator.of(context);

    await appState.completarPaso4PagoMatricula();

    if (!mounted) return;
    setState(() => _isProcesando = false);

    navigator.push(
      MaterialPageRoute(builder: (_) => const PasarelaPagosScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final nombreUsuario = state.nombreUsuario.trim();
    final documentoUsuario = state.documentoUsuario.trim();
    final carreraUsuario = state.carreraUsuario.isNotEmpty
        ? state.carreraUsuario
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
                    // Ficha del Estudiante
                    _buildStudentCard(
                      nombre: nombreUsuario,
                      documento: documentoUsuario,
                      carrera: carreraUsuario,
                    ),

                    const SizedBox(height: 16),

                    // Selector rápido de opciones
                    _buildQuickSelectChips(),

                    const SizedBox(height: 14),

                    // Título de Conceptos
                    const Text(
                      'Conceptos Disponibles a Cancelar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _deepDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Selecciona los ítems que deseas pagar en esta transacción:',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.grey.shade700,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Tarjetas de conceptos
                    ..._conceptos.map(
                      (concepto) => _buildConceptCard(concepto),
                    ),

                    const SizedBox(height: 14),

                    // Resumen de liquidación
                    _buildResumenLiquidacion(),

                    const SizedBox(height: 16),

                    // Acordeón del Cronograma de Cuotas
                    _buildCronogramaSection(),

                    const SizedBox(height: 16),

                    // Canales de pago aceptados
                    _buildCanalesPago(),

                    const SizedBox(height: 16),

                    // Sello de seguridad
                    // Sello de seguridad
                    _buildSecurityBanner(),

                    const SizedBox(height: 16),

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
              'Pago de Matrícula',
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
                          'Condición: Ingresante Admitido',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Semestre 2026-II',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildQuickSelectChips() {
    final todosSeleccionados = _conceptos.every((c) => c.seleccionado);
    final soloMatricula =
        _conceptos.firstWhere((c) => c.id == 'matricula').seleccionado &&
        !_conceptos.firstWhere((c) => c.id == 'cuota1').seleccionado;

    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => _seleccionarTodo(true),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: todosSeleccionados
                    ? _primaryPurple.withValues(alpha: 0.12)
                    : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: todosSeleccionados
                      ? _primaryPurple
                      : const Color(0xFFECE8F7),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.done_all_rounded,
                    size: 16,
                    color: todosSeleccionados
                        ? _primaryPurple
                        : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Pagar Todo',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: todosSeleccionados ? _primaryPurple : _deepDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: InkWell(
            onTap: _seleccionarSoloMatricula,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: soloMatricula
                    ? _primaryPurple.withValues(alpha: 0.12)
                    : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: soloMatricula
                      ? _primaryPurple
                      : const Color(0xFFECE8F7),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 16,
                    color: soloMatricula
                        ? _primaryPurple
                        : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Solo Matrícula',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: soloMatricula ? _primaryPurple : _deepDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConceptCard(_ConceptoPago concepto) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: concepto.seleccionado
              ? _primaryPurple
              : const Color(0xFFECE8F7),
          width: concepto.seleccionado ? 1.8 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: concepto.seleccionado
                ? _primaryPurple.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            setState(() => concepto.seleccionado = !concepto.seleccionado);
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Checkbox personalizado
                Checkbox(
                  value: concepto.seleccionado,
                  onChanged: (v) {
                    setState(() => concepto.seleccionado = v ?? false);
                  },
                  activeColor: _primaryPurple,
                  side: const BorderSide(color: _primaryPurple, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: 4),

                // Ícono
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: concepto.seleccionado
                        ? _primaryPurple.withValues(alpha: 0.12)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    concepto.icono,
                    color: concepto.seleccionado
                        ? _primaryPurple
                        : Colors.grey.shade600,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),

                // Info del concepto
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              concepto.titulo,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: _deepDark,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: concepto.id == 'matricula'
                                  ? Colors.indigo.shade50
                                  : (concepto.id == 'seguro'
                                        ? Colors.amber.shade50
                                        : Colors.teal.shade50),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              concepto.tag,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: concepto.id == 'matricula'
                                    ? Colors.indigo.shade800
                                    : (concepto.id == 'seguro'
                                          ? Colors.amber.shade900
                                          : Colors.teal.shade800),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        concepto.subtitulo,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.grey.shade600,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'S/ ${concepto.precio.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: _primaryPurple,
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
  }

  Widget _buildResumenLiquidacion() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFECE8F7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.receipt_long_rounded, color: _primaryPurple, size: 20),
              SizedBox(width: 8),
              Text(
                'Resumen de Liquidación',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: _deepDark,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          ..._conceptos.where((c) => c.seleccionado).map((c) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      c.titulo,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  Text(
                    'S/ ${c.precio.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _deepDark,
                    ),
                  ),
                ],
              ),
            );
          }),
          if (!_hayAlgunSeleccionado)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No has seleccionado ningún concepto todavía.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: Colors.redAccent.shade700,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total a Cancelar:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _deepDark,
                ),
              ),
              Text(
                'S/ ${_total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: _primaryPurple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCronogramaSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFECE8F7)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: _mostrarCronograma,
          onExpansionChanged: (v) => setState(() => _mostrarCronograma = v),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _primaryPurple.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.date_range_rounded,
              color: _primaryPurple,
              size: 20,
            ),
          ),
          title: const Text(
            'Cronograma de Cuotas 2026-II',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _deepDark,
            ),
          ),
          subtitle: Text(
            '5 cuotas mensuales del semestre académico',
            style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  ..._cronograma.map((cuota) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cuota.numero,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _deepDark,
                                ),
                              ),
                              Text(
                                'Vence: ${cuota.fechaVencimiento}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'S/ ${cuota.monto.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _primaryPurple,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCanalesPago() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFECE8F7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.payment_rounded, color: _primaryPurple, size: 20),
              SizedBox(width: 8),
              Text(
                'Métodos de Pago Aceptados',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: _deepDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _metodoPill(
                'Tarjetas Débito / Crédito',
                Icons.credit_card_rounded,
              ),
              _metodoPill('Yape & Plin QR', Icons.qr_code_rounded),
              _metodoPill(
                'PagoEfectivo / CIP',
                Icons.account_balance_wallet_rounded,
              ),
              _metodoPill(
                'Banca Móvil & Agentes',
                Icons.account_balance_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metodoPill(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _lightBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFECE8F7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _primaryPurple),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: const Row(
        children: [
          Icon(Icons.lock_outline_rounded, color: Color(0xFF065F46), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Transacción 100% segura y encriptada bajo estándares PCI-DSS de Tecsup.',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF064E3B),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Sticky Bottom Action Bar ──────────────────────────────────────────────
  Widget _buildBottomActionBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Total en vivo
          Expanded(
            flex: 4,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOTAL A PAGAR',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'S/ ${_total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: _primaryPurple,
                  ),
                ),
              ],
            ),
          ),

          // Botón Continuar
          // Botón Continuar
          Expanded(
            flex: 6,
            child: GestureDetector(
              onTap: (_hayAlgunSeleccionado && !_isProcesando)
                  ? _continuarAPasarela
                  : null,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _hayAlgunSeleccionado ? 1.0 : 0.4,
                child: Container(
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _brandPurple,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: _hayAlgunSeleccionado
                        ? const [
                            BoxShadow(
                              color: Color.fromARGB(255, 132, 57, 231),
                              offset: Offset(3, 6),
                              blurRadius: 3,
                              spreadRadius: 1,
                            ),
                          ]
                        : [],
                  ),
                  child: _isProcesando
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Pagar Ahora',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
