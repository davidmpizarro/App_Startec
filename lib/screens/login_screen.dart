import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'facial_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  bool _rememberMe = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  // ✅ Agrega estos controladores
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usuarioController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const FacialScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al iniciar sesión. Intenta de nuevo.';
        _isLoading = false;
      });
    }
  }

  Widget _buildUsuarioField() {
    return Container(
      constraints: const BoxConstraints(minHeight: 48, maxHeight: 60),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: _usuarioController,
        decoration: InputDecoration(
          hintText: 'Usuario',
          hintStyle: const TextStyle(color: Colors.black38, fontSize: 15),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 24,
            vertical: MediaQuery.of(context).size.height * 0.015,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      constraints: const BoxConstraints(minHeight: 48, maxHeight: 60),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        decoration: InputDecoration(
          hintText: 'Contraseña',
          hintStyle: const TextStyle(color: Colors.black38, fontSize: 15),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 24,
            vertical: MediaQuery.of(context).size.height * 0.015,
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.black38,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 185, 109, 255),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // STARTEC
              Center(
                child: Image.asset(
                  'assets/images/STARTEC-LOGO.png',
                  height: 100,
                ),
              ),
              const SizedBox(height: 0),
              const Center(
                child: Text(
                  'Inicia tu futuro aquí',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),

              const SizedBox(height: 28),

              // Label
              const Text(
                'Inicio de sesión',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // Campo Usuario (visual, decorativo)
              _buildUsuarioField(),
              const SizedBox(height: 12),

              // Campo Contraseña (visual, decorativo)
              _buildPasswordField(),
              const SizedBox(height: 12),

              // Recuérdame + ¿Olvidaste tu contraseña?
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
                  const Text(
                    '¿Olvidaste tu contraseña?',
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Botón INICIAR SESIÓN (negro)
              // Botón INICIAR SESIÓN (negro)
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          final usuario = _usuarioController.text.trim();
                          final password = _passwordController.text.trim();

                          if (usuario.isEmpty || password.isEmpty) {
                            setState(() {
                              _errorMessage = 'Completa todos los campos.';
                            });
                            return;
                          }

                          // ✅ Validar que sea correo @tecsup.edu.pe
                          if (!usuario.endsWith('@tecsup.edu.pe')) {
                            setState(() {
                              _errorMessage =
                                  'Solo se permiten cuentas @tecsup.edu.pe';
                            });
                            return;
                          }

                          setState(() {
                            _isLoading = true;
                            _errorMessage = null;
                          });

                          try {
                            // ✅ Autenticación real con Firebase
                            await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                                  email: usuario,
                                  password: password,
                                );

                            if (mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const FacialScreen(),
                                ),
                              );
                            }
                          } on FirebaseAuthException catch (e) {
                            setState(() {
                              // ✅ Mensajes de error en español según el código
                              switch (e.code) {
                                case 'user-not-found':
                                  _errorMessage =
                                      'No existe una cuenta con ese correo.';
                                  break;
                                case 'wrong-password':
                                  _errorMessage = 'Contraseña incorrecta.';
                                  break;
                                case 'invalid-email':
                                  _errorMessage = 'El correo no es válido.';
                                  break;
                                case 'user-disabled':
                                  _errorMessage =
                                      'Esta cuenta ha sido deshabilitada.';
                                  break;
                                default:
                                  _errorMessage =
                                      'Error al iniciar sesión. Intenta de nuevo.';
                              }
                              _isLoading = false;
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'INICIAR SESIÓN',
                          style: TextStyle(fontSize: 15, letterSpacing: 1.5),
                        ),
                ),
              ),

              const SizedBox(height: 12),

              // Botón GOOGLE (blanco)
              SizedBox(
                width: double.infinity,
                height: 54,
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
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF8B2FC9),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network(
                              'https://www.google.com/favicon.ico',
                              height: 20,
                              width: 20,
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

              if (_errorMessage != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade400,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_rounded, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 28),

              // Ilustración
              Center(
                child: Image.asset(
                  'assets/images/foto-login-startec.png',
                  height: 180,
                ),
              ),

              const SizedBox(height: 20),

              // Footer
              const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿No tienes acceso? ',
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                    const SizedBox(width: 30),
                    Text(
                      'Contacta a tu asesor.',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
