import 'package:flutter/material.dart';
import 'courses_screen.dart';
import '../widgets/main_scaffold.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _documentosPendientes = true;

  final _nombres = TextEditingController();
  final _apellidos = TextEditingController();
  final _documento = TextEditingController();
  final _nombrePadre = TextEditingController();
  final _nombreMadre = TextEditingController();
  final _direccion = TextEditingController();
  final _responsablePago = TextEditingController();
  final _correoResponsable = TextEditingController();
  final _telefonoResponsable = TextEditingController();

  // ✅ Precarga los datos guardados
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<AppState>();
      _nombres.text = state.nombreUsuario;
      _apellidos.text = state.apellidosUsuario;
      _documento.text = state.documentoUsuario;
      _nombrePadre.text = state.nombrePadre;
      _nombreMadre.text = state.nombreMadre;
      _direccion.text = state.direccionUsuario;
      _responsablePago.text = state.responsablePago;
      _correoResponsable.text = state.correoResponsable;
      _telefonoResponsable.text = state.telefonoResponsable;
    });
  }

  @override
  void dispose() {
    _nombres.dispose();
    _apellidos.dispose();
    _documento.dispose();
    _nombrePadre.dispose();
    _nombreMadre.dispose();
    _direccion.dispose();
    _responsablePago.dispose();
    _correoResponsable.dispose();
    _telefonoResponsable.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),

              Icon(Icons.person, size: 100, color: Colors.grey.shade400),

              const SizedBox(height: 16),

              const Text(
                'Actualiza tu perfil',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 24),

              _buildField('Nombres', _nombres),
              _buildField('Apellidos', _apellidos),
              _buildField('Documento de identidad', _documento),
              _buildField('Nombre del padre', _nombrePadre),
              _buildField('Nombre de la madre', _nombreMadre),
              _buildField('Dirección', _direccion),
              _buildField('Responsable del pago', _responsablePago),
              _buildField('Correo del responsable', _correoResponsable),
              _buildField('Teléfono del responsable', _telefonoResponsable),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Documentos pendientes',
                    style: TextStyle(fontSize: 15),
                  ),
                  Checkbox(
                    value: _documentosPendientes,
                    onChanged: (v) =>
                        setState(() => _documentosPendientes = v ?? false),
                    activeColor: const Color.fromARGB(255, 185, 109, 255),
                    side: const BorderSide(
                      color: Color.fromARGB(255, 185, 109, 255),
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Center(
                child: GestureDetector(
                  onTap: () async {
                    if (_nombres.text.isEmpty ||
                        _apellidos.text.isEmpty ||
                        _documento.text.isEmpty ||
                        _nombrePadre.text.isEmpty ||
                        _nombreMadre.text.isEmpty ||
                        _direccion.text.isEmpty ||
                        _responsablePago.text.isEmpty ||
                        _correoResponsable.text.isEmpty ||
                        _telefonoResponsable.text.isEmpty) {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: const Icon(
                            Icons.warning_amber_rounded,
                            color: Color.fromARGB(255, 185, 109, 255),
                            size: 48,
                          ),
                          content: const Text(
                            'Por favor completa todos los campos antes de continuar.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                          actionsAlignment: MainAxisAlignment.center,
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(
                                    255,
                                    185,
                                    109,
                                    255,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Entendido',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                      return;
                    }

                    // ✅ Pasa los datos al guardar
                    await context.read<AppState>().completarPaso2(
                      nombre: _nombres.text,
                      apellidos: _apellidos.text,
                      documento: _documento.text,
                      padre: _nombrePadre.text,
                      madre: _nombreMadre.text,
                      direccion: _direccion.text,
                      responsable: _responsablePago.text,
                      correo: _correoResponsable.text,
                      telefono: _telefonoResponsable.text,
                    );
                    if (!mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CoursesScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 185, 109, 255),
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromARGB(255, 132, 57, 231),
                          offset: Offset(3, 6),
                          blurRadius: 3,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Text(
                      'Siguiente',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
          Expanded(
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color.fromARGB(255, 185, 109, 255),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: TextField(
                controller: controller,
                style: const TextStyle(fontSize: 13),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
