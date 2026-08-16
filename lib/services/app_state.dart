import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  bool paso1Bienvenida = true;
  bool paso2Perfil = false;
  bool paso3Documentos = false;
  bool paso4Matricula = false;
  bool paso5Carrera = false;
  bool paso6Campus = false;

  // ✅ Datos del perfil
  String nombreUsuario = '';
  String apellidosUsuario = '';
  String documentoUsuario = '';
  String nombrePadre = '';
  String nombreMadre = '';
  String direccionUsuario = '';
  String responsablePago = '';
  String correoResponsable = '';
  String telefonoResponsable = '';

  // ✅ Cargar estado guardado al iniciar
  Future<void> cargarEstado() async {
    final prefs = await SharedPreferences.getInstance();
    paso1Bienvenida = prefs.getBool('paso1') ?? true;
    paso2Perfil = prefs.getBool('paso2') ?? false;
    paso3Documentos = prefs.getBool('paso3') ?? false;
    paso4Matricula = prefs.getBool('paso4') ?? false;
    paso5Carrera = prefs.getBool('paso5') ?? false;
    paso6Campus = prefs.getBool('paso6') ?? false;

    // ✅ Carga datos del perfil
    nombreUsuario = prefs.getString('nombre') ?? '';
    apellidosUsuario = prefs.getString('apellidos') ?? '';
    documentoUsuario = prefs.getString('documento') ?? '';
    nombrePadre = prefs.getString('nombrePadre') ?? '';
    nombreMadre = prefs.getString('nombreMadre') ?? '';
    direccionUsuario = prefs.getString('direccion') ?? '';
    responsablePago = prefs.getString('responsablePago') ?? '';
    correoResponsable = prefs.getString('correoResponsable') ?? '';
    telefonoResponsable = prefs.getString('telefonoResponsable') ?? '';

    notifyListeners();
  }

  // ✅ completarPaso2 ahora guarda también los datos del perfil
  Future<void> completarPaso2({
    required String nombre,
    required String apellidos,
    required String documento,
    required String padre,
    required String madre,
    required String direccion,
    required String responsable,
    required String correo,
    required String telefono,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('paso2', true);
    await prefs.setString('nombre', nombre);
    await prefs.setString('apellidos', apellidos);
    await prefs.setString('documento', documento);
    await prefs.setString('nombrePadre', padre);
    await prefs.setString('nombreMadre', madre);
    await prefs.setString('direccion', direccion);
    await prefs.setString('responsablePago', responsable);
    await prefs.setString('correoResponsable', correo);
    await prefs.setString('telefonoResponsable', telefono);

    paso2Perfil = true;
    nombreUsuario = nombre;
    apellidosUsuario = apellidos;
    documentoUsuario = documento;
    nombrePadre = padre;
    nombreMadre = madre;
    direccionUsuario = direccion;
    responsablePago = responsable;
    correoResponsable = correo;
    telefonoResponsable = telefono;
    notifyListeners();
  }

  Future<void> completarPaso3() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('paso3', true);
    paso3Documentos = true;
    notifyListeners();
  }

  Future<void> completarPaso4() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('paso4', true);
    paso4Matricula = true;
    notifyListeners();
  }

  Future<void> completarPaso5() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('paso5', true);
    paso5Carrera = true;
    notifyListeners();
  }

  Future<void> completarPaso6() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('paso6', true);
    paso6Campus = true;
    notifyListeners();
  }

  // ✅ Útil para testing o cerrar sesión
  Future<void> resetearEstado() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    paso1Bienvenida = true;
    paso2Perfil = false;
    paso3Documentos = false;
    paso4Matricula = false;
    paso5Carrera = false;
    paso6Campus = false;
    nombreUsuario = '';
    apellidosUsuario = '';
    documentoUsuario = '';
    nombrePadre = '';
    nombreMadre = '';
    direccionUsuario = '';
    responsablePago = '';
    correoResponsable = '';
    telefonoResponsable = '';
    notifyListeners();
  }
}
