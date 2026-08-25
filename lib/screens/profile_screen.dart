import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'document_upload_screen.dart';
import '../widgets/main_scaffold.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color _brandPurple = Color.fromARGB(255, 185, 109, 255);

  bool _terminosAceptados = false;
  File? _fotoPerfil;

  final _nombres = TextEditingController();
  final _apellidos = TextEditingController();
  final _documento = TextEditingController();
  final _celular = TextEditingController();
  final _direccion = TextEditingController();
  final _distrito = TextEditingController();
  final _provincia = TextEditingController();
  final _departamento = TextEditingController();
  final _nombrePadre = TextEditingController();
  final _nombreMadre = TextEditingController();
  final _responsablePago = TextEditingController();
  final _correoResponsable = TextEditingController();
  final _telefonoResponsable = TextEditingController();

  @override
  void initState() {
    super.initState();
    // ✅ Se lee el AppState de forma síncrona, ANTES del primer build,
    // así la foto (y el resto de campos) aparecen correctos desde el
    // primer frame, sin parpadeo.
    final state = context.read<AppState>();
    _nombres.text = state.nombreUsuario;
    _apellidos.text = state.apellidosUsuario;
    _documento.text = state.documentoUsuario;
    _celular.text = state.celularUsuario;
    _direccion.text = state.direccionUsuario;
    _distrito.text = state.distritoUsuario;
    _provincia.text = state.provinciaUsuario;
    _departamento.text = state.departamentoUsuario;
    _nombrePadre.text = state.nombrePadre;
    _nombreMadre.text = state.nombreMadre;
    _responsablePago.text = state.responsablePago;
    _correoResponsable.text = state.correoResponsable;
    _telefonoResponsable.text = state.telefonoResponsable;
    _terminosAceptados = state.terminosDatosAceptados;
    if (state.fotoPerfilPath.isNotEmpty) {
      _fotoPerfil = File(state.fotoPerfilPath);
    }
  }

  @override
  void dispose() {
    _nombres.dispose();
    _apellidos.dispose();
    _documento.dispose();
    _celular.dispose();
    _direccion.dispose();
    _distrito.dispose();
    _provincia.dispose();
    _departamento.dispose();
    _nombrePadre.dispose();
    _nombreMadre.dispose();
    _responsablePago.dispose();
    _correoResponsable.dispose();
    _telefonoResponsable.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFoto() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: _brandPurple),
              title: const Text('Elegir de la galería'),
              onTap: () async {
                Navigator.pop(ctx);
                await _obtenerImagen(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera, color: _brandPurple),
              title: const Text('Tomar una foto'),
              onTap: () async {
                Navigator.pop(ctx);
                await _obtenerImagen(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _obtenerImagen(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? imagen = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 800,
    );
    if (imagen != null) {
      setState(() => _fotoPerfil = File(imagen.path));
      await context.read<AppState>().actualizarFotoPerfil(imagen.path);
    }
  }

  void _mostrarDialogoTerminos() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.privacy_tip_outlined, color: _brandPurple),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Aceptación de Datos Personales',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: const SingleChildScrollView(
          child: Text(
            'En cumplimiento con la Ley N° 29733 (Ley de Protección de Datos Personales de Perú) y su Reglamento:\n\n'
            '1. Los datos personales y de contacto que registras serán utilizados exclusivamente para gestionar tu proceso de admisión y matrícula en TECSUP.\n\n'
            '2. La información será almacenada de forma segura en los servidores institucionales de TECSUP.\n\n'
            '3. Puedes revocar o actualizar tus datos de acuerdo con los canales oficiales de atención de TECSUP.',
            style: TextStyle(fontSize: 13, height: 1.4, color: Colors.black87),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _terminosAceptados = true);
            },
            child: const Text(
              'Aceptar términos',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  bool get _camposCompletos =>
      _nombres.text.isNotEmpty &&
      _apellidos.text.isNotEmpty &&
      _documento.text.isNotEmpty &&
      _celular.text.isNotEmpty &&
      _direccion.text.isNotEmpty &&
      _distrito.text.isNotEmpty &&
      _provincia.text.isNotEmpty &&
      _departamento.text.isNotEmpty &&
      _nombrePadre.text.isNotEmpty &&
      _nombreMadre.text.isNotEmpty &&
      _responsablePago.text.isNotEmpty &&
      _correoResponsable.text.isNotEmpty &&
      _telefonoResponsable.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),

              // ✅ Avatar editable (toca para cambiar la foto)
              Center(
                child: GestureDetector(
                  onTap: _seleccionarFoto,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: _fotoPerfil != null
                            ? FileImage(_fotoPerfil!) as ImageProvider
                            : const AssetImage('assets/images/student.png'),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: _brandPurple,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              const Text(
                'Actualiza tu perfil',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Se pide completar / actualizar tus datos personales.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              _buildField('Nombres', _nombres),
              _buildField('Apellidos', _apellidos),
              _buildField('Documento de identidad', _documento),
              _buildField('Celular', _celular),
              _buildField('Dirección', _direccion),
              _buildField('Distrito', _distrito),
              _buildField('Provincia', _provincia),
              _buildField('Departamento', _departamento),
              _buildField('Nombre y Apellidos de la Madre', _nombreMadre),
              _buildField('Nombre y Apellidos del Padre', _nombrePadre),
              _buildField('Responsable del pago', _responsablePago),
              _buildField(
                'Correo del Responsable del Pago',
                _correoResponsable,
              ),
              _buildField(
                'Celular del Responsable del Pago',
                _telefonoResponsable,
              ),

              const SizedBox(height: 16),

              // ✅ Aceptación de términos y condiciones (Datos Personales)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: _terminosAceptados,
                      activeColor: _brandPurple,
                      onChanged: (val) {
                        setState(() => _terminosAceptados = val ?? false);
                      },
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: _mostrarDialogoTerminos,
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                            children: [
                              TextSpan(text: 'Acepto los '),
                              TextSpan(
                                text:
                                    'términos y condiciones para la protección de datos personales',
                                style: TextStyle(
                                  color: _brandPurple,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Center(
                child: GestureDetector(
                  onTap: () async {
                    if (!_camposCompletos) {
                      _mostrarError(
                        'Por favor completa todos los campos antes de continuar.',
                      );
                      return;
                    }

                    if (!_terminosAceptados) {
                      _mostrarError(
                        'Debes aceptar los términos de protección de datos personales.',
                      );
                      return;
                    }

                    await context.read<AppState>().completarPaso2(
                      nombre: _nombres.text,
                      apellidos: _apellidos.text,
                      documento: _documento.text,
                      celular: _celular.text,
                      direccion: _direccion.text,
                      distrito: _distrito.text,
                      provincia: _provincia.text,
                      departamento: _departamento.text,
                      padre: _nombrePadre.text,
                      madre: _nombreMadre.text,
                      responsable: _responsablePago.text,
                      correo: _correoResponsable.text,
                      telefono: _telefonoResponsable.text,
                      terminosAceptados: _terminosAceptados,
                    );
                    if (!mounted) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DocumentUploadScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: _brandPurple,
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

  void _mostrarError(String mensaje) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(
          Icons.warning_amber_rounded,
          color: _brandPurple,
          size: 48,
        ),
        content: Text(
          mensaje,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15, color: Colors.black87),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: _brandPurple,
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
  }

  Widget _buildField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 44,
            decoration: BoxDecoration(
              border: Border.all(color: _brandPurple, width: 1.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: controller,
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
