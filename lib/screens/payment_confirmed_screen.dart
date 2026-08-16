import 'package:flutter/material.dart';
import 'career_screen.dart';
import '../widgets/main_scaffold.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

class PaymentConfirmedScreen extends StatefulWidget {
  const PaymentConfirmedScreen({super.key});

  @override
  State<PaymentConfirmedScreen> createState() => _PaymentConfirmedScreenState();
}

class _PaymentConfirmedScreenState extends State<PaymentConfirmedScreen> {
  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),

              // Ícono persona
              Icon(Icons.person, size: 100, color: Colors.grey.shade400),

              const SizedBox(height: 24),

              // Título
              const Text(
                '¡Pago confirmado!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 32),

              // Ícono check verde
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 60),
              ),

              const SizedBox(height: 40),

              // Texto informativo
              const Text(
                'Tu pago ha sido procesado exitosamente. Ahora puedes continuar con los pasos finales para el inicio de clases.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),

              const Spacer(),

              // Botón
              Center(
                child: GestureDetector(
                  onTap: () async {
                    await context.read<AppState>().completarPaso4();
                    if (!mounted) return; // ✅ falta esto
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CareerScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 185, 109, 255),
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromARGB(255, 132, 57, 231),
                          offset: Offset(3, 6),
                          blurRadius: 3,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Text(
                      'Ir a tu vida en Tecsup',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
