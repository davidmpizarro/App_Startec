import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../screens/login_screen.dart';
import '../screens/roadmap_screen.dart';
import '../screens/profile_screen.dart';
import '../widgets/chat_bot_sheet.dart';
import '../screens/payments_screen.dart';

class MainScaffold extends StatelessWidget {
  final Widget body;
  final Color backgroundColor;

  const MainScaffold({
    super.key,
    required this.body,
    this.backgroundColor = Colors.white,
  });

  // Agregar esta función dentro de MainScaffold
  void _abrirChatBot(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ChatBotSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    final user = FirebaseAuth.instance.currentUser;
    final String nombre = user?.displayName ?? user?.email ?? 'Estudiante';
    final String nombreCorto = nombre.split(' ').first;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: backgroundColor,

      // ✅ Drawer reutilizable
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              color: const Color.fromARGB(255, 185, 109, 255),
              child: SafeArea(
                child: Text(
                  'Hola, $nombreCorto',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            _drawerItem(Icons.assignment, 'Estado de Admisión', () {}),
            _drawerItem(Icons.folder, 'Documentos', () {}),
            _drawerItem(Icons.credit_card, 'Mis Pagos', () {}),
            _drawerItem(Icons.school, 'Explora Tecsup', () {}),
            _drawerItem(Icons.list_alt, 'Otros Trámites', () {}),
            _drawerItem(Icons.schedule, 'Mis Horarios', () {}),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Cerrar sesión',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                await GoogleSignIn().signOut();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),

      body: body,

      // ✅ Bottom nav reutilizable
      bottomNavigationBar: Container(
        height: 60,
        color: const Color.fromARGB(255, 185, 109, 255),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Íconos de navegación
            Positioned.fill(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 70), // espacio para el bot
                  GestureDetector(
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const RoadmapScreen()),
                    ),
                    child: const Icon(
                      Icons.home,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PaymentsScreen()),
                    ),
                    child: const Icon(
                      Icons.credit_card,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => scaffoldKey.currentState?.openDrawer(),
                    child: const Icon(
                      Icons.menu,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: -28,
              left: 65,
              right: 120,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 44),
                  child: GestureDetector(
                    // 👈 agrega esto
                    onTap: () => _abrirChatBot(context),
                    child: Image.asset(
                      'assets/images/icon-bot1.png',
                      width: 78,
                      height: 78,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ListTile _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color.fromARGB(255, 185, 109, 255)),
      title: Text(title),
      onTap: onTap,
    );
  }
}
