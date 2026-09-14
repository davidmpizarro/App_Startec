import 'package:flutter/material.dart';
import '../screens/roadmap_screen.dart';
import '../screens/profile_screen.dart';
import '../widgets/chat_bot_sheet.dart';
import '../widgets/app_drawer.dart';
import '../screens/payments_screen.dart';

class MainScaffold extends StatelessWidget {
  final Widget body;
  final Color backgroundColor;

  const MainScaffold({
    super.key,
    required this.body,
    this.backgroundColor = Colors.white,
  });

  static const double _barBaseHeight = 60;

  // 👈 NUEVO: helper para que cualquier screen sepa cuánto padding
  // inferior necesita su ScrollView para no quedar tapado por la barra.
  // Úsalo así en tus screens (ej. DocumentUploadScreen):
  //
  // padding: EdgeInsets.only(
  //   left: 20, right: 20, top: 16,
  //   bottom: MainScaffold.bottomBarHeight(context) + 20,
  // ),
  static double bottomBarHeight(BuildContext context) {
    return _barBaseHeight + MediaQuery.of(context).padding.bottom;
  }

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
    return Scaffold(
      backgroundColor: backgroundColor,
      drawer: const AppDrawer(),
      body: body,
      bottomNavigationBar: Container(
        // 👈 único cambio real vs tu original: sumamos el safe area
        // inferior del sistema (gesture bar) para que la franja púrpura
        // no quede pegada/comida por el indicador de home en celulares
        // con navegación por gestos.
        height: _barBaseHeight + MediaQuery.of(context).padding.bottom,
        color: const Color.fromARGB(255, 185, 109, 255),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              bottom: MediaQuery.of(
                context,
              ).padding.bottom, // 👈 deja los íconos en los 60px de arriba
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
                  const SizedBox(width: 70),
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
                  Builder(
                    builder: (context) => GestureDetector(
                      onTap: () => Scaffold.of(context).openDrawer(),
                      child: const Icon(
                        Icons.menu,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 👈 exactamente tu posicionamiento original del bot, sin tocar
            Positioned(
              top: -28,
              left: 65,
              right: 120,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 44),
                  child: GestureDetector(
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
}
