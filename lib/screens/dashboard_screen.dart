import 'package:flutter/material.dart';
import '../widgets/main_scaffold.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // ✅ Se completa al entrar a la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<AppState>().completarPaso6();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header con back + título
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back, size: 28),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      '¡Tu futuro en Tecsup ha iniciado!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Grid de opciones
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildCard(Icons.assignment_ind, 'Estado de Admisión'),
                    _buildCard(Icons.storage, 'Documentos'),
                    _buildCard(Icons.credit_card, 'Mis Pagos'),
                    _buildCard(Icons.school, 'Explora Tecsup'),
                    _buildCard(Icons.volunteer_activism, 'Otros Trámites'),
                    _buildCard(Icons.calendar_month, 'Mis Horarios'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(IconData icon, String label) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60, color: const Color.fromARGB(255, 185, 109, 255)),
          const SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
