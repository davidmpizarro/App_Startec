import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'roadmap_screen.dart';
import '../widgets/main_scaffold.dart';
import '../services/app_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Obtiene el usuario actual de AppState (o fallback a Firebase)
    final appState = context.watch<AppState>();
    final user = FirebaseAuth.instance.currentUser;
    final String nombreCompleto = appState.nombreUsuario.isNotEmpty
        ? appState.nombreUsuario
        : (user?.displayName ?? user?.email ?? 'Estudiante');
    final String nombreCorto = nombreCompleto
        .split(' ')
        .first; // ✅ Solo el primer nombre (ej. "Antonio")

    return MainScaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxHeight < 680;
            final imageHeight = isSmallScreen ? 160.0 : 210.0;
            final verticalSpacing = isSmallScreen ? 18.0 : 28.0;

            return SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MainScaffold.bottomBarHeight(context) + 20,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: isSmallScreen ? 20 : 36),
                        child: Image.asset(
                          'assets/images/foto-home.png',
                          height: imageHeight,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: verticalSpacing),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '¡Hola $nombreCorto!',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 24 : 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 18 : 24),
                            const Text(
                              'Vive tu proceso de matrícula como una\naventura con STARTEC.',
                              style: TextStyle(
                                fontSize: 14.5,
                                color: Colors.black,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              '¡Supera todos los niveles para asegurar una experiencia positiva hasta el inicio de clases!',
                              style: TextStyle(
                                fontSize: 14.5,
                                color: Colors.black,
                                height: 1.45,
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 24 : 32),
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
                                    horizontal: 28,
                                    vertical: 13,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                      255,
                                      185,
                                      109,
                                      255,
                                    ),
                                    borderRadius: BorderRadius.circular(40),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color.fromARGB(
                                          255,
                                          132,
                                          57,
                                          231,
                                        ),
                                        offset: Offset(3, 6),
                                        blurRadius: 3,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: const Text(
                                    'Quiero empezar',
                                    style: TextStyle(
                                      fontSize: 17,
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
