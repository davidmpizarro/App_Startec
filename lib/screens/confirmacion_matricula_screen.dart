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
  static const Color _brandPurple = Color.fromARGB(255, 185, 109, 255);
  static const String _urlConfirmacion =
      'https://sis.tecsup.edu.pe/umasnet/Home2.aspx';

  Future<void> _abrirEnlace() async {
    final uri = Uri.parse(_urlConfirmacion);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir el navegador web.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al intentar abrir el enlace.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 14),

              // Ícono persona
              Icon(Icons.person, size: 100, color: Colors.grey.shade400),

              const SizedBox(height: 16),

              // Título
              const Text(
                'Confirmación de Matrícula',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 18),

              // Mensaje explicativo
              const Text(
                'Para finalizar tu proceso de matrícula, debes realizar el clic final de confirmación ingresando al portal de Tecsup.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 28),

              // Tarjeta interactiva del portal SIS Tecsup
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(25, 185, 109, 255),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _brandPurple.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
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
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Portal SIS Tecsup',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Haz clic en el enlace para abrir el portal y completar tu confirmación:',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: _abrirEnlace,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _brandPurple),
                          boxShadow: [
                            BoxShadow(
                              color: _brandPurple.withValues(alpha: 0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.open_in_new,
                              size: 18,
                              color: _brandPurple,
                            ),
                            SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                _urlConfirmacion,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _brandPurple,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Botón para continuar
              Center(
                child: GestureDetector(
                  onTap: () async {
                    final appState = context.read<AppState>();
                    final navigator = Navigator.of(context);
                    await appState.completarPaso6Confirmacion();
                    if (!mounted) return;
                    navigator.push(
                      MaterialPageRoute(builder: (_) => const CareerScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: _brandPurple,
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

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
