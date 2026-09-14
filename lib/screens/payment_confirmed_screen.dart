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
            final isSmall = constraints.maxHeight < 680;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                24,
                16,
                24,
                MainScaffold.bottomBarHeight(context) + 24,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - (MainScaffold.bottomBarHeight(context) + 24),
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: isSmall ? 10 : 20),

                      // Ícono persona
                      Icon(
                        Icons.person,
                        size: isSmall ? 70 : 90,
                        color: Colors.grey.shade400,
                      ),

                      SizedBox(height: isSmall ? 14 : 20),

                      // Título
                      Text(
                        '¡Pago confirmado!',
                        style: TextStyle(
                          fontSize: isSmall ? 22 : 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: isSmall ? 20 : 28),

                      // Ícono check verde
                      Container(
                        width: isSmall ? 75 : 90,
                        height: isSmall ? 75 : 90,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: isSmall ? 48 : 56,
                        ),
                      ),

                      SizedBox(height: isSmall ? 24 : 32),

                      // Texto informativo
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'Tu pago ha sido procesado exitosamente. Ahora puedes continuar con la confirmación de tu matrícula.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isSmall ? 14 : 15,
                            color: Colors.black87,
                            height: 1.45,
                          ),
                        ),
                      ),

                      SizedBox(height: isSmall ? 32 : 44),

                      // Botón hacia Confirmación de matrícula
                      Center(
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
                              horizontal: 36,
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
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
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
                      const SizedBox(height: 16),
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
