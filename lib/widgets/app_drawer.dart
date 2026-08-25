import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import '../screens/login_screen.dart';
import '../screens/payments_screen.dart';
import '../screens/estado_admision_screen.dart';
import '../screens/document_upload_screen.dart';
import '../screens/explora_tecsup_screen.dart';
import '../screens/otros_tramites_screen.dart';
import '../screens/mis_horarios_screen.dart';
import '../services/app_state.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final user = FirebaseAuth.instance.currentUser;
    final String nombreCompleto = appState.nombreUsuario.isNotEmpty
        ? appState.nombreUsuario
        : (user?.displayName ?? user?.email ?? 'Estudiante');
    final String nombreCorto = nombreCompleto.split(' ').first;

    return Drawer(
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
          _drawerItem(context, Icons.assignment, 'Estado de Admisión', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EstadoAdmisionScreen()),
            );
          }),
          _drawerItem(context, Icons.folder, 'Documentos', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DocumentUploadScreen()),
            );
          }),
          _drawerItem(context, Icons.credit_card, 'Mis Pagos', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PaymentsScreen()),
            );
          }),
          _drawerItem(context, Icons.public, 'Explora Tecsup', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ExploraTecsupScreen()),
            );
          }),
          _drawerItem(context, Icons.list_alt, 'Otros Trámites', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OtrosTramitesScreen()),
            );
          }),
          _drawerItem(context, Icons.schedule, 'Mis Horarios', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MisHorariosScreen()),
            );
          }),
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
    );
  }

  ListTile _drawerItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: const Color.fromARGB(255, 185, 109, 255)),
      title: Text(title),
      onTap: onTap,
    );
  }
}
