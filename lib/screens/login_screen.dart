import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'facial_screen.dart';
import 'home_screen.dart';
import '../services/dni_auth_service.dart';
import '../services/app_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final DniAuthService _dniAuthService = MockDniAuthService();
  bool _isLoading = false;
  bool _rememberMe = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  @override
  void dispose() {
    _usuarioController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Iniciar sesión con DNI (según indicación de TI / Zoho)
  Future<void> _handleDniLogin() async {
    final usuario = _usuarioController.text.trim();
    final password = _passwordController.text.trim();
    // 1. Validaciones básicas
    if (usuario.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor ingresa tu DNI y Contraseña.';
      });
      return;
    }
    // Si el usuario ingresó un correo institucional @tecsup.edu.pe
    if (usuario.contains('@')) {
      if (!usuario.endsWith('@tecsup.edu.pe')) {
        setState(() {
          _errorMessage =
              'Solo se permiten cuentas @tecsup.edu.pe o tu número de DNI.';
        });
        return;
      }
      await _loginWithFirebaseEmail(usuario, password);
      return;
    }
    // 2. Validación de formato de DNI (8 dígitos)
    if (usuario.length != 8 || int.tryParse(usuario) == null) {
      setState(() {
        _errorMessage = 'El DNI debe contener exactamente 8 dígitos numéricos.';
      });
      return;
    }
    // 3. Validación de contraseña igual a DNI
    if (password != usuario) {
      setState(() {
        _errorMessage =
            'Para nuevos ingresantes, la contraseña es tu mismo DNI.';
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // 4. Consulta a la base de admisión / Zoho
      final admitido = await _dniAuthService.loginWithDni(usuario, password);
      // 5. Guardar datos en AppState para que estén disponibles en el resto de pantallas
      final appState = context.read<AppState>();
      await appState.setUsuarioAdmitido(
        nombre: admitido.nombre,
        documento: admitido.dni,
        carrera: admitido.carrera,
      );
      if (!mounted) return;

      // 6. Si ya tiene biometría va a HomeScreen, si es primer ingreso va a FacialScreen
      if (appState.biometriaRegistrada) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const FacialScreen()),
        );
      }
    } on DniNotFoundException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  /// Iniciar sesión con Reconocimiento Facial (Opción 2 de ingreso)
  void _handleBiometricLogin() {
    final appState = context.read<AppState>();

    if (!appState.biometriaRegistrada) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Aún no has registrado tu rostro. Ingresa primero con tu DNI para capturar tu foto.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Abre directamente la cámara frontal para Reconocimiento Facial (sin PIN del sistema)
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FacialScreen(isLoginMode: true)),
    );
  }

  /// Autenticación directa con Firebase Email si se ingresó correo
  Future<void> _loginWithFirebaseEmail(String email, String password) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const FacialScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'user-not-found':
            _errorMessage = 'No existe una cuenta con ese correo.';
            break;
          case 'wrong-password':
            _errorMessage = 'Contraseña incorrecta.';
            break;
          default:
            _errorMessage = 'Error al iniciar sesión. Intenta de nuevo.';
        }
        _isLoading = false;
      });
    }
  }

  /// Inicio de sesión con Google institucional (@tecsup.edu.pe)
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }
      if (!googleUser.email.endsWith('@tecsup.edu.pe')) {
        await GoogleSignIn().signOut();
        setState(() {
          _errorMessage = 'Solo se permiten cuentas @tecsup.edu.pe';
          _isLoading = false;
        });
        return;
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      if (!mounted) return;

      final appState = context.read<AppState>();
      final nombreGoogle =
          googleUser.displayName ?? userCredential.user?.displayName ?? '';

      await appState.setUsuarioAdmitido(
        nombre: nombreGoogle,
        documento: appState.documentoUsuario,
        carrera: appState.carreraUsuario.isNotEmpty
            ? appState.carreraUsuario
            : null,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const FacialScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al conectar con Google. Intenta de nuevo.';
        _isLoading = false;
      });
    }
  }

  void _showAsesorContactDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Contacto de Asesor'),
        content: const Text(
          'Si eres un alumno admitido y tu DNI no figura en el sistema de admisión, comunícate con tu asesor educativo o al correo de admisión:\n\nadmision@tecsup.edu.pe',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  Widget _buildUsuarioField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _usuarioController,
        keyboardType: TextInputType.text,
        decoration: const InputDecoration(
          hintText: 'Usuario',
          hintStyle: TextStyle(color: Colors.black38, fontSize: 15),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        decoration: InputDecoration(
          hintText: 'Contraseña',
          hintStyle: const TextStyle(color: Colors.black38, fontSize: 15),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.black45,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
      ),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB96DFF),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmall = constraints.maxHeight < 680;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: isSmall ? 8 : 16),
                  // Logo STARTEC y subtítulo
                  Center(
                    child: Image.asset(
                      'assets/images/STARTEC-LOGO.png',
                      height: isSmall ? 70 : 85,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const Center(
                    child: Text(
                      'Inicia tu futuro aquí',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  SizedBox(height: isSmall ? 18 : 26),
                  // Título "Inicio de sesión"
                  const Text(
                    'Inicio de sesión',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: isSmall ? 14 : 18),
              // Campo Usuario (DNI)
              _buildUsuarioField(),
              const SizedBox(height: 14),
              // Campo Contraseña (DNI)
              _buildPasswordField(),
              const SizedBox(height: 12),
              // Fila Recuérdame + ¿Olvidaste tu contraseña?
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (v) =>
                            setState(() => _rememberMe = v ?? false),
                        fillColor: WidgetStateProperty.all(Colors.white),
                        checkColor: const Color(0xFF8B2FC9),
                        side: const BorderSide(color: Colors.white),
                      ),
                      const Text(
                        'Recuérdame',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Para nuevos ingresantes, tu contraseña es tu número de DNI.',
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      '¿Olvidaste tu contraseña?',
                      style: TextStyle(color: Colors.black87, fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Botón INICIAR SESIÓN (Negro)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleDniLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 3,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'INICIAR SESIÓN',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              // Botón Ingreso con Biométrico (Opción 2 de ingreso)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _handleBiometricLogin,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.18),
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  icon: const Icon(
                    Icons.face_retouching_natural,
                    size: 22,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Ingresar con Biométrico',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Botón Continuar con Google (Blanco)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signInWithGoogle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        'https://www.google.com/favicon.ico',
                        height: 20,
                        width: 20,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.g_mobiledata, size: 24),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Continuar con Google',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Mensaje de Error
              if (_errorMessage != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade600,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
                SizedBox(height: isSmall ? 16 : 24),
                // Ilustración
                Center(
                  child: Image.asset(
                    'assets/images/foto-login-startec.png',
                    height: isSmall ? 130 : 160,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(height: isSmall ? 14 : 20),
                // Footer: ¿No tienes acceso? Contacta a tu asesor.
                Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '¿No tienes acceso? ',
                          style: TextStyle(color: Colors.black87, fontSize: 14),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _showAsesorContactDialog,
                          child: const Text(
                            'Contacta a tu asesor.',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    ),
  );
}
}
