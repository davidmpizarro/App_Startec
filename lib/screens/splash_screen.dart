import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmall = constraints.maxHeight < 680;

            return Padding(
              padding: EdgeInsets.symmetric(vertical: isSmall ? 20 : 36),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logos arriba
                  Column(
                    children: [
                      Image.asset(
                        'assets/images/logo-splash-tecsup.png',
                        height: isSmall ? 40 : 50,
                      ),
                      SizedBox(height: isSmall ? 20 : 28),
                      Image.asset(
                        'assets/images/logo-splash-startec.png',
                        height: isSmall ? 40 : 50,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Loading bar en medio
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: const LinearProgressIndicator(
                        minHeight: 8,
                        backgroundColor: Colors.black,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF00BCD4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Ilustración abajo
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Image.asset(
                      'assets/images/foto-splash.png',
                      height: isSmall ? 150 : 200,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
