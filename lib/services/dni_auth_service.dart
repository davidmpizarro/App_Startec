import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';

/// Datos del estudiante admitido desde Zoho / Admisión
class AdmitidoData {
  final String dni;
  final String nombre;
  final String carrera;
  const AdmitidoData({
    required this.dni,
    required this.nombre,
    required this.carrera,
  });
}

class DniNotFoundException implements Exception {
  final String message;
  DniNotFoundException([
    this.message = 'El DNI no está registrado en el sistema de admisión.',
  ]);

  @override
  String toString() => message;
}

/// Interfaz abstracta del servicio
abstract class DniAuthService {
  Future<AdmitidoData> loginWithDni(String dni, String password);
}

/// Implementación MOCK para pruebas locales mientras TI integra Zoho
class MockDniAuthService implements DniAuthService {
  static final Map<String, AdmitidoData> _admitidosRegistrados = {
    '12345678': const AdmitidoData(
      dni: '12345678',
      nombre: 'Antonio',
      carrera: 'Diseño y Desarrollo de Software',
    ),
    '87654321': const AdmitidoData(
      dni: '87654321',
      nombre: 'María',
      carrera: 'Administración de Redes y Comunicaciones',
    ),
    '70654321': const AdmitidoData(
      dni: '70654321',
      nombre: 'Carlos',
      carrera: 'Mecatrónica Industrial',
    ),
  };
  @override
  Future<AdmitidoData> loginWithDni(String dni, String password) async {
    // Simular latencia de red
    await Future.delayed(Duration(milliseconds: 600 + Random().nextInt(400)));
    final admitido = _admitidosRegistrados[dni];
    if (admitido == null) {
      throw DniNotFoundException(
        'El DNI $dni no se encuentra en el sistema de admisión. Contacta a tu asesor.',
      );
    }
    // Validación de contraseña (según TI, la contraseña inicial es el mismo DNI)
    if (password != dni) {
      throw Exception('La contraseña ingresada no coincide con el DNI.');
    }
    // Iniciar sesión anónima en Firebase y asignar el nombre
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      currentUser = userCredential.user;
    }
    await currentUser?.updateDisplayName(admitido.nombre);
    return admitido;
  }
}
