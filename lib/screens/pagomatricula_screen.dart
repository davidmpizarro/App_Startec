import 'package:flutter/material.dart';
import '../widgets/main_scaffold.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import 'pasarela_pagos_screen.dart';

class PagoMatriculaScreen extends StatefulWidget {
  const PagoMatriculaScreen({super.key});

  @override
  State<PagoMatriculaScreen> createState() => _PagoMatriculaScreenState();
}

class _PagoMatriculaScreenState extends State<PagoMatriculaScreen> {
  final List<Map<String, dynamic>> _conceptos = [
    {'nombre': 'Matrícula', 'selected': true, 'precio': 550.0},
    {
      'nombre': '1° cuota del semestre',
      'selected': true,
      'precio': 550.0,
    },
  ];

  double get _total => _conceptos
      .where((c) => c['selected'] == true)
      .fold(0.0, (sum, c) => sum + (c['precio'] as double));

  bool get _hayAlgunSeleccionado => _conceptos.any((c) => c['selected'] == true);

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 14),

              // Ícono persona
              Icon(Icons.person, size: 100, color: Colors.grey.shade400),

              const SizedBox(height: 14),

              // Título
              const Text(
                'Realiza tu pago de matrícula',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              // Conceptos a pagar (Matrícula y 1° cuota del semestre)
              ..._conceptos.asMap().entries.map((entry) {
                final i = entry.key;
                final concepto = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          concepto['nombre'],
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                      Checkbox(
                        value: concepto['selected'],
                        onChanged: (v) =>
                            setState(() => _conceptos[i]['selected'] = v ?? false),
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
                'Recuerda que al proceder al pago confirmas tu compromiso con la matrícula.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),

              // Mensaje de advertencia si no hay conceptos seleccionados
              if (!_hayAlgunSeleccionado)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    'Debes seleccionar al menos un concepto para continuar.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

              const SizedBox(height: 40),

              // Botón Proceder al pago
              Center(
                child: GestureDetector(
                  onTap: _hayAlgunSeleccionado
                      ? () async {
                          final appState = context.read<AppState>();
                          final navigator = Navigator.of(context);
                          await appState.completarPaso4PagoMatricula();
                          if (!mounted) return;
                          navigator.push(
                            MaterialPageRoute(
                              builder: (_) => const PasarelaPagosScreen(),
                            ),
                          );
                        }
                      : null,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _hayAlgunSeleccionado ? 1.0 : 0.4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 185, 109, 255),
                        borderRadius: BorderRadius.circular(40),
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
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
