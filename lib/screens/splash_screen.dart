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
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logos arriba
              Column(
                children: [
                  Image.asset(
                    'assets/images/logo-splash-tecsup.png',
                    height: 50,
                  ),
                  const SizedBox(height: 30),
                  Image.asset(
                    'assets/images/logo-splash-startec.png',
                    height: 50,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Loading bar en medio
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 100),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: const LinearProgressIndicator(
                    minHeight: 10,
                    backgroundColor: Colors.black,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF00BCD4),
                    ),
                  ),
                ),
              ),
              // Ilustración abajo
              Padding(
                padding: const EdgeInsets.only(bottom: 20), // 👈 sube la imagen
                child: Image.asset(
                  'assets/images/foto-splash.png',
                  height: 200,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
