import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  bool paso1Bienvenida = true;
  bool paso2Perfil = false;
  bool paso3Documentos = false;
  bool paso4PagoMatricula = false; // ✅ nuevo (antes era CoursesScreen suelto)
  bool paso5Pasarela = false; // ✅ nuevo
  bool paso6Confirmacion = false; // ✅ antes era paso4Matricula
  bool paso7Carrera = false; // ✅ antes era paso5Carrera
  bool paso8Campus = false; // ✅ antes era paso6Campus

  // ✅ Estado de Biometría
  bool biometriaRegistrada = false;
  bool terminosBiometricosAceptados = false;

  // ✅ Datos del perfil
  String nombreUsuario = '';
  String apellidosUsuario = '';
  String documentoUsuario = '';
  String carreraUsuario = '';
  String nombrePadre = '';
  String nombreMadre = '';
  String direccionUsuario = '';
  String responsablePago = '';
  String correoResponsable = '';
  String telefonoResponsable = '';
  String celularUsuario = '';
  String distritoUsuario = '';
  String provinciaUsuario = '';
  String departamentoUsuario = '';
  bool terminosDatosAceptados = false;

  // ✅ Foto de perfil (ruta local del archivo)
  String fotoPerfilPath = '';

  Future<void> cargarEstado() async {
    final prefs = await SharedPreferences.getInstance();
    paso1Bienvenida = prefs.getBool('paso1') ?? true;
    paso2Perfil = prefs.getBool('paso2') ?? false;
    paso3Documentos = prefs.getBool('paso3') ?? false;
    paso4PagoMatricula = prefs.getBool('paso4') ?? false;
    paso5Pasarela = prefs.getBool('paso5') ?? false;
    paso6Confirmacion = prefs.getBool('paso6') ?? false;
    paso7Carrera = prefs.getBool('paso7') ?? false;
    paso8Campus = prefs.getBool('paso8') ?? false;

    nombreUsuario = prefs.getString('nombre') ?? '';
    apellidosUsuario = prefs.getString('apellidos') ?? '';
    documentoUsuario = prefs.getString('documento') ?? '';
    carreraUsuario = prefs.getString('carrera') ?? '';
    nombrePadre = prefs.getString('nombrePadre') ?? '';
    nombreMadre = prefs.getString('nombreMadre') ?? '';
    direccionUsuario = prefs.getString('direccion') ?? '';
    responsablePago = prefs.getString('responsablePago') ?? '';
    correoResponsable = prefs.getString('correoResponsable') ?? '';
    telefonoResponsable = prefs.getString('telefonoResponsable') ?? '';
    celularUsuario = prefs.getString('celular') ?? '';
    distritoUsuario = prefs.getString('distrito') ?? '';
    provinciaUsuario = prefs.getString('provincia') ?? '';
    departamentoUsuario = prefs.getString('departamento') ?? '';
    terminosDatosAceptados = prefs.getBool('terminosDatosAceptados') ?? false;
    fotoPerfilPath = prefs.getString('fotoPerfilPath') ?? '';

    if (documentoUsuario.isNotEmpty) {
      biometriaRegistrada =
          prefs.getBool('biometria_$documentoUsuario') ?? false;
      terminosBiometricosAceptados =
          prefs.getBool('terminos_$documentoUsuario') ?? false;
    } else {
      biometriaRegistrada = false;
      terminosBiometricosAceptados = false;
    }

    notifyListeners();
  }

  Future<void> registrarBiometria({required bool aceptoTerminos}) async {
    final prefs = await SharedPreferences.getInstance();
    if (documentoUsuario.isNotEmpty) {
      await prefs.setBool('biometria_$documentoUsuario', true);
      await prefs.setBool('terminos_$documentoUsuario', aceptoTerminos);
    }
    await prefs.setBool('biometriaRegistrada', true);
    biometriaRegistrada = true;
    terminosBiometricosAceptados = aceptoTerminos;
    notifyListeners();
  }

  Future<void> setUsuarioAdmitido({
    required String nombre,
    required String documento,
    String? carrera,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nombre', nombre);
    await prefs.setString('documento', documento);
    if (carrera != null) {
      await prefs.setString('carrera', carrera);
      carreraUsuario = carrera;
    }
    nombreUsuario = nombre;
    documentoUsuario = documento;

    biometriaRegistrada = prefs.getBool('biometria_$documento') ?? false;
    terminosBiometricosAceptados =
        prefs.getBool('terminos_$documento') ?? false;

    notifyListeners();
  }

  Future<void> resetearBiometria({String? dni}) async {
    final prefs = await SharedPreferences.getInstance();
    final targetDni = dni ?? documentoUsuario;
    if (targetDni.isNotEmpty) {
      await prefs.remove('biometria_$targetDni');
      await prefs.remove('terminos_$targetDni');
    }
    await prefs.remove('biometriaRegistrada');
    await prefs.remove('terminosBiometricosAceptados');
    biometriaRegistrada = false;
    terminosBiometricosAceptados = false;
    notifyListeners();
  }

  Future<void> completarPaso2({
    required String nombre,
    required String apellidos,
    required String documento,
    required String celular,
    required String direccion,
    required String distrito,
    required String provincia,
    required String departamento,
    required String padre,
    required String madre,
    required String responsable,
    required String correo,
    required String telefono,
    required bool terminosAceptados,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('paso2', true);
    await prefs.setString('nombre', nombre);
    await prefs.setString('apellidos', apellidos);
    await prefs.setString('documento', documento);
    await prefs.setString('celular', celular);
    await prefs.setString('direccion', direccion);
    await prefs.setString('distrito', distrito);
    await prefs.setString('provincia', provincia);
    await prefs.setString('departamento', departamento);
    await prefs.setString('nombrePadre', padre);
    await prefs.setString('nombreMadre', madre);
    await prefs.setString('responsablePago', responsable);
    await prefs.setString('correoResponsable', correo);
    await prefs.setString('telefonoResponsable', telefono);
    await prefs.setBool('terminosDatosAceptados', terminosAceptados);

    paso2Perfil = true;
    nombreUsuario = nombre;
    apellidosUsuario = apellidos;
    documentoUsuario = documento;
    celularUsuario = celular;
    direccionUsuario = direccion;
    distritoUsuario = distrito;
    provinciaUsuario = provincia;
    departamentoUsuario = departamento;
    nombrePadre = padre;
    nombreMadre = madre;
    responsablePago = responsable;
    correoResponsable = correo;
    telefonoResponsable = telefono;
    terminosDatosAceptados = terminosAceptados;
    notifyListeners();
  }

  // ✅ Actualiza y persiste la ruta local de la foto de perfil
  Future<void> actualizarFotoPerfil(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fotoPerfilPath', path);
    fotoPerfilPath = path;
    notifyListeners();
  }

  Future<void> completarPaso3() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('paso3', true);
    paso3Documentos = true;
    notifyListeners();
  }

  // ✅ Pago de Matrícula (antes vivía suelto en CoursesScreen)
  Future<void> completarPaso4PagoMatricula() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('paso4', true);
    paso4PagoMatricula = true;
    notifyListeners();
  }

  // ✅ Pasarela de pagos (nuevo, simulado)
  Future<void> completarPaso5Pasarela() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('paso5', true);
    paso5Pasarela = true;
    notifyListeners();
  }

  // ✅ Confirmación de matrícula (antes era completarPaso4)
  Future<void> completarPaso6Confirmacion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('paso6', true);
    paso6Confirmacion = true;
    notifyListeners();
  }

  // ✅ Conoce tu carrera (antes era completarPaso5)
  Future<void> completarPaso7Carrera() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('paso7', true);
    paso7Carrera = true;
    notifyListeners();
  }

  // ✅ Conquista el campus (antes era completarPaso6)
  Future<void> completarPaso8Campus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('paso8', true);
    paso8Campus = true;
    notifyListeners();
  }

  Future<void> resetearEstado() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    paso1Bienvenida = true;
    paso2Perfil = false;
    paso3Documentos = false;
    paso4PagoMatricula = false;
    paso5Pasarela = false;
    paso6Confirmacion = false;
    paso7Carrera = false;
    paso8Campus = false;
    biometriaRegistrada = false;
    terminosBiometricosAceptados = false;
    nombreUsuario = '';
    apellidosUsuario = '';
    documentoUsuario = '';
    carreraUsuario = '';
    nombrePadre = '';
    nombreMadre = '';
    direccionUsuario = '';
    responsablePago = '';
    correoResponsable = '';
    telefonoResponsable = '';
    celularUsuario = '';
    distritoUsuario = '';
    provinciaUsuario = '';
    departamentoUsuario = '';
    terminosDatosAceptados = false;
    fotoPerfilPath = '';
    notifyListeners();
  }
}
