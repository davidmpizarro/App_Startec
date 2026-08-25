import 'package:flutter/material.dart';
import '../widgets/main_scaffold.dart';
import 'confirmacion_matricula_screen.dart';

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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 32,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          const SizedBox(height: 24),

                          // Ícono persona
                          Icon(
                            Icons.person,
                            size: 100,
                            color: Colors.grey.shade400,
                          ),

                          const SizedBox(height: 24),

                          // Título
                          const Text(
                            '¡Pago confirmado!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
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
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 60,
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Texto informativo
                          const Text(
                            'Tu pago ha sido procesado exitosamente. Ahora puedes continuar con la confirmación de tu matrícula.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),

                      // Botón hacia Confirmación de matrícula
                      Padding(
                        padding: const EdgeInsets.only(top: 48),
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const ConfirmacionMatriculaScreen(),
                                ),
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
                                'Confirmación de matrícula',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
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
        ),
      ),
    );
  }
}
