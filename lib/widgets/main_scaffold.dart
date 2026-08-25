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
    // 👈 ya no hay "final scaffoldKey = GlobalKey<ScaffoldState>();" aquí

    return Scaffold(
      // 👈 ya no hay "key: scaffoldKey" aquí
      backgroundColor: backgroundColor,
      drawer:
          const AppDrawer(), // 👈 en vez de todo el Drawer(child: Column(...)) escrito a mano
      body: body,
      bottomNavigationBar: Container(
        height: 60,
        color: const Color.fromARGB(255, 185, 109, 255),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
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
                    // 👈 en vez de "onTap: () => scaffoldKey.currentState?.openDrawer()"
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
