import 'package:flutter/material.dart';
import '../widgets/main_scaffold.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import 'document_upload_screen.dart';
import 'pagomatricula_screen.dart';
import 'explora_tecsup_screen.dart';
import 'estado_admision_screen.dart';
import 'otros_tramites_screen.dart';
import 'mis_horarios_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<AppState>().completarPaso8Campus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
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

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.95,
                  children: [
                    _buildCard(
                      icon: Icons.assignment_ind,
                      label: 'Estado de Admisión',
                      subtitle: 'Ingresante',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EstadoAdmisionScreen(),
                        ),
                      ),
                    ),
                    _buildCard(
                      icon: Icons.folder,
                      label: 'Documentos',
                      subtitle: 'Entregado o Pendiente',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DocumentUploadScreen(),
                        ),
                      ),
                    ),
                    _buildCard(
                      icon: Icons.credit_card,
                      label: 'Mis Pagos',
                      subtitle: 'Matrícula y Cuotas',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PagoMatriculaScreen(),
                        ),
                      ),
                    ),
                    _buildCard(
                      icon: Icons.school,
                      label: 'Explora Tecsup',
                      subtitle: '360° Campus',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ExploraTecsupScreen(),
                        ),
                      ),
                    ),
                    _buildCard(
                      icon: Icons.list_alt,
                      label: 'Otros Trámites',
                      subtitle: 'Crédito educativo y Becas',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OtrosTramitesScreen(),
                        ),
                      ),
                    ),
                    _buildCard(
                      icon: Icons.access_time,
                      label: 'Mis Horarios',
                      subtitle: 'Ciclo 2026-I',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MisHorariosScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    String? subtitle,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50,
              color: const Color.fromARGB(255, 185, 109, 255),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color.fromARGB(255, 185, 109, 255),
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
