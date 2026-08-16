import 'package:flutter/material.dart';
import 'payment_confirmed_screen.dart';
import '../widgets/main_scaffold.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  final List<Map<String, dynamic>> _cursos = [
    {'nombre': 'Curso 1', 'selected': true, 'precio': 450.0},
    {'nombre': 'Curso 2', 'selected': true, 'precio': 380.0},
    {'nombre': 'Curso 3', 'selected': true, 'precio': 420.0},
    {'nombre': 'Curso 4', 'selected': true, 'precio': 390.0},
  ];

  double get _total => _cursos
      .where((c) => c['selected'] == true)
      .fold(0, (sum, c) => sum + c['precio']);

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),

              // Ícono persona
              Icon(Icons.person, size: 100, color: Colors.grey.shade400),

              const SizedBox(height: 16),

              // Título
              const Text(
                'Realiza tu pago de matrícula',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 24),

              // Lista de cursos
              ..._cursos.asMap().entries.map((entry) {
                final i = entry.key;
                final curso = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        curso['nombre'],
                        style: const TextStyle(fontSize: 15),
                      ),
                      Checkbox(
                        value: curso['selected'],
                        onChanged: (v) =>
                            setState(() => _cursos[i]['selected'] = v ?? false),
                        activeColor: const Color.fromARGB(255, 185, 109, 255),
                        side: const BorderSide(
                          color: Color.fromARGB(255, 185, 109, 255),
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const Divider(height: 32),

              // Total a pagar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total a pagar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'S/ ${_total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 185, 109, 255),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Nota informativa
              const Text(
                'Recuerda que al proceder al pago, confirmas tu selección de cursos y tu compromiso de matrícula.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 40),

              // Botón Proceder al pago
              Center(
                child: GestureDetector(
                  onTap: () async {
                    await context.read<AppState>().completarPaso3();
                    if (!mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PaymentConfirmedScreen(),
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
                      'Proceder al pago',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
