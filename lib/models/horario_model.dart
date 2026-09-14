/// Representa una sesión de clase dentro del horario semanal
/// (ej. Lunes 08:00-10:00, Aula 302).
class SesionHorario {
  final String dia; // 'Lunes', 'Martes', ...
  final String horaInicio; // '08:00'
  final String horaFin; // '10:00'
  final String aula;
  final String docente;

  const SesionHorario({
    required this.dia,
    required this.horaInicio,
    required this.horaFin,
    required this.aula,
    required this.docente,
  });

  factory SesionHorario.fromJson(Map<String, dynamic> json) => SesionHorario(
    dia: json['dia'] ?? '',
    horaInicio: json['horaInicio'] ?? '',
    horaFin: json['horaFin'] ?? '',
    aula: json['aula'] ?? '',
    docente: json['docente'] ?? '',
  );
}

/// Representa un curso matriculado, con sus sesiones de horario.
class CursoMatriculado {
  final String codigo;
  final String nombre;
  final String seccion;
  final int creditos;
  final List<SesionHorario> sesiones;

  const CursoMatriculado({
    required this.codigo,
    required this.nombre,
    required this.seccion,
    required this.creditos,
    required this.sesiones,
  });

  factory CursoMatriculado.fromJson(Map<String, dynamic> json) =>
      CursoMatriculado(
        codigo: json['codigo'] ?? '',
        nombre: json['nombre'] ?? '',
        seccion: json['seccion'] ?? '',
        creditos: json['creditos'] ?? 0,
        sesiones: (json['sesiones'] as List<dynamic>? ?? [])
            .map((s) => SesionHorario.fromJson(s as Map<String, dynamic>))
            .toList(),
      );
}
