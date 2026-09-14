import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/app_state.dart';
import '../widgets/main_scaffold.dart';
import 'dashboard_screen.dart';

/// Modelo de datos para un curso en la malla curricular oficial
class _CursoData {
  final String codigo;
  final String nombre;
  final int creditos;
  final int horasSemanales;
  final String
  tipoCompetencia; // 'Específica técnica' o 'Para la empleabilidad'
  final String descripcion;
  final String prerrequisitos;
  final List<String> herramientas;

  const _CursoData({
    required this.codigo,
    required this.nombre,
    required this.creditos,
    required this.horasSemanales,
    required this.tipoCompetencia,
    required this.descripcion,
    required this.prerrequisitos,
    required this.herramientas,
  });

  bool get esEspecificaTecnica =>
      tipoCompetencia.toLowerCase().contains('específica');
}

/// Modelo de datos para cada ciclo académico
class _CicloData {
  final int numero;
  final String nombreRomano;
  final String enfoque;
  final List<_CursoData> cursos;

  const _CicloData({
    required this.numero,
    required this.nombreRomano,
    required this.enfoque,
    required this.cursos,
  });

  int get totalCreditos => cursos.fold(0, (sum, c) => sum + c.creditos);
  int get totalHoras => cursos.fold(0, (sum, c) => sum + c.horasSemanales);
}

class CareerScreen extends StatefulWidget {
  const CareerScreen({super.key});

  @override
  State<CareerScreen> createState() => _CareerScreenState();
}

