import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'roadmap_screen.dart';
import '../widgets/main_scaffold.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Obtiene el usuario actual de Firebase
    final user = FirebaseAuth.instance.currentUser;
    final String nombre = user?.displayName ?? user?.email ?? 'Estudiante';
    final String nombreCorto = nombre
        .split(' ')
        .first; // ✅ Solo el primer nombre

    return MainScaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Image.asset('assets/images/foto-home.png', height: 220),
            ),
            const SizedBox(height: 35),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¡Hola $nombreCorto!',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 35),
                    const Text(
                      'Vive tu proceso de matrícula como una\naventura con STARTEC.',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '¡Supera todos los niveles para asegurar una experiencia positiva hasta el inicio de clases!',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                        height: 1.5,
                      ),
                    ),
                    const Spacer(),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RoadmapScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 185, 109, 255),
                            borderRadius: BorderRadius.circular(40),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(255, 132, 57, 231),
                                offset: const Offset(3, 6),
                                blurRadius: 3,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: const Text(
                            'Quiero empezar',
                            style: TextStyle(
                              fontSize: 18,
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
          ],
        ),
      ),
    );
  }
}
