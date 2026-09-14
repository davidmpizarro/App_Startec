import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/main_scaffold.dart';
import '../services/app_state.dart';

// ============================================================
// PALETA COMPARTIDA (misma convención que el resto de la app)
// ============================================================
class _C {
  static const purple = Color.fromARGB(255, 185, 109, 255);
}

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final matriculaPagada = state.paso4PagoMatricula;

    return MainScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            24,
            8,
            24,
            MainScaffold.bottomBarHeight(context) + 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // ── Flecha de regreso (mismo estilo que el resto de la app) ──
              Builder(
                builder: (context) => InkWell(
                  onTap: () {
                    if (Navigator.canPop(context)) Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.black87,
                      size: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Header (ícono + título centrados) ─────────────────────────
              const Center(
                child: Icon(Icons.credit_card, size: 80, color: _C.purple),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'Mis Pagos',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 28),

              // ── Estado de deuda ──────────────────────────────
              _seccion('Estado de matrícula'),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _C.purple.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _C.purple, width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _deudaFila(
                      'Matrícula',
                      matriculaPagada ? 'Pagada' : 'Pendiente',
                      color: matriculaPagada ? Colors.green : Colors.redAccent,
                    ),
                    const SizedBox(height: 8),
                    _deudaFila('Periodo', '2026 - II (Regular)'),
                    const Divider(height: 20),
                    Row(
                      children: [
                        Icon(
                          matriculaPagada
                              ? Icons.check_circle
                              : Icons.error_outline,
                          color: matriculaPagada ? Colors.green : Colors.orange,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          matriculaPagada
                              ? 'Al día'
                              : 'Completa tu pago de matrícula',
                          style: TextStyle(
                            color: matriculaPagada
                                ? Colors.green
                                : Colors.orange.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Cursos matriculados ──────────────────────────
              _seccion('Mis cursos'),
              if (matriculaPagada)
                _infoVacia(
                  Icons.menu_book_outlined,
                  'Tus cursos aparecerán aquí una vez inicie el ciclo académico.',
                )
              else
                _infoVacia(
                  Icons.lock_outline,
                  'Completa el pago de tu matrícula para ver tus cursos asignados.',
                ),

              const SizedBox(height: 24),

              // ── Métodos de pago ──────────────────────────────
              _seccion('Métodos de pago'),
              _metodoPago(
                Icons.account_balance,
                'Transferencia bancaria',
                'BCP / Interbank / BBVA',
              ),
              _metodoPago(
                Icons.phone_android,
                'Yape / Plin',
                'Pago inmediato con QR',
              ),
              _metodoPago(
                Icons.store,
                'Agente o caja',
                'Pago presencial en sede',
              ),

              const SizedBox(height: 24),

              // ── Historial de pagos ───────────────────────────
              _seccion('Historial de pagos'),
              if (matriculaPagada)
                _historialItem('Matrícula 2026-II', 'Pagado', pendiente: false)
              else
                _infoVacia(
                  Icons.receipt_long_outlined,
                  'Aún no tienes pagos registrados.',
                ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _seccion(String titulo) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      titulo,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: _C.purple,
      ),
    ),
  );

  Widget _deudaFila(String label, String valor, {Color? color}) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(fontSize: 14, color: Colors.black54)),
      Text(
        valor,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: color ?? Colors.black87,
        ),
      ),
    ],
  );

  Widget _infoVacia(IconData icon, String mensaje) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Row(
      children: [
        Icon(icon, color: Colors.grey.shade500, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            mensaje,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
        ),
      ],
    ),
  );

  Widget _metodoPago(IconData icon, String titulo, String subtitulo) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _C.purple.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: _C.purple, size: 24),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Text(
              subtitulo,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _historialItem(
    String concepto,
    String estado, {
    bool pendiente = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: pendiente
            ? Colors.redAccent.withValues(alpha: 0.08)
            : Colors.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: pendiente ? Colors.redAccent : Colors.green,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              concepto,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: pendiente ? Colors.redAccent : Colors.green,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              estado,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
