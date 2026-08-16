import 'package:flutter/material.dart';
import '../widgets/main_scaffold.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              const Center(
                child: Icon(
                  Icons.credit_card,
                  size: 80,
                  color: Color.fromARGB(255, 185, 109, 255),
                ),
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
              _seccion('Estado de deuda'),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(30, 185, 109, 255),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color.fromARGB(255, 185, 109, 255),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _deudaFila('Monto mensual', 'S/ 1,352.00'),
                    const SizedBox(height: 8),
                    _deudaFila('Pagado', 'S/ 1,352.00', color: Colors.green),
                    const SizedBox(height: 8),
                    _deudaFila('Pendiente', 'S/ 0.00', color: Colors.redAccent),
                    const Divider(height: 20),
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Al día',
                          style: TextStyle(
                            color: Colors.green,
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

              // ── Cursos pagados ───────────────────────────────
              _seccion('Mis cursos pagados'),
              _cursoPagado('Ciencias Básicas Aplicadas', 'S/ 338.00'),
              _cursoPagado('Diseño de Interfaces de Programación', 'S/ 338.00'),
              _cursoPagado('Fundamentos de Programación', 'S/ 338.00'),
              _cursoPagado('Cálculo y Estadística', 'S/ 338.00'),

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
              _historialItem('Enero 2025', 'S/ 1,352.00', 'Pagado'),
              _historialItem('Febrero 2025', 'S/ 1,352.00', 'Pagado'),
              _historialItem('Marzo 2025', 'S/ 1,352.00', 'Pagado'),
              _historialItem(
                'Abril 2025',
                'S/ 1,352.00',
                'Pendiente',
                pendiente: true,
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
        color: Color.fromARGB(255, 185, 109, 255),
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

  Widget _cursoPagado(String nombre, String precio) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Color.fromARGB(255, 185, 109, 255),
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  nombre,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
        Text(
          precio,
          style: const TextStyle(
            fontSize: 14,
            color: Color.fromARGB(255, 185, 109, 255),
            fontWeight: FontWeight.w600,
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
            color: const Color.fromARGB(30, 185, 109, 255),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: const Color.fromARGB(255, 185, 109, 255),
            size: 24,
          ),
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
    String mes,
    String monto,
    String estado, {
    bool pendiente = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: pendiente
            ? const Color.fromARGB(20, 255, 80, 80)
            : const Color.fromARGB(20, 80, 200, 120),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: pendiente ? Colors.redAccent : Colors.green,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            mes,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          Text(
            monto,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
