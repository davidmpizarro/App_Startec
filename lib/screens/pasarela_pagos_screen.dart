import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../widgets/main_scaffold.dart';
import 'payment_confirmed_screen.dart';

class PasarelaPagosScreen extends StatefulWidget {
  const PasarelaPagosScreen({super.key});

  @override
  State<PasarelaPagosScreen> createState() => _PasarelaPagosScreenState();
}

class _PasarelaPagosScreenState extends State<PasarelaPagosScreen> {
  static const Color _brandPurple = Color.fromARGB(255, 185, 109, 255);

  final _numeroTarjeta = TextEditingController();
  final _titular = TextEditingController();
  final _vencimiento = TextEditingController();
  final _cvv = TextEditingController();
  bool _isProcesando = false;

  @override
  void dispose() {
    _numeroTarjeta.dispose();
    _titular.dispose();
    _vencimiento.dispose();
    _cvv.dispose();
    super.dispose();
  }

  Future<void> _procesarPago() async {
    if (_numeroTarjeta.text.isEmpty ||
        _titular.text.isEmpty ||
        _vencimiento.text.isEmpty ||
        _cvv.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa todos los datos de la tarjeta.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isProcesando = true);

    // ⚠️ Simulado — aquí se integraría Culqi/Niubiz/etc. cuando esté listo el backend.
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    await context.read<AppState>().completarPaso5Pasarela();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const PaymentConfirmedScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const Icon(Icons.credit_card, size: 80, color: _brandPurple),
              const SizedBox(height: 12),
              const Text(
                'Pasarela de Pagos',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Ingresa los datos de tu tarjeta para completar el pago (entorno de prueba).',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),

              _campo(
                'Número de tarjeta',
                _numeroTarjeta,
                hint: '4111 1111 1111 1111',
              ),
              _campo(
                'Nombre del titular',
                _titular,
                hint: 'Como aparece en la tarjeta',
              ),
              Row(
                children: [
                  Expanded(
                    child: _campo('Vencimiento', _vencimiento, hint: 'MM/AA'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _campo('CVV', _cvv, hint: '123')),
                ],
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isProcesando ? null : _procesarPago,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brandPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 3,
                  ),
                  child: _isProcesando
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'CONFIRMAR PAGO',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _campo(
    String label,
    TextEditingController controller, {
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Container(
            height: 44,
            decoration: BoxDecoration(
              border: Border.all(color: _brandPurple, width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: controller,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