class _CareerScreenState extends State<CareerScreen>
    with SingleTickerProviderStateMixin {
  // Paleta de colores institucional Startec / Tecsup
  static const Color _primaryPurple = Color(0xFF9E4DFE);
  static const Color _brandPurple = Color(0xFFB96DFF);
  static const Color _darkPurple = Color(0xFF751FD6);
  static const Color _deepDark = Color(0xFF1E1435);
  static const Color _lightBg = Color(0xFFF7F5FC);
  static const Color _surfaceCard = Colors.white;

  // Colores de competencias según la Malla Oficial
  static const Color _colorTecnica = Color(
    0xFF0284C7,
  ); // Azul para Específica técnica
  static const Color _colorEmpleabilidad = Color(
    0xFFEA580C,
  ); // Naranja para Empleabilidad

  // Enlaces oficiales
  static const String _urlSilabo =
      'https://www.tecsup.edu.pe/wp-content/uploads/2026/silabo-general.pdf';
  static const String _urlMallaCurricular =
      'https://www1.tecsup.edu.pe/sites/default/files/files-webdrupal/plancurricular/53046-MALLACURRICULAR-3A_v3.pdf';
  static const String _urlCanvas =
      'https://tecsup.instructure.com/login/canvas';
  static const String _urlBiblioteca =
      'https://www.tecsup.edu.pe/biblioteca-virtual';

  late TabController _tabController;
  int _cicloSeleccionadoIndex = 0;
  bool _isCompleting = false;

  // ── Malla Curricular Oficial Completa (Ciclos 01 al 06) según Malla Tecsup ──
  final List<_CicloData> _mallaCurricular = const [
    // ── CICLO 01 ──────────────────────────────────────────────────────────
    _CicloData(
      numero: 1,
      nombreRomano: 'Ciclo 01',
      enfoque: 'Fundamentos de Programación, Lógica e Interfaces',
      cursos: [
        _CursoData(
          codigo: 'DS-101',
          nombre: 'Diseño de Interfaces de Programación',
          creditos: 4,
          horasSemanales: 4,
          tipoCompetencia: 'Específica técnica',
          descripcion:
              'Fundamentos de diseño UI/UX, arquitectura de información, maquetación web y desarrollo de interfaces interactivas y accesibles.',
          prerrequisitos: 'Ninguno (Ingreso)',
          herramientas: ['Figma', 'HTML5', 'CSS3', 'Design Systems'],
        ),
        _CursoData(
          codigo: 'DS-102',
          nombre: 'Fundamentos de Programación',
          creditos: 4,
          horasSemanales: 5,
          tipoCompetencia: 'Específica técnica',
          descripcion:
              'Lógica computacional, algoritmos estructurados, tipos de datos, estructuras de control y funciones con enfoque práctico.',
          prerrequisitos: 'Ninguno (Ingreso)',
          herramientas: ['Python', 'VS Code', 'Git', 'Flowgorithm'],
        ),
        _CursoData(
          codigo: 'CB-101',
          nombre: 'Ciencias Básicas Aplicadas',
          creditos: 3,
          horasSemanales: 3,
          tipoCompetencia: 'Específica técnica',
          descripcion:
              'Principios físicos y fundamentos de circuitos y lógica electrónica aplicados a la computación.',
          prerrequisitos: 'Ninguno (Ingreso)',
          herramientas: ['Simuladores Lógicos', 'Tinkercad'],
        ),
        _CursoData(
          codigo: 'HB-101',
          nombre: 'Técnicas de Expresión Oral y Escrita',
          creditos: 3,
          horasSemanales: 3,
          tipoCompetencia: 'Para la empleabilidad',
          descripcion:
              'Comunicación efectiva, redacción de documentos técnicos y oratoria orientada a presentaciones de proyectos.',
          prerrequisitos: 'Ninguno (Ingreso)',
          herramientas: ['Pitch Deck', 'Technical Writing'],
        ),
        _CursoData(
          codigo: 'CB-102',
          nombre: 'Cálculo y Estadística',
          creditos: 4,
          horasSemanales: 4,
          tipoCompetencia: 'Para la empleabilidad',
          descripcion:
              'Modelos matemáticos, álgebra lineal y estadística descriptiva para la resolución de problemas computacionales.',
          prerrequisitos: 'Ninguno (Ingreso)',
          herramientas: ['GeoGebra', 'Excel Estadístico', 'Python'],
        ),
        _CursoData(
          codigo: 'HB-102',
          nombre: 'Desarrollo Personal',
          creditos: 3,
          horasSemanales: 3,
          tipoCompetencia: 'Para la empleabilidad',
          descripcion:
              'Autoliderazgo, inteligencia emocional, ética profesional y trabajo colaborativo en equipo.',
          prerrequisitos: 'Ninguno (Ingreso)',
          herramientas: ['Miro', 'Dinámicas de Equipo'],
        ),
      ],
    ),

    // ── CICLO 02 ──────────────────────────────────────────────────────────
    _CicloData(
      numero: 2,
      nombreRomano: 'Ciclo 02',
      enfoque: 'POO, Bases de Datos y Arquitectura de Computadoras',
      cursos: [
        _CursoData(
          codigo: 'DS-201',
          nombre: 'Investigación de Mercado',
          creditos: 3,
          horasSemanales: 3,
          tipoCompetencia: 'Específica técnica',
          descripcion:
              'Análisis de tendencias de mercado, validación de necesidades de clientes y definición de requerimientos de productos tecnológicos.',
          prerrequisitos: 'Fundamentos de Programación',
          herramientas: ['Benchmarking', 'User Research', 'Google Analytics'],
        ),
        _CursoData(
          codigo: 'DS-202',
          nombre: 'Programación Orientada a Objetos',
          creditos: 4,
          horasSemanales: 5,
          tipoCompetencia: 'Específica técnica',
          descripcion:
              'Paradigmas de POO, clases, herencia, polimorfismo, encapsulamiento y patrones con Java y C#.',
          prerrequisitos: 'Fundamentos de Programación',
          herramientas: ['Java', 'IntelliJ IDEA', 'C#', 'Git'],
        ),
        _CursoData(
          codigo: 'DS-203',
          nombre: 'Base de Datos',
          creditos: 4,
          horasSemanales: 4,
          tipoCompetencia: 'Específica técnica',
          descripcion:
              'Modelamiento entidad-relación, normalización de datos y consultas estructuradas en SQL.',
          prerrequisitos: 'Fundamentos de Programación',
          herramientas: ['PostgreSQL', 'MySQL', 'DBeaver'],
        ),
        _CursoData(
          codigo: 'DS-204',
          nombre: 'Arquitectura de Computadoras',
          creditos: 3,
          horasSemanales: 3,
          tipoCompetencia: 'Específica técnica',
          descripcion:
              'Estructura interna del procesador, memorias, buses, microarquitectura y ensamblador básico.',
          prerrequisitos: 'Ciencias Básicas Aplicadas',
          herramientas: ['Logisim', 'Simulador CPU'],
        ),
        _CursoData(
          codigo: 'DS-205',
          nombre: 'Informática Aplicada en TI',
          creditos: 3,
          horasSemanales: 3,
          tipoCompetencia: 'Específica técnica',
          descripcion:
              'Infraestructura tecnológica, redes de datos, telecomunicaciones y servicios empresariales.',
          prerrequisitos: 'Ciencias Básicas Aplicadas',
          herramientas: ['Cisco Packet Tracer', 'Wireshark'],
        ),
        _CursoData(
          codigo: 'HB-201',
          nombre: 'Comprensión y Producción de Textos',
          creditos: 3,
          horasSemanales: 3,
          tipoCompetencia: 'Para la empleabilidad',
          descripcion:
              'Lectura crítica de documentación especializada y redacción avanzada de informes de ingeniería.',
          prerrequisitos: 'Técnicas de Expresión',
          herramientas: ['Normas APA/IEEE', 'Documentación Técnica'],
        ),
        _CursoData(
          codigo: 'CB-201',
          nombre: 'Aplicaciones del Cálculo y Estadística',
          creditos: 3,
          horasSemanales: 3,
          tipoCompetencia: 'Para la empleabilidad',
          descripcion:
              'Cálculo integral, probabilidad y distribuciones estadísticas aplicadas al análisis de software.',
          prerrequisitos: 'Cálculo y Estadística',
          herramientas: ['R Studio', 'Python Analytics'],
        ),
      ],
    ),

    // ── CICLO 03 ──────────────────────────────────────────────────────────
    _CicloData(
      numero: 3,
      nombreRomano: 'Ciclo 03',
      enfoque: 'Requerimientos, Algoritmos, Web y Sistemas Operativos',
      cursos: [
        _CursoData(
          codigo: 'DS-301',
          nombre: 'Ingeniería de Requerimientos y Diseño de Software',
          creditos: 4,
          horasSemanales: 4,
          tipoCompetencia: 'Específica técnica',
          descripcion:
              'Especificación formal de requisitos, modelado UML, historias de usuario y diseño arquitectónico inicial.',
          prerrequisitos: 'Investigación de Mercado',
          herramientas: ['Enterprise Architect', 'Draw.io', 'Jira'],
        ),
        _CursoData(
          codigo: 'DS-302',
          nombre: 'Estructuras de Datos y Algoritmos',
          creditos: 4,
          horasSemanales: 5,
          tipoCompetencia: 'Específica técnica',
          descripcion:
              'Listas, árboles, grafos, pilas, colas y algoritmos de optimización con análisis de complejidad Big-O.',
          prerrequisitos: 'Programación Orientada a Objetos',
          herramientas: ['Java', 'C++', 'Algoritmos y Benchmark'],
        ),
        _CursoData(
          codigo: 'DS-303',
          nombre: 'Desarrollo de Aplicaciones en Internet',
          creditos: 4,
          horasSemanales: 5,
          tipoCompetencia: 'Específica técnica',
          descripcion:
              'Desarrollo web del lado del cliente y servidor, protocolos HTTP/HTTPS, APIs RESTful y frameworks frontend.',
          prerrequisitos: 'Base de Datos',
          herramientas: ['JavaScript', 'TypeScript', 'Node.js', 'React'],
        ),
        _CursoData(
          codigo: 'DS-304',
          nombre: 'Base de Datos Avanzado',
          creditos: 4,
          horasSemanales: 4,
          tipoCompetencia: 'Específica técnica',
          descripcion:
              'Procedimientos almacenados, transacciones ACID, bases NoSQL, optimización de consultas e indexación.',
          prerrequisitos: 'Base de Datos',
          herramientas: ['PostgreSQL', 'MongoDB', 'Redis'],
        ),
        _CursoData(
          codigo: 'DS-305',
          nombre: 'Sistemas Operativos',
          creditos: 3,
          horasSemanales: 4,
          tipoCompetencia: 'Específica técnica',
          descripcion:
              'Gestión de procesos, memoria, almacenamiento, hilos de ejecución y scripting en entornos Linux.',
          prerrequisitos: 'Arquitectura de Computadoras',
          herramientas: ['Linux Ubuntu', 'Bash Scripting', 'Virtualización'],
        ),
        _CursoData(
          codigo: 'HB-301',
          nombre: 'Mejora Continua en el Diseño',
          creditos: 3,
          horasSemanales: 3,
          tipoCompetencia: 'Para la empleabilidad',
          descripcion:
              'Metodologías ágiles de feedback, iteración rápida, design thinking y aseguramiento continuo de valor.',
          prerrequisitos: 'Comprensión de Textos',
          herramientas: ['Scrum', 'Kanban', 'Mural'],
        ),
      ],
    ),

    // ── CICLO 04 ──────────────────────────────────────────────────────────
    _CicloData(
      numero: 4,
      nombreRomano: 'Ciclo 04',
      enfoque: 'Pruebas QA, Apps Empresariales, Web y Móviles',
      cursos: [
        _CursoData(
          codigo: 'DS-401',
          nombre: 'Construcción y Pruebas de Software',
          creditos: 4,
          horasSemanales: 4,
          tipoCompetencia: 'Específica técnica',
          descripcion:
              'Testing unitario, pruebas de integración, automatización QA, TDD y control de calidad del código.',
          prerrequisitos: 'Ingeniería de Requerimientos',
          herramientas: ['JUnit', 'Jest', 'Selenium', 'Postman'],
        ),
        _CursoData(
          codigo: 'DS-402',
          nombre: 'Tecnologías Emergentes',
          creditos: 3,
          horasSemanales: 3,
          tipoCompetencia: 'Específica técnica',
          descripcion:
              'Exploración de vanguardia: Inteligencia Artificial, Blockchain, IoT y tendencias disruptivas en TI.',
          prerrequisitos: 'Estructuras de Datos y Algoritmos',
          herramientas: ['OpenAI APIs', 'Python IA', 'IoT Hub'],
        ),
        _CursoData(
          codigo: 'DS-403',
          nombre: 'Desarrollo de Aplicaciones Empresariales',
          creditos: 4,
          horasSemanales: 5,
          tipoCompetencia: 'Específica técnica',
          descripcion:
              'Arquitectura de capas, inyección de dependencias, frameworks empresariales (Spring Boot, .NET Core) y persistencia.',
          prerrequisitos: 'Estructuras de Datos y Algoritmos',
          herramientas: ['Spring Boot', '.NET Core', 'Hibernate/JPA'],
        ),
        _CursoData(
          codigo: 'DS-404',
          nombre: 'Desarrollo de Aplicaciones Web',
          creditos: 4,
          horasSemanales: 4,
          tipoCompetencia: 'Específica técnica',
          descripcion:
              'Construcción de Single Page Applications (SPA), Server-Side Rendering (SSR), integración de APIs y seguridad web.',
          prerrequisitos: 'Desarrollo de Apps en Internet',
          herramientas: ['React', 'Next.js', 'Tailwind CSS'],
        ),
        _CursoData(
          codigo: 'DS-405',
          nombre: 'Programación en Móviles',
          creditos: 4,
          horasSemanales: 5,
          tipoCompetencia: 'Específica técnica',
          descripcion:
              'Desarrollo de aplicaciones móviles nativas y cross-platform, ciclo de vida de componentes y consumo de servicios.',
          prerrequisitos: 'Desarrollo de Apps en Internet',
          herramientas: ['Flutter', 'Dart', 'Android Studio'],
        ),
        _CursoData(
          codigo: 'HB-401',
          nombre: 'Investigación e Innovación Tecnológica',
          creditos: 3,
          horasSemanales: 3,
          tipoCompetencia: 'Para la empleabilidad',
          descripcion:
              'Metodología de la investigación científica, formulación de proyectos tecnológicos y patentes.',
          prerrequisitos: 'Mejora Continua',
          herramientas: ['Mendeley', 'Metodología Científica'],
        ),
      ],
    ),

    // ── CICLO 05 ──────────────────────────────────────────────────────────
    _CicloData(
      numero: 5,
      nombreRomano: 'Ciclo 05',
      enfoque: 'Móviles Multiplataforma, Cloud, Integración y Marketing',
      cursos: [
        _CursoData(
          codigo: 'DS-501',
          nombre: 'Aplicaciones Móviles Multiplataforma',
          creditos: 4,
          horasSemanales: 4,
          tipoCompetencia: 'Específica técnica',
          descripcion:
              'Arquitecturas avanzadas para Android e iOS, Clean Architecture, gestión de estado robusta y plugins nativos.',
          prerrequisitos: 'Programación en Móviles',
          herramientas: ['Flutter', 'Bloc/Provider', 'Firebase'],
        ),
        _CursoData(
          codigo: 'DS-502',
          nombre: 'Integración de Sistemas Empresariales',
          creditos: 4,
          horasSemanales: 4,
          tipoCompetencia: 'Específica técnica',
          descripcion:
              'Arquitectura orientada a servicios (SOA), microservicios, Message Brokers (RabbitMQ, Kafka) y Enterprise Integration Patterns.',
          prerrequisitos: 'Desarrollo de Apps Empresariales',
          herramientas: ['RabbitMQ', 'Kafka', 'Docker', 'REST/gRPC'],
        ),
        _CursoData(
          codigo: 'DS-503',
          nombre: 'Marketing y Comercialización de Nuevos Productos',
          creditos: 3,
          horasSemanales: 3,
          tipoCompetencia: 'Específica técnica',
          descripcion:
              'Growth hacking, estrategias de go-to-market para productos digitales, embudos de conversión y monetización.',
          prerrequisitos: 'Construcción y Pruebas',
          herramientas: ['Mixpanel', 'Google Ads', 'HubSpot'],
        ),
        _CursoData(
          codigo: 'DS-504',
          nombre: 'Desarrollo de Aplicaciones Web Avanzado',
          creditos: 4,
          horasSemanales: 4,
          tipoCompetencia: 'Específica técnica',
          descripcion:
              'Microfrontends, WebSockets en tiempo real, Progressive Web Apps (PWA), rendimiento extremo y seguridad OWASP.',
          prerrequisitos: 'Desarrollo de Aplicaciones Web',
          herramientas: ['WebSockets', 'GraphQL', 'Next.js Pro'],
        ),
        _CursoData(
          codigo: 'DS-505',
          nombre: 'Programación en Móviles Avanzado',
          creditos: 4,
          horasSemanales: 4,
          tipoCompetencia: 'Específica técnica',
          descripcion:
              'Geolocalización en tiempo real, biometría, pagos in-app, notificaciones push y publicación en App Store y Google Play.',
          prerrequisitos: 'Programación en Móviles',
          herramientas: ['Maps SDK', 'Stripe Móvil', 'CI/CD Móvil'],
        ),
        _CursoData(
          codigo: 'DS-506',
          nombre: 'Desarrollo de Soluciones en la Nube',
          creditos: 4,
          horasSemanales: 4,
          tipoCompetencia: 'Específica técnica',
          descripcion:
              'Despliegue serverless, contenedores, orquestación, balanceo de carga y arquitectura Cloud en AWS y GCP.',
          prerrequisitos: 'Construcción y Pruebas',
          herramientas: ['AWS', 'Docker', 'Kubernetes', 'Terraform'],
        ),
        _CursoData(
          codigo: 'HB-501',
          nombre: 'Diseño de Proyectos de Innovación',
          creditos: 3,
          horasSemanales: 3,
          tipoCompetencia: 'Para la empleabilidad',
          descripcion:
              'Estructuración, viabilidad financiera y técnica de proyectos MVP de alta escalabilidad.',
          prerrequisitos: 'Investigación e Innovación',
          herramientas: ['Business Model Canvas', 'Finanzas TI'],
        ),
      ],
    ),

    // ── CICLO 06 ──────────────────────────────────────────────────────────
    _CicloData(
      numero: 6,
      nombreRomano: 'Ciclo 06',
      enfoque: 'Startup Venture, BI, Integración Avanzada y Emprendimiento',
      cursos: [
        _CursoData(
          codigo: 'DS-601',
          nombre: 'Gestión de Servicio de Software',
          creditos: 3,
          horasSemanales: 3,
          tipoCompetencia: 'Específica técnica',
          descripcion:
              'Buenas prácticas ITIL, monitoreo de disponibilidad, Service Level Agreements (SLA), observabilidad y soporte continuo.',
          prerrequisitos: 'Desarrollo Soluciones Nube',
          herramientas: ['Datadog', 'Grafana', 'ITIL Framework'],
        ),
        _CursoData(
          codigo: 'DS-602',
          nombre: 'Integración de Sistemas Empresariales Avanzado',
          creditos: 4,
          horasSemanales: 4,
          tipoCompetencia: 'Específica técnica',
          descripcion:
              'Integración híbrida Cloud-OnPremise, Event-Driven Architecture, sincronización masiva y seguridad en APIs.',
          prerrequisitos: 'Integración de Sistemas',
          herramientas: ['Apache Kafka', 'API Gateways', 'OAuth2'],
        ),
        _CursoData(
          codigo: 'DS-603',
          nombre: 'Desarrollo de Aplicaciones Empresariales Avanzado',
          creditos: 4,
          horasSemanales: 4,
          tipoCompetencia: 'Específica técnica',
          descripcion:
              'Sistemas distribuidos de misión crítica, tolerancia a fallos, CQRS y arquitecturas de microservicios de alto tráfico.',
          prerrequisitos: 'Integración de Sistemas',
          herramientas: ['Microservicios', 'Redis Cache', 'Kubernetes'],
        ),
        _CursoData(
          codigo: 'DS-604',
          nombre: 'Startup Venture Project',
          creditos: 5,
          horasSemanales: 5,
          tipoCompetencia: 'Específica técnica',
          descripcion:
              'Desarrollo y puesta en producción del producto tecnológico integrador final (Capstone Project / Titulación).',
          prerrequisitos: 'Diseño Proyectos Innovación',
          herramientas: ['Stack Completo', 'Cloud Production', 'Pitch'],
        ),
        _CursoData(
          codigo: 'DS-605',
          nombre: 'Inteligencia de Negocios',
          creditos: 3,
          horasSemanales: 3,
          tipoCompetencia: 'Específica técnica',
          descripcion:
              'Data Warehousing, pipelines ETL, tableros analíticos interactivos y analítica predictiva para toma de decisiones.',
          prerrequisitos: 'Desarrollo Soluciones Nube',
          herramientas: ['Power BI', 'ETL Pipelines', 'SQL Analytics'],
        ),
        _CursoData(
          codigo: 'HB-601',
          nombre: 'Consultoría y Desarrollo Profesional',
          creditos: 3,
          horasSemanales: 3,
          tipoCompetencia: 'Para la empleabilidad',
          descripcion:
              'Consultoría técnica, marca personal, inserción laboral estratégica y negociación profesional.',
          prerrequisitos: 'Diseño Proyectos Innovación',
          herramientas: ['LinkedIn Pro', 'Portafolio Tech'],
        ),
        _CursoData(
          codigo: 'HB-602',
          nombre: 'Emprendimiento',
          creditos: 3,
          horasSemanales: 3,
          tipoCompetencia: 'Para la empleabilidad',
          descripcion:
              'Creación de empresas de base tecnológica, levantamiento de capital, propiedad intelectual y pitch a inversionistas.',
          prerrequisitos: 'Diseño Proyectos Innovación',
          herramientas: ['Pitch Deck', 'Legal Startup'],
        ),
        _CursoData(
          codigo: 'HB-603',
          nombre: 'Sociedad y Desarrollo Sostenible',
          creditos: 2,
          horasSemanales: 2,
          tipoCompetencia: 'Para la empleabilidad',
          descripcion:
              'Responsabilidad social corporativa, objetivos ODS, impacto ambiental y tecnología verde sostenible.',
          prerrequisitos: 'Desarrollo Personal',
          herramientas: ['ODS Tech', 'Green Computing'],
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _abrirEnlace(String url, String errorMsg) async {
    try {
      final uri = Uri.parse(url);
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text(errorMsg)),
              ],
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text(errorMsg)),
              ],
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  void _mostrarDetalleCurso(_CursoData curso) {
    final catColor = _colorPorCompetencia(curso.tipoCompetencia);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Header del modal
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: catColor.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          _iconoPorCompetencia(curso.tipoCompetencia),
                          color: catColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: catColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${curso.codigo} • ${curso.tipoCompetencia.toUpperCase()}',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: catColor,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              curso.nombre,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _deepDark,
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Métricas del curso
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _lightBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _infoItem(
                          icon: Icons.star_rounded,
                          titulo: 'Créditos',
                          valor: '${curso.creditos} Créditos',
                          color: Colors.amber.shade800,
                        ),
                        Container(
                          width: 1,
                          height: 32,
                          color: Colors.grey.shade300,
                        ),
                        _infoItem(
                          icon: Icons.access_time_filled_rounded,
                          titulo: 'Dedicación',
                          valor: '${curso.horasSemanales} hrs / sem',
                          color: _primaryPurple,
                        ),
                        Container(
                          width: 1,
                          height: 32,
                          color: Colors.grey.shade300,
                        ),
                        _infoItem(
                          icon: Icons.school_rounded,
                          titulo: 'Tipo',
                          valor: curso.esEspecificaTecnica
                              ? 'Técnica'
                              : 'Empleabilidad',
                          color: catColor,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Descripción
                  const Text(
                    'Descripción de la asignatura',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _deepDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    curso.descripcion,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: Colors.grey.shade800,
                      height: 1.45,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Prerrequisitos
                  const Text(
                    'Prerrequisitos',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _deepDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        size: 18,
                        color: Colors.indigo.shade600,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          curso.prerrequisitos,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Herramientas y tecnologías
                  const Text(
                    'Herramientas & Tecnologías aplicadas',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _deepDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: curso.herramientas.map((tech) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _primaryPurple.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _primaryPurple.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.code_rounded,
                              size: 14,
                              color: _primaryPurple,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              tech,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: _primaryPurple,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Botón de cerrar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Entendido',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _infoItem({
    required IconData icon,
    required String titulo,
    required String valor,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          titulo,
          style: TextStyle(
            fontSize: 10.5,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          valor,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: _deepDark,
          ),
        ),
      ],
    );
  }

  Color _colorPorCompetencia(String tipo) {
    if (tipo.toLowerCase().contains('empleabilidad')) {
      return _colorEmpleabilidad;
    }
    return _colorTecnica;
  }

  IconData _iconoPorCompetencia(String tipo) {
    if (tipo.toLowerCase().contains('empleabilidad')) {
      return Icons.psychology_outlined;
    }
    return Icons.terminal_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final nombreUsuario = appState.nombreUsuario.trim();
    final carreraUsuario = appState.carreraUsuario.isNotEmpty
        ? appState.carreraUsuario
        : 'Diseño y Desarrollo de Software';

    return MainScaffold(
      backgroundColor: _lightBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Navigation Bar ─────────────────────────────────────────
            _buildAppBar(context),

            // ── Contenido con Scroll ───────────────────────────────────────
            Expanded(
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),

                            // Hero Banner
                            _buildHeroBanner(nombreUsuario, carreraUsuario),

                            const SizedBox(height: 16),

                            // Métricas clave
                            _buildMetricasCards(),

                            const SizedBox(height: 18),

                            // Selector de pestañas
                            _buildTabBar(),

                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Malla Curricular
                    _buildMallaTab(),

                    // Tab 2: Perfil y Tecnologías
                    _buildPerfilTechTab(),

                    // Tab 3: Recursos y Canvas
                    _buildRecursosTab(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      color: _lightBg,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              if (Navigator.canPop(context)) Navigator.pop(context);
            },
            borderRadius: BorderRadius.circular(12),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: _deepDark,
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'Conoce tu Carrera',
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _deepDark,
                letterSpacing: -0.2,
              ),
            ),
          ),
          const SizedBox(width: 34),
        ],
      ),
    );
  }

  Widget _buildHeroBanner(String nombre, String carrera) {
    final saludo = nombre.isNotEmpty
        ? '¡Hola, $nombre!'
        : '¡Hola, Futuro Profesional!';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _brandPurple,
            _brandPurple.withValues(alpha: 0.85),
            _darkPurple,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _brandPurple.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -25,
            top: -25,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Image.asset(
                      'assets/images/software-icon2.png',
                      width: 46,
                      height: 46,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.computer_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          saludo,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          carrera,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: Colors.amberAccent,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Malla curricular oficial estructurada en competencias técnicas y para la empleabilidad.',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricasCards() {
    return Row(
      children: [
        Expanded(
          child: _metricCard(
            icon: Icons.timelapse_rounded,
            valor: '3 Años',
            subtitulo: '6 Ciclos',
            color: _primaryPurple,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _metricCard(
            icon: Icons.trending_up_rounded,
            valor: '96%',
            subtitulo: 'Empleabilidad',
            color: const Color(0xFF0284C7),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _metricCard(
            icon: Icons.workspace_premium_rounded,
            valor: '3 Módulos',
            subtitulo: 'Certificaciones',
            color: const Color(0xFF059669),
          ),
        ),
      ],
    );
  }

  Widget _metricCard({
    required IconData icon,
    required String valor,
    required String subtitulo,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: _surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFECE8F7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              valor,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _deepDark,
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              subtitulo,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFECE7F8),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(4),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: _primaryPurple,
        unselectedLabelColor: Colors.grey.shade700,
        labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('Malla Curricular'),
            ),
          ),
          Tab(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('Certificaciones'),
            ),
          ),
          Tab(
            child: FittedBox(fit: BoxFit.scaleDown, child: Text('Recursos')),
          ),
        ],
      ),
    );
  }

  // ── Tab 1: Malla Curricular Oficial ───────────────────────────────────────
  Widget _buildMallaTab() {
    final cicloActual = _mallaCurricular[_cicloSeleccionadoIndex];

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        18,
        8,
        18,
        MainScaffold.bottomBarHeight(context) + 30,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Leyenda de Competencias (como en la foto oficial)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _colorTecnica,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Específicas técnicas',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: _deepDark,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _colorEmpleabilidad,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Para la empleabilidad',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: _deepDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Selector de Ciclos (Ciclo 01 al 06)
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _mallaCurricular.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isSelected = _cicloSeleccionadoIndex == index;
                return ChoiceChip(
                  label: Text(_mallaCurricular[index].nombreRomano),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _cicloSeleccionadoIndex = index);
                    }
                  },
                  selectedColor: _primaryPurple,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : _deepDark,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    fontSize: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? _primaryPurple : Colors.grey.shade300,
                    ),
                  ),
                  showCheckmark: false,
                );
              },
            ),
          ),

          const SizedBox(height: 14),

          // Resumen del ciclo seleccionado
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFECE8F7)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enfoque: ${cicloActual.enfoque}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: _deepDark,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${cicloActual.cursos.length} Asignaturas • ${cicloActual.totalCreditos} Créditos • ${cicloActual.totalHoras} hrs/sem',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Lista de Cursos del Ciclo
          ...cicloActual.cursos.map((curso) => _buildCourseCard(curso)),

          const SizedBox(height: 14),

          // Botón para ver Malla PDF Oficial
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _abrirEnlace(
                _urlMallaCurricular,
                'No se pudo abrir el PDF de la malla curricular.',
              ),
              icon: const Icon(
                Icons.picture_as_pdf_rounded,
                color: _darkPurple,
                size: 20,
              ),
              label: const Text(
                'Descargar Malla Curricular Completa (PDF)',
                style: TextStyle(
                  color: _darkPurple,
                  fontWeight: FontWeight.bold,
                  fontSize: 13.5,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _brandPurple, width: 1.4),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 16),

          _buildBottomActionBar(),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCourseCard(_CursoData curso) {
    final catColor = _colorPorCompetencia(curso.tipoCompetencia);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFECE8F7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _mostrarDetalleCurso(curso),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Indicador cuadrado como en el afiche oficial
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: catColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 12),

                // Info del curso
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: catColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              curso.tipoCompetencia,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: catColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '•  ${curso.creditos} Créditos',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        curso.nombre,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _deepDark,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),

                // Flecha de acción
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Tab 2: Certificaciones Modulares & Tech ──────────────────────────────
  Widget _buildPerfilTechTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        18,
        8,
        18,
        MainScaffold.bottomBarHeight(context) + 30,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Certificaciones modulares anuales (de la foto oficial)
          _seccionTitulo(
            'Certificación Modular Anual',
            Icons.workspace_premium_rounded,
          ),
          _certificacionCard(
            modulo: 'Año 01 / Módulo 1',
            titulo: 'Tecnologías Aplicadas al Desarrollo de Software',
            icon: Icons.code_rounded,
            color: _primaryPurple,
          ),
          _certificacionCard(
            modulo: 'Año 02 / Módulo 2',
            titulo: 'Programación de Aplicaciones Web y Móviles',
            icon: Icons.devices_rounded,
            color: const Color(0xFF0284C7),
          ),
          _certificacionCard(
            modulo: 'Año 03 / Módulo 3',
            titulo: 'Diseño e Integración de Aplicaciones Empresariales',
            icon: Icons.domain_rounded,
            color: const Color(0xFF059669),
          ),

          const SizedBox(height: 18),

          // Perfil de egreso
          _seccionTitulo('Perfil del Egresado Tecsup', Icons.school_outlined),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFECE8F7)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Como profesional en Diseño y Desarrollo de Software serás capaz de liderar la creación, arquitectura y mantenimiento de soluciones tecnológicas innovadoras de alta disponibilidad y escalabilidad.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),
                _bulletPunto(
                  'Diseño de arquitecturas de software modernas (Microservicios, Cloud Native).',
                ),
                _bulletPunto(
                  'Desarrollo Fullstack (Web frontend, Backend APIs, Apps móviles nativas).',
                ),
                _bulletPunto(
                  'Automatización DevOps, CI/CD y despliegue continuo en la nube.',
                ),
                _bulletPunto(
                  'Integración de Inteligencia Artificial aplicada a productos digitales.',
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Tech Stack
          _seccionTitulo('Tecnologías que dominarás', Icons.code_rounded),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFECE8F7)),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 10,
              children: [
                _techBadge(
                  'Flutter & Dart',
                  Icons.flutter_dash,
                  _primaryPurple,
                ),
                _techBadge('React & Next.js', Icons.web, Colors.cyan.shade700),
                _techBadge(
                  'Python & IA',
                  Icons.psychology,
                  Colors.amber.shade900,
                ),
                _techBadge(
                  'Spring Boot & .NET',
                  Icons.dns_rounded,
                  Colors.green.shade700,
                ),
                _techBadge(
                  'PostgreSQL & MongoDB',
                  Icons.storage_rounded,
                  Colors.indigo.shade700,
                ),
                _techBadge(
                  'AWS & Cloud',
                  Icons.cloud_queue_rounded,
                  Colors.orange.shade800,
                ),
                _techBadge(
                  'Docker & Kubernetes',
                  Icons.view_in_ar_rounded,
                  Colors.blue.shade700,
                ),
                _techBadge(
                  'Git & GitHub',
                  Icons.merge_type_rounded,
                  Colors.grey.shade800,
                ),
                _techBadge(
                  'Figma & UI/UX',
                  Icons.palette_outlined,
                  Colors.pink.shade600,
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          _buildBottomActionBar(),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _certificacionCard({
    required String modulo,
    required String titulo,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFECE8F7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  modulo,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: _deepDark,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bulletPunto(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 16,
            color: _primaryPurple,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(
                fontSize: 12.5,
                color: Colors.grey.shade800,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _techBadge(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab 3: Recursos y Canvas ──────────────────────────────────────────────
  Widget _buildRecursosTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        18,
        8,
        18,
        MainScaffold.bottomBarHeight(context) + 30,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner de Canvas LMS
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE53935), Color(0xFFC62828)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Aula Virtual Canvas',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Plataforma oficial de clases y tareas',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'Accede con tu correo institucional @tecsup.edu.pe para revisar material de clases, foros y entregas.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _abrirEnlace(
                      _urlCanvas,
                      'No se pudo abrir el portal de Canvas.',
                    ),
                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    label: const Text(
                      'Ingresar a Canvas LMS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFC62828),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Documentos y enlaces clave
          _seccionTitulo('Documentos Académicos', Icons.folder_shared_outlined),

          _recursoCard(
            titulo: 'Sílabo Oficial 2026-I',
            subtitulo: 'Contenidos, criterios de evaluación y calendario',
            icon: Icons.menu_book_rounded,
            badge: 'PDF Oficial',
            color: _primaryPurple,
            onTap: () =>
                _abrirEnlace(_urlSilabo, 'No se pudo abrir el sílabo general.'),
          ),

          _recursoCard(
            titulo: 'Malla Curricular Detallada',
            subtitulo: 'Distribución oficial de cursos y competencias',
            icon: Icons.table_chart_rounded,
            badge: 'Descargar',
            color: const Color(0xFF0284C7),
            onTap: () => _abrirEnlace(
              _urlMallaCurricular,
              'No se pudo abrir la malla curricular.',
            ),
          ),

          _recursoCard(
            titulo: 'Biblioteca Virtual & IEEE Xplore',
            subtitulo: 'Bases de datos científicas, papers y libros digitales',
            icon: Icons.local_library_rounded,
            badge: 'Acceso Libre',
            color: const Color(0xFF059669),
            onTap: () => _abrirEnlace(
              _urlBiblioteca,
              'No se pudo abrir la biblioteca virtual.',
            ),
          ),

          const SizedBox(height: 20),

          // Beneficios de estudiante
          _seccionTitulo(
            'Beneficios Tecnológicos Gratuitos',
            Icons.card_giftcard_rounded,
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFECE8F7)),
            ),
            child: Column(
              children: [
                _beneficioItem(
                  titulo: 'GitHub Student Developer Pack',
                  desc:
                      'Herramientas de desarrollo, dominios gratis y créditos en la nube.',
                  icon: Icons.terminal_rounded,
                ),
                const Divider(height: 20),
                _beneficioItem(
                  titulo: 'Licencias JetBrains Pro',
                  desc:
                      'IDEs profesionales (IntelliJ, WebStorm, PyCharm) gratis para alumnos.',
                  icon: Icons.code_rounded,
                ),
                const Divider(height: 20),
                _beneficioItem(
                  titulo: 'Microsoft Office 365 & OneDrive 1TB',
                  desc:
                      'Word, Excel, PowerPoint y almacenamiento cloud con tu correo Tecsup.',
                  icon: Icons.cloud_circle_rounded,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Próximamente
          _seccionTitulo('Próximamente', Icons.schedule_rounded),
          _proximamenteCard(
            icon: Icons.calendar_month_rounded,
            titulo: 'Publicación de Horarios y Secciones',
            subtitulo: 'Disponible en la 2da fase antes del inicio del ciclo.',
          ),

          const SizedBox(height: 18),

          _buildBottomActionBar(),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _seccionTitulo(String titulo, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: _primaryPurple),
          const SizedBox(width: 8),
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: _deepDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _recursoCard({
    required String titulo,
    required String subtitulo,
    required IconData icon,
    required String badge,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFECE8F7)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              titulo,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: _deepDark,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              badge,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitulo,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _beneficioItem({
    required String titulo,
    required String desc,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: _primaryPurple),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: _deepDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 11.5,
                  color: Colors.grey.shade600,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _proximamenteCard({
    required IconData icon,
    required String titulo,
    required String subtitulo,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  subtitulo,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '2da fase',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Sticky Bottom Action Bar ──────────────────────────────────────────────
  // ── Sticky Bottom Action Bar ──────────────────────────────────────────────
  Widget _buildBottomActionBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: GestureDetector(
        onTap: _isCompleting
            ? null
            : () async {
                setState(() => _isCompleting = true);
                await context.read<AppState>().completarPaso7Carrera();
                if (!mounted) return;
                setState(() => _isCompleting = false);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: Colors.white),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '¡Paso 7 completado! Bienvenido a tu vida académica.',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: const Color(0xFF059669),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DashboardScreen()),
                );
              },
        child: Container(
          width: double.infinity,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _brandPurple,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                color: Color.fromARGB(255, 132, 57, 231),
                offset: Offset(3, 6),
                blurRadius: 3,
                spreadRadius: 1,
              ),
            ],
          ),
          child: _isCompleting
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Completar y Continuar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
