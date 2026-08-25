import 'package:flutter/material.dart';
import '../widgets/main_scaffold.dart';
import 'dashboard_screen.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

class CareerScreen extends StatefulWidget {
  const CareerScreen({super.key});

  @override
  State<CareerScreen> createState() => _CareerScreenState();
}

class _CareerScreenState extends State<CareerScreen> {
  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              Center(
                child: Image.asset(
                  'assets/images/software-icon2.png',
                  width: 150,
                  height: 150,
                ),
              ),

              const SizedBox(height: 8),

              const Center(
                child: Text(
                  'Conoce tu carrera',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 8),

              Center(
                child: Builder(
                  builder: (context) {
                    final carrera = context.watch<AppState>().carreraUsuario;
                    return Text(
                      carrera.isNotEmpty
                          ? carrera
                          : 'Diseño y Desarrollo de Software',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color.fromARGB(255, 185, 109, 255),
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              _seccion('Duración'),
              const Text(
                '3 años (6 semestres)',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),

              const SizedBox(height: 20),

              _seccion('Cursos del primer semestre'),
              _curso('Técnicas de Expresión Oral y Escrita'),
              _curso('Cálculo y Estadística'),
              _curso('Desarrollo Personal'),
              _curso('Ciencias Básicas Aplicadas'),
              _curso('Diseño de Interfaces de Programación'),
              _curso('Fundamentos de Programación'),

              const SizedBox(height: 32),

              Center(
                child: GestureDetector(
                  onTap: () async {
                    await context.read<AppState>().completarPaso7Carrera();
                    if (!mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DashboardScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
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
                      'Completado ✓',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _seccion(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        titulo,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 185, 109, 255),
        ),
      ),
    );
  }

  Widget _curso(String nombre) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
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
    );
  }
}
