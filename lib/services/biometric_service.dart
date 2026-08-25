import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();

  /// Comprueba si el dispositivo soporta biometría (huella / FaceID / biometría del sistema)
  static Future<bool> canCheckBiometrics() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
      return canAuthenticate;
    } catch (e) {
      debugPrint('[BiometricService] Error verificando soporte biométrico: $e');
      return false;
    }
  }

  /// Autentica con el hardware biométrico del dispositivo (Huella, FaceID o PIN de dispositivo)
  static Future<bool> authenticateWithBiometrics({
    String reason = 'Escanea tu rostro o huella para ingresar a STARTEC',
  }) async {
    try {
      final isSupported = await canCheckBiometrics();
      if (!isSupported) {
        debugPrint('[BiometricService] Dispositivo no soporta biometría.');
        return false;
      }

      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      debugPrint('[BiometricService] Error en autenticación biométrica: $e');
      return false;
    }
  }

  /// Simula el envío y registro de la biometría en la Base de Datos de TECSUP
  static Future<bool> sincronizarBiometriaConTecsup({
    required String dni,
    required String nombre,
    required bool terminosAceptados,
  }) async {
    // Simula la latencia de red al enviar el template biométrico / foto al backend de TECSUP
    await Future.delayed(const Duration(milliseconds: 600));
    debugPrint(
      '[TECSUP BD] Registro biométrico sincronizado con éxito para DNI: $dni ($nombre) - Protección de datos aceptada: $terminosAceptados',
    );
    return true;
  }
}
