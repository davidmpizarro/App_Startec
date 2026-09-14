import '../models/horario_model.dart';

/// Servicio encargado de obtener el horario y los cursos matriculados
/// del alumno desde el sistema U+ (consumo de solo lectura).
///
/// FASE 2 — pendiente de integración real.
/// Cuando U+ entregue el endpoint/credenciales, reemplazar el cuerpo de
/// `obtenerHorario` por el llamado HTTP real (por ejemplo con `http` o
/// `dio`), manteniendo la misma firma para no tener que tocar la UI.
class HorarioService {
  /// Devuelve la lista de cursos matriculados con su horario.
  /// Lanza una excepción si la consulta falla (la UI debe capturarla
  /// y mostrar un estado de error).
  Future<List<CursoMatriculado>> obtenerHorario(String documentoAlumno) async {
    // ── TODO (Fase 2): reemplazar por el consumo real de la API de U+ ──
    //
    // Ejemplo de forma esperada una vez integrado:
    //
    // final response = await http.get(
    //   Uri.parse('https://api.uplus.tecsup.edu.pe/horarios/$documentoAlumno'),
    //   headers: {'Authorization': 'Bearer $token'},
    // );
    // if (response.statusCode != 200) {
    //   throw Exception('No se pudo obtener el horario (${response.statusCode})');
    // }
    // final data = jsonDecode(response.body) as List<dynamic>;
    // return data
    //     .map((c) => CursoMatriculado.fromJson(c as Map<String, dynamic>))
    //     .toList();

    throw UnimplementedError(
      'La consulta de horarios (API U+) aún no está disponible. '
      'Se habilitará en la Fase 2.',
    );
  }
}
